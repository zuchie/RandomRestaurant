//
//  MapBrain.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import MapKit

class MapBrain: NSObject, MKMapViewDelegate {
    
    private var myLocation = CLLocationCoordinate2D()
    private var bizLocation = CLLocationCoordinate2D()
    private var myRegion = MKCoordinateRegion()
    private var bizCenter = CLLocationCoordinate2D()
    
    func setMyLocationBrain(myLoc: CLLocationCoordinate2D) {
        myLocation = myLoc
    }
    func setBizLocationBrain(bizLoc: CLLocationCoordinate2D) {
        bizLocation = bizLoc
    }
    
    var region: MKCoordinateRegion {
        get {
            return myRegion
        }
        set {
            myRegion = newValue
        }
    }
    
    var center: CLLocationCoordinate2D {
        get {
            return bizCenter
        }
        set {
            bizCenter = newValue
        }
    }
    
    private var locations: Dictionary<String, LocationTypes> = [
        "my" : LocationTypes.my {
                let center = CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                return MKCoordinateRegion(center: center, span: span)
            },
        "biz" : LocationTypes.biz {
                return CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }
    ]
    
    /*
    private var locInfo: LocationInfo?
    
    private struct LocationInfo {
        private var getLocation: (CLLocationCoordinate2D) -> MKCoordinateRegion
        private var myLoc: CLLocationCoordinate2D
    }
    */
    private enum LocationTypes {
        case my((CLLocationCoordinate2D) -> MKCoordinateRegion)
        case biz((CLLocationCoordinate2D) -> CLLocationCoordinate2D)
    }
 
    func drawLocation(location: String) {
        if let location = locations[location] {
            switch location {
            case .my(let function):
                region = function(myLocation)
                /*
                locInfo = LocationInfo(getLocation: function, myLoc: myLocation)
                region = (locInfo?.getLocation(locInfo!.myLoc))!
                */
            case .biz(let function):
                center = function(bizLocation)
            }
        }
    }
}
