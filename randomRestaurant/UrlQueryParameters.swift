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
    var openAt: Int?
    var sortBy: String?
    
    fileprivate var queryStr = ""
    var queryString: String {
        return queryStr
    }
    
    init(latitude: Double?, longitude: Double?, category: String?, radius: Int?, limit: Int?, openAt: Int?, sortBy: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.radius = radius
        self.limit = limit
        self.openAt = openAt
        self.sortBy = sortBy
        
        queryStr = buildQueryString()
    }
    
}

extension YelpUrlQueryParameters {
    // Compose legit Yelp Url query string
    fileprivate func buildQueryString() -> String {
        let parameters: [(Any?, String)] = [(latitude, "latitude"),  (longitude, "longitude"), (category, "categories"), (radius, "radius"), (limit, "limit"), (openAt, "open_at"), (sortBy, "sort_by")]
        
        func formatParameter(parameter: (Any?, String)) -> String {
            let param = parameter
            guard var value = param.0 else {
                // If no category specified, cover all restaurants
                if param.1 == "categories" {
                    return "&categories=restaurants"
                }
                return ""
            }
            // Use Yelp required strings for special cases
            if value as? String == "American" {
                value = "newamerican,tradamerican"
            }
            if value as? String == "Indian" {
                value = "indpak"
            }
            
            return "&\(param.1)=\(value)".lowercased()
        }
        
        return parameters.map(formatParameter).reduce("https://api.yelp.com/v3/businesses/search?", {$0 + $1})
    }
    
}
