//
//  UrlQueryParameters.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/27/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class UrlQueryParameters {
    // MARK: Properties
    
    var location: String
    var category: String
    var radius: Int
    var limit: Int
    var openAt: Int
    
    // MARK: Initialization
    init?(location: String, category: String, radius: Int, limit: Int, openAt: Int) {
        self.location = location
        self.category = category
        self.radius = radius
        self.limit = limit
        self.openAt = openAt

    }
}