//
//  Location.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 4/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import CoreLocation

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
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            print("Requesting location...")
            locationManager.requestLocation()
        } else {
            let alert = Alert(title: "Location Services not available",
                              message: "Please make sure that your device is connected to the network",
                              actions: [.ok]
            )
            alert.presentAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("authorization not determined")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("authorized when in use")
            locationManager.requestLocation()
        case .denied, .restricted:
            print("authorization denied")
            let alert = Alert(
                title: "Location Access Disabled",
                message: "In order to get your current location, please open Settings and set location access of this App to 'While Using the App'.",
                actions: [.cancel, .openSettings]
            )
            alert.presentAlert()
        default:
            print("Access request error, status: \(status)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        print("Location updating error: \(error.localizedDescription)")
        self.delegate?.updateLocationError(error: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Update location")
        self.delegate?.updateLocation(location: locations.last)
        //print("Location: \(String(describing: locations.last))")
    }
    
}
