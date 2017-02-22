//
//  HereAndNow.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/22/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class HereAndNow: UIViewController, CLLocationManagerDelegate {
    fileprivate let locationManager = CLLocationManager()
    
    dynamic var coordinate = CLLocationCoordinate2D()
    
    fileprivate var now = Date().timeIntervalSince1970
    var date: Double {
        return now
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
    }
    
    // Asking for access of user's location.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            // Asking users to enable location access from Settings.
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to get your current location, please open Settings and set location access of this App to 'While Using the App'.",
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { action in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true, completion: nil)
        default:
            print("Access request error")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.first! as CLLocation
        
        manager.stopUpdatingLocation()
        
        coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
    }
    
}
