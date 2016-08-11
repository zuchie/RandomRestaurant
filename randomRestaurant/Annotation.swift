//
//  Annotation.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import MapKit
import AddressBook

class BizAnnotation: NSObject, MKAnnotation {
    var title: String? = nil
    let locationName: String
    //let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, /*discipline: String, */coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        //self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}