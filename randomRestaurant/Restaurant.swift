//
//  Restaurant.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 10/1/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class Restaurant {
    
    var name: String?
    var price: String?
    var rating: String?
    var reviewCount: String?
    var address: String?
    var isFavorite: Bool?
    var date: Int?
    var url: String?
    var latitude: Double?
    var longitude: Double?
    var category: String?
    
    init?(name: String, price: String, rating: String, reviewCount: String, address: String, isFavorite: Bool, date: Int, url: String, latitude: Double, longitude: Double, category: String) {
        self.name = name
        self.price = price
        self.rating = rating
        self.reviewCount = reviewCount
        self.address = address
        self.isFavorite = isFavorite
        self.date = date
        self.url = url
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
    }
    
    init?() {
        
    }
}
