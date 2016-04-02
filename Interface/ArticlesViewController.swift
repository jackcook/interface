//
//  ArticlesViewController.swift
//  Interface
//
//  Created by Jack Cook on 4/2/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

class ArticlesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        Quizlet.sharedInstance.createSet(["term1": "term1valuea", "term2": "term2valuea"]) { (url) in
            print(url)
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row % 5 == 0 ? 312 : 136
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = NSBundle.mainBundle().loadNibNamed(indexPath.row % 5 == 0 ? "LargeArticleCell" : "ArticleCell", owner: self, options: nil)[0] as! ArticleCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Quizlet.sharedInstance.beginAuthorization(self)
    }
}
