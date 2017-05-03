//
//  Alert.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 4/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

//import Foundation
import UIKit

/*
class Alert {
    var controller: UIAlertController
    
    enum Actions {
        case ok, cancel, openSettings
    }
    
    init(title: String, message: String, actions: [Actions]) {
        controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var alertAction: UIAlertAction
        for action in actions {
            switch action {
            case .ok: alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            case .cancel: alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            case .openSettings: alertAction = UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                })
            }
            controller.addAction(alertAction)
        }
    }

    func presentAlert() {
        print("Present alert")
        guard let topViewController = UIApplication.topViewController() else {
            fatalError("No existing view controllers.")
        }
        
        print("Top view controller: \(topViewController)")
        if topViewController is MainTableViewController {
            topViewController.present(controller, animated: false, completion: nil)
        }
        
    }
}
*/

extension UIAlertController {
    enum Actions {
        case ok, cancel, openSettings
    }

    /**
        
     Make an Alert instance, and add actions to it.
     
     - parameters:
        - title: The title of the alert.
        - message: The details of the alert.
        - actions: The actions users can take.
     
     */
    convenience init(title: String, message: String, actions: [Actions]) {
        self.init(title: title, message: message, preferredStyle: .alert)
        
        var alertAction: UIAlertAction
        for action in actions {
            switch action {
            case .ok: alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            case .cancel: alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            case .openSettings: alertAction = UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                })
            }
            self.addAction(alertAction)
        }
    }
}
