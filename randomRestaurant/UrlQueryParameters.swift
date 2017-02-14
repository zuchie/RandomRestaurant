//
//  YelpUrlQueryParameters.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/27/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import CoreLocation

class YelpUrlQueryParameters {
    
    // MARK: Properties
    static var coordinates: CLLocationCoordinate2D?
    static var category: String?
    static var radius = 10000
    static var limit = 50
    static var openAt: Int?
    
    static var rating = 0.0

    /*
    // MARK: Properties.
    
    var coordinates: CLLocationCoordinate2D?
    var category: String?
    var radius: Int?
    var limit: Int?
    var openAt: Int?
    
    
    // MARK: Initialization
    
    init?(coordinates: CLLocationCoordinate2D, category: String, radius: Int, limit: Int, openAt: Int) {
        self.coordinates = coordinates
        self.category = category
        self.radius = radius
        self.limit = limit
        self.openAt = openAt

    }
    */
}
