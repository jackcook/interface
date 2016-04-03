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
    
    private var articleTitle: UILabel!
    private var imageView: UIImageView!
    private var textView: ArticleTextView!
    
    private var translateView: UIView!
    private var translateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        if imageView == nil {
            imageView = UIImageView()
            imageView.image = UIImage(named: "Article Image")
            scrollView.addSubview(imageView)
        }
        
        let width = scrollView.bounds.width
        imageView.frame = CGRectMake(0, articleTitle.frame.origin.y + articleTitle.frame.size.height + 16, width, width * (9/16))
        
        if textView == nil {
            textView = ArticleTextView(delegate: self)
            textView.editable = false
            textView.font = UIFont.systemFontOfSize(16)
            textView.scrollEnabled = false
            textView.text = "JOSEPH EID / AFP\n\nPrès d’une semaine après le départ des djihadistes, la de Palmyre, qui a fui les combats des dernières semaines, n’était toujours pas revenue par crainte des mines plantées par l’EI, de représailles du régime ou du fait des importantes destructions causées par les combats et les bombardements aériens russes. Estimée à 70 000 personnes avant la guerre, elle était tombée à 15 000 durant la présence de l’EI.\n\nLa cité antique, patrimoine mondial de l’humanité, a par ailleurs subi de sérieuses dégradations, certaines parties ayant été dynamitées par les djihadistes. Un photographe de l’Agence France-presse (AFP), Joseph Eid, a comparé les ruines avant et après l’occupation par l’EI.\n\n\"Le temple de Bêl ne sera plus jamais comme avant. D'après nos experts, nous allons pouvoir certainement restaurer un tiers de la cella détruite et peut-être plus après des études complémentaires avec l'Unesco. Cela prendra cinq ans de travail sur le terrain\", a affirmé le directeur des antiquités syriennes, Maamoun Abdelkarim."
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
            translateView.backgroundColor = UIColor(white: 0, alpha: 0.85)
            translateView.layer.cornerRadius = 8
            view.addSubview(translateView)
        }
        translateView.frame = CGRectMake(16, 80, view.bounds.width - 32, 36)
        
        if translateLabel == nil {
            translateLabel = UILabel()
            translateLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightSemibold)
            translateLabel.text = "around twenty"
            translateLabel.textAlignment = .Center
            translateLabel.textColor = UIColor.whiteColor()
            translateView.addSubview(translateLabel)
        }
        translateLabel.frame = CGRectMake(16, 4, translateView.frame.size.width - 32, 28)
    }
    
    func longTouchReceived(point: CGPoint, state: UIGestureRecognizerState, text: String) {
        switch state {
        case .Began:
            UIView.animateWithDuration(0.25, animations: {
                self.translateView.alpha = 1
            })
        case .Changed:
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
        case .Ended:
            UIView.animateWithDuration(0.25, animations: {
                self.translateView.alpha = 0
            }, completion: { (done) in
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
