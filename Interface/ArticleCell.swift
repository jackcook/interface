//
//  ArticleCell.swift
//  Interface
//
//  Created by Jack Cook on 4/2/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstLineLabel: UILabel?
    @IBOutlet weak var sourceImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sourceImage.image = sourceImage.image?.imageWithRenderingMode(.AlwaysTemplate)
        sourceImage.tintColor = UIColor(white: 0, alpha: 0.75)
        
        sourceImage.alpha = 0
        
        let hour = Int(arc4random_uniform(9)) + 1
        timeLabel.text = "\(hour)h"
    }
    
    func configure(article: Article) {
        titleLabel.text = article.title
        firstLineLabel?.text = article.description
        
        Interface.sharedInstance.getArticleThumbnail(article) { (image) in
            self.articleImage?.image = image
        }
    }
}
