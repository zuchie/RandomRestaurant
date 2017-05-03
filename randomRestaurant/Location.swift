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
        
        /*
         let alert = UIAlertController(title: "Location Services not available",
         message: "Please make sure that your device is connected to the network",
         actions: [.ok]
         )
         guard let nav = UIApplication.topViewController()?.navigationController else {
         fatalError("No nav controller")
         }
         nav.mainViewController()?.present(alert, animated: false)
         */
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
            print("authorization denied")
            /*
            let alert = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to get your current location, please open Settings and set location access of this App to 'While Using the App'.",
                actions: [.cancel, .openSettings]
            )
            UIApplication.topViewController()?.navigationController?.mainViewController()?.present(alert, animated: false)
            */
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
    }
    
}
/*
extension UINavigationController {
    
    /**
     
     Get Main Table View Controler from the Navigation stack.
     
     - returns:
     Main Table View Controller, or nil.
 
     */
    func mainViewController() -> MainTableViewController? {
        for vc in self.viewControllers {
            print("vc: \(vc)")
            if vc is MainTableViewController {
                print("Found main vc")
                return (vc as! MainTableViewController)
            }
        }
        return nil
    }
}
*/
/*
extension UIApplication {
    /**
     
     Get the top view controller from the view controller hierarchy of a base view controller.
     
     - parameters:
     - controller: The base view controller, root view controller as default.
     
     - returns:
     The top view controller.
     
     */
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let tabController = controller as? UITabBarController {
            return topViewController(controller: tabController.selectedViewController)
        }
        if let navController = controller as? UINavigationController {
            return topViewController(controller: navController.visibleViewController)
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        print("controller: \(String(describing: controller))")
        return controller
    }
}
*/
