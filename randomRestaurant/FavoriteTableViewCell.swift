//
//  FavoriteTableViewCell.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 1/31/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation

class FavoriteTableViewCell: UITableViewCell {

    var rating: String!
    var reviewCount: String!
    var url: String!
    var price: String!
    var address: String!
    var coordinate: CLLocationCoordinate2D!
    var category: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let imageView = UIImageView()
        imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 10.0, height: 10.0))
        imageView.image = UIImage(named: "leftArrow")
        accessoryView = imageView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
