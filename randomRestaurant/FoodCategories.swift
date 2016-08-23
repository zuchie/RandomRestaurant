//
//  FoodCategories.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/23/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class FoodCategories {
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Float
    
    // MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Float) {
        self.name = name
        self.photo = photo
        self.rating = rating
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
}