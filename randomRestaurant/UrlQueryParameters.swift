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
    var latitude = Parameter(name: "latitude", value: nil)
    var longitude = Parameter(name: "longitude", value: nil)
    var category = Parameter(name: "categories", value: nil)
    var radius = Parameter(name: "radius", value: 10000)
    var limit = Parameter(name: "limit", value: 30)
    var openAt = Parameter(name: "open_at", value: nil)
    
    var rating: Float = 0.0

    struct Parameter {
        var name: String
        var value: Any?
        var queryString: String {
            // Make a url query format string: "&name=value" or, "" if value == nil.
            if let myValue = value {
                return "&\(name)=\(myValue)".lowercased()
            } else {
                return ""
            }
        }
    }
}
