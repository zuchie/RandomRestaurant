//
//  LocationManager.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 4/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

//import Foundation
import CoreLocation
import UIKit

// Singleton class
class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    fileprivate var locationManager = CLLocationManager()
    var completion: ((_ location: CLLocation) -> Void)?
    var updateCount = 0
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func requestLocation() {
        print("Requesting location...")
        updateCount = 0
        //locationManager.requestLocation()
        locationManager.startUpdatingLocation()
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
            // Still updating location, propagating corresponding error to locationManger(_:didFailWithError:) method to handle.
            self.requestLocation()
        default:
            print("Access not authorized, status: \(status.rawValue)")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location updating error: \(error.localizedDescription)")
        
        let alert: UIAlertController
        
        switch error._code {
        case CLError.network.rawValue:
            alert = UIAlertController(
                title: "Location Services not available",
                message: "Please make sure that your device is connected to the network",
                actions: [.ok]
            )
        case CLError.denied.rawValue:
            alert = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to get your current location, please open Settings and set location access of this App to 'While Using the App'.",
                actions: [.cancel, .openSettings]
            )
            // Cancel location updating from requestLocation(), otherwise locationUnknown error will follow.
            locationManager.stopUpdatingLocation()
        case CLError.locationUnknown.rawValue:
            alert = UIAlertController(
                title: "Location Unknown",
                message: "Couldn't get location, please try again at a later time.",
                actions: [.ok]
            )
        default:
            alert = UIAlertController(
                title: "Bad location services",
                message: "Location services got issue, please try again at a later time.",
                actions: [.ok]
            )
        }
        
        alert.show()
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Update location...")
        updateCount += 1
        
        // Only report the initial location fix.
        if updateCount == 1 {
            manager.stopUpdatingLocation()
            guard let location = locations.last else {
                fatalError("No locations updated.")
            }
            completion?(location)
        }
    }
    /*
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("did pause location updating")
        updateCount = 0
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("did resume location updating")
        updateCount = 0
    }
    */
}
