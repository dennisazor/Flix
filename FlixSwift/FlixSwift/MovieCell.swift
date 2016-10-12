//
//  MovieCell.swift
//  FlixSwift
//
//  Created by Suraya Shivji on 10/10/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var movieImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleText.font = UIFont(name: "Avenir", size: 20.0)
        titleText.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleText.numberOfLines = 0
        
        descriptionText.font = UIFont(name: "Avenir", size: 13.0)
        descriptionText.lineBreakMode = NSLineBreakMode.byWordWrapping
        descriptionText.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
