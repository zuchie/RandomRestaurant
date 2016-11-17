//
//  YelpUrlQueryParameters.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/27/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class YelpUrlQueryParameters {
    
    /*
    // MARK: Properties
    static var location: String?
    static var category: String?
    static var radius = 40000
    static var limit = 50
    static var openAt: Int?
    */
    
    var location: String?
    var category: String?
    var radius: Int?
    var limit: Int?
    var openAt: Int?
    
    // MARK: Initialization
    init?(location: String, category: String, radius: Int, limit: Int, openAt: Int) {
        self.location = location
        self.category = category
        self.radius = radius
        self.limit = limit
        self.openAt = openAt

    }
}
