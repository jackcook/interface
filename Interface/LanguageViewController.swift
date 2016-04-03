//
//  LanguageViewController.swift
//  Interface
//
//  Created by Jack Cook on 4/3/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        doneButton.enabled = false
        
        tableView.bounces = false
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        for idx in 0..<tableView.numberOfRowsInSection(0) {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: idx, inSection: 0))
            if cell?.accessoryType == .Checkmark {
                switch idx {
                case 1: language = "zh-CN"
                case 2: language = "fr-FR"
                case 3: language = "es-ES"
                case 4: language = "sv-SE"
                default: language = "fr-FR"
                }
                
                break
            }
        }
        
        performSegueWithIdentifier("articlesSegue", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 42
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "LanguageCell")
        
        switch indexPath.row {
        case 0: cell.selectionStyle = .None
        case 1: cell.textLabel?.text = "Chinese"
        case 2: cell.textLabel?.text = "French"
        case 3: cell.textLabel?.text = "Spanish"
        case 4: cell.textLabel?.text = "Swedish"
        default: break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        doneButton.enabled = true
        
        for idx in 0..<tableView.numberOfRowsInSection(0) {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: idx, inSection: 0))
            cell?.accessoryType = .None
        }
        
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
    }
}
