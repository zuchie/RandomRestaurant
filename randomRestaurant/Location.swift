//
//  Location.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 4/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationControllerDelegate {
    func updateLocation(location: CLLocation?)
    func updateLocationError(error: Error?)
}

// Singleton class
class LocationController: NSObject, CLLocationManagerDelegate {
    static let sharedLocationManager = LocationController()
    
    fileprivate var locationManager = CLLocationManager()
    var delegate: LocationControllerDelegate?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
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
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied, .restricted:
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

        self.delegate?.updateLocationError(error: error)
        print("Location updating error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.delegate?.updateLocation(location: locations.last)
        //print("Location: \(String(describing: locations.last))")
    }
    
}
