//
//  Location.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 4/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    fileprivate let locationManager = CLLocationManager()
    fileprivate var currentLocation: CLLocationCoordinate2D?
    fileprivate var error: Error?
    fileprivate var timer: Timer?
    fileprivate var counter = 0

    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getLocation(closure: (CLLocationCoordinate2D?, Error?) -> Void) {
        if CLLocationManager.locationServicesEnabled() {
            currentLocation = nil
            error = nil
            
            locationManager.requestLocation() // iOS 9 and later
            
            if #available(iOS 10.0, *) {
                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in self.pollingLocation() })
            } else {
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(pollingLocation), userInfo: nil, repeats: true)
            }
            closure(currentLocation, error)
        } else {
            let alert = Alert(title: "Location Services not available",
                          message: "Please make sure that your device is connected to the network",
                          actions: [.ok]
            )
            alert.presentAlert()
        }
        
    }
    
    func pollingLocation() {
        counter += 1
        if self.currentLocation != nil || self.error != nil || counter > 1_000 {
            timer?.invalidate()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            break
        case .denied:
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
        self.error = error
        print("Location updating error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            fatalError("No location's been updated")
        }
        
        currentLocation = location.coordinate
    }
    
}
