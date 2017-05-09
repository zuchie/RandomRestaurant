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

// Singleton class
class LocationManager: NSObject, CLLocationManagerDelegate, AlertProtocol {
    static let shared = LocationManager()
    
    fileprivate var locationManager = CLLocationManager()
    
    // Set to the UIViewController which will present the alerts.
    weak var alertPresentingVC: UIViewController?
    
    var completion: ((_ location: CLLocation) -> Void)?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func requestLocation() {
        print("Requesting location...)")
        
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
        
        guard let vc = alertPresentingVC else {
            fatalError("No View Controller to present alerts.")
        }
        
        vc.present(alert, animated: false)

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Update location...")
        guard let location = locations.last else {
            fatalError("No locations updated.")
        }
        
        completion?(location)
    }
    
}
