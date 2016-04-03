//
//  ArticleTextView.swift
//  Interface
//
//  Created by Jack Cook on 4/2/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

class ArticleTextView: UITextView, UIGestureRecognizerDelegate {
    
    private var articleDelegate: ArticleTextViewDelegate?
    private var longPressRecognizer: UILongPressGestureRecognizer!
    
    init(delegate: ArticleTextViewDelegate?) {
        super.init(frame: CGRectZero, textContainer: nil)
        
        articleDelegate = delegate
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressRecognizer.delegate = self
        addGestureRecognizer(longPressRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let superview = superview?.superview else {
            return
        }
        
        let point = gestureRecognizer.locationInView(superview)
        articleDelegate?.longTouchReceived(point, state: gestureRecognizer.state, text: (text as NSString).substringWithRange(selectedRange))
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }
}

protocol ArticleTextViewDelegate {
    func longTouchReceived(point: CGPoint, state: UIGestureRecognizerState, text: String)
}
