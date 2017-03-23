//
//  YelpUrlQueryParameters.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/27/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class YelpUrlQueryParameters {
    
    // MARK: Properties
    
    var latitude: Double?
    var longitude: Double?
    var category: String?
    var radius: Int?
    var limit: Int?
    var openAt: Double?
    var sortBy: String?
    
    var queryString: String {
        return buildQueryString()
    }
    
    init(latitude: Double?, longitude: Double?, category: String?, radius: Int?, limit: Int?, openAt: Double?, sortBy: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.radius = radius
        self.limit = limit
        self.openAt = openAt
        self.sortBy = sortBy
    }
    
    // Compose legit Yelp Url query string
    private func buildQueryString() -> String {
        let parameters: [(Any?, String)] = [(latitude, "latitude"),  (longitude, "longitude"), (category, "categories"), (radius, "radius"), (limit, "limit"), (openAt, "open_at"), (sortBy, "sort_by")]
        
        func formatParameter(parameter: (Any?, String)) -> String {
            var param = parameter
            guard let value = param.0 else {
                // If no category specified, cover all restaurants
                if param.1 == "categories" {
                    return "restaurants"
                }
                return ""
            }
            // Use Yelp required strings for special cases
            if param.1 == "American" {
                param.1 = "newamerican,tradamerican"
            }
            if param.1 == "Indian" {
                param.1 = "indpak"
            }
            
            return "&\(param.1)=\(value)".lowercased()
        }
        
        return parameters.map(formatParameter).reduce("https://api.yelp.com/v3/businesses/search?", {$0 + $1})
    }
    
}
