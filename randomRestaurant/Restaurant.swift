//
//  Restaurant.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 10/1/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class Restaurant {
    
    var name: String
    var price: String
    var rating: String
    var reviewCount: String
    var address: String
    var isFavorite: Bool
    var date: Int
    var url: String
    var latitude: Double
    var longitude: Double
    var category: String
    var total: Int
    var number: Int
    
    init(name: String, price: String, rating: String, reviewCount: String, address: String, isFavorite: Bool, date: Int, url: String, latitude: Double, longitude: Double, category: String, total: Int, number: Int) {
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
        self.total = total
        self.number = number
    }
    
    // Initializer for Restaurants in History DB.
    convenience init(name: String, price: String, rating: String, reviewCount: String, address: String, isFavorite: Bool, date: Int, url: String, latitude: Double, longitude: Double, category: String) {
        
        self.init(name: name, price: price, rating: rating, reviewCount: reviewCount, address: address, isFavorite: isFavorite, date: date, url: url, latitude: latitude, longitude: longitude, category: category, total: 0, number: 0)
    }
    // Initializer for Restaurants in Favorite DB.
    convenience init(name: String, price: String, rating: String, reviewCount: String, address: String, url: String, latitude: Double, longitude: Double, category: String) {
        
        self.init(name: name, price: price, rating: rating, reviewCount: reviewCount, address: address, isFavorite: false, date: 0, url: url, latitude: latitude, longitude: longitude, category: category)
    }
    
    convenience init() {
        self.init(name: "", price: "", rating: "", reviewCount: "", address: "", url: "", latitude: 0.0, longitude: 0.0, category: "")
    }

}
