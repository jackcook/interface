//
//  ShareViewController.swift
//  Add to Interface
//
//  Created by Jack Cook on 4/5/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.5) { 
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
            self.activityIndicator.alpha = 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        activityIndicator.center = view.center
    }
}
