//
//  MainTableViewSectionHeaderView.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/20/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class MainTableViewHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    var headerName: String!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */


}
