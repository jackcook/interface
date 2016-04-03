//
//  ArticleViewController.swift
//  Interface
//
//  Created by Jack Cook on 4/2/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController, ArticleTextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var article: Article!
    
    private var articleTitle: UILabel!
    private var imageView: UIImageView!
    private var textView: ArticleTextView!
    
    private var translateView: UIView!
    private var translateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView()
        scrollView.addSubview(imageView)
        
        Interface.sharedInstance.getArticleThumbnail(article) { (image) in
            self.imageView.image = image
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView == nil {
            scrollView = UIScrollView()
            view.addSubview(scrollView)
        }
        scrollView.frame = view.bounds
        
        if articleTitle == nil {
            articleTitle = UILabel()
            articleTitle.font = UIFont.systemFontOfSize(22, weight: UIFontWeightSemibold)
            articleTitle.numberOfLines = 0
            articleTitle.text = "Un charnier de l’Etat islamique découvert à Palmyre, en Syrie"
            scrollView.addSubview(articleTitle)
        }
        
        let articleTitleHeight = (articleTitle.text! as NSString).boundingRectWithSize(CGSizeMake(scrollView.bounds.width - 32, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: articleTitle.font], context: nil).height
        articleTitle.frame = CGRectMake(16, 16, scrollView.bounds.width - 32, articleTitleHeight)
        
        let imageWidth = scrollView.bounds.width
        imageView.frame = CGRectMake(0, articleTitle.frame.origin.y + articleTitle.frame.size.height + 16, imageWidth, imageWidth * (9/16))
        
        if textView == nil {
            guard let text = article.text else {
                return
            }
            
            var articleText = text.componentsSeparatedByString("\n")
            
            var idx = 0
            for line in articleText {
                if line.characters.count < 50 {
                    articleText.removeAtIndex(idx)
                    idx -= 1
                }
                
                idx += 1
            }
            
            let finalText = articleText.joinWithSeparator("\n\n")
            
            textView = ArticleTextView(delegate: self)
            textView.editable = false
            textView.font = UIFont.systemFontOfSize(16)
            textView.scrollEnabled = false
            textView.text = finalText
            scrollView.addSubview(textView)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let attributes = [NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: textView.font!]
            textView.attributedText = NSAttributedString(string: textView.text, attributes: attributes)
        }
        
        let textViewHeight = textView.sizeThatFits(CGSizeMake(scrollView.bounds.width - 32, CGFloat.max)).height
        textView.frame = CGRectMake(16, imageView.frame.origin.y + imageView.frame.size.height + 10, scrollView.bounds.width - 32, textViewHeight)
        
        scrollView.contentSize = CGSizeMake(scrollView.bounds.width, textView.frame.origin.y + textView.frame.size.height + 16)
        
        if translateView == nil {
            translateView = UIView()
            translateView.alpha = 0
            translateView.backgroundColor = UIColor(white: 0, alpha: 0.85)
            translateView.layer.cornerRadius = 8
            view.addSubview(translateView)
        }
        translateView.frame = CGRectMake(16, 80, view.bounds.width - 32, 36)
        
        if translateLabel == nil {
            translateLabel = UILabel()
            translateLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightSemibold)
            translateLabel.text = ""
            translateLabel.textAlignment = .Center
            translateLabel.textColor = UIColor.whiteColor()
            translateView.addSubview(translateLabel)
        }
        translateLabel.frame = CGRectMake(16, 4, translateView.frame.size.width - 32, 28)
    }
    
    func longTouchReceived(point: CGPoint, state: UIGestureRecognizerState, text: String) {
        func moveTranslationView() {
            translateView.frame = CGRectMake(16, point.y - 96 - translateView.frame.size.height, translateView.frame.size.width, translateView.frame.size.height)
            
            let text = (textView.text as NSString).substringWithRange(textView.selectedRange)
            Interface.sharedInstance.translateTerm(text) { (translation) in
                guard let translation = translation else {
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.translateLabel.text = translation
                })
            }
        }
        
        switch state {
        case .Began:
            UIView.animateWithDuration(0.25, animations: {
                self.translateView.alpha = 1
                moveTranslationView()
            })
        case .Changed:
            moveTranslationView()
        case .Ended:
            UIView.animateWithDuration(0.25, animations: {
                self.translateView.alpha = 0
                self.translateView.frame = CGRectMake(16, 80, self.view.bounds.width - 32, 36)
            })
            
            textView.becomeFirstResponder()
            
            let copyItem = UIMenuItem(title: "Copy", action: #selector(copyText))
            let translateItem = UIMenuItem(title: "Translate", action: #selector(translate))
            UIMenuController.sharedMenuController().menuItems = [copyItem, translateItem]
            UIMenuController.sharedMenuController().setTargetRect(CGRectMake(point.x, point.y, 1, 1), inView: view)
            UIMenuController.sharedMenuController().setMenuVisible(true, animated: true)
        default:
            break
        }
    }
    
    internal func copyText() {
        let text = (textView.text as NSString).substringWithRange(textView.selectedRange)
        UIPasteboard.generalPasteboard().string = text
    }
    
    internal func translate() {
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return action == #selector(copyText) || action == #selector(translate)
    }
}