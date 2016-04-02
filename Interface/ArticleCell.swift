//
//  ArticleCell.swift
//  Interface
//
//  Created by Jack Cook on 4/2/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstLineLabel: UILabel?
    @IBOutlet weak var sourceImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sourceImage.image = sourceImage.image?.imageWithRenderingMode(.AlwaysTemplate)
        sourceImage.tintColor = UIColor(white: 0, alpha: 0.75)
    }
}
