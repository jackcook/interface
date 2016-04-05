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
    
    private var articles = [Article]()
    private var articleToSend: Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        
        Interface.sharedInstance.retrieveArticles { (articles) in
            guard let articles = articles else {
                return
            }
            
            self.articles = articles
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func quizletButton(sender: UIBarButtonItem) {
        if Quizlet.sharedInstance.accessToken == nil {
            Quizlet.sharedInstance.beginAuthorization(self)
        } else {
            let setId = Quizlet.sharedInstance.setId
            
            guard setId > 0 else {
                return
            }
            
            let url = NSURL(string: "https://quizlet.com/\(setId)/")!
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let avc = segue.destinationViewController as! ArticleViewController
        avc.article = articleToSend
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row % 5 == 0 ? 312 : 136
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let article = articles[indexPath.row]
        
        let cell = NSBundle.mainBundle().loadNibNamed(indexPath.row % 5 == 0 ? (article.imageUrl == nil ? "NoImageArticleCell" : "LargeArticleCell") : (article.imageUrl == nil ? "NoImageArticleCell" : "ArticleCell"), owner: self, options: nil)[0] as! ArticleCell
        cell.configure(articles[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        articleToSend = articles[indexPath.row]
        performSegueWithIdentifier("articleSegue", sender: nil)
    }
}
