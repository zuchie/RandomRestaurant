//
//  Location.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 4/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

protocol LocationManagerDelegate {
    func updateLocation(location: CLLocation?)
    func updateLocationError(error: Error?)
}

// Singleton class
class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    fileprivate var locationManager = CLLocationManager()
    var delegate: LocationManagerDelegate?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func requestLocation() {
        print("Requesting location...")
        locationManager.requestLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop updating location.")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("authorization not determined")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("authorized when in use")
            self.requestLocation()
        case .denied, .restricted:
            print("authorization denied or restricted")
            // Still updating location, propagating corresponding error to delegate method.
            self.requestLocation()
        default:
            print("Access not authorized, status: \(status.rawValue)")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        print("Location updating error: \(error.localizedDescription)")
        self.delegate?.updateLocationError(error: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Update location")
        self.delegate?.updateLocation(location: locations.last)
    }
    
}
