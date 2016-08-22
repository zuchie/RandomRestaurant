//
//  LocationsBrain.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/21/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class LocationsBrain {
    
    private var locations: [String]? = nil
    
    var allLoadedLocations: [String]? {
        get {
            return locations
        }
    }
    
    func loadLocations() {
        let filePath = NSBundle.mainBundle().pathForResource("gazetteer", ofType: "txt")
        if let path = filePath {
            do {
                if let locationsString: String = try String(contentsOfFile: path, encoding: NSMacOSRomanStringEncoding/*NSUTF8StringEncoding*/) {
                    locations = locationsString.componentsSeparatedByString("\n")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("file not found")
        }
    }
}
