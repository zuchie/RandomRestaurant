//
//  Alert.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 4/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import UIKit


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
        UIApplication.topViewController()?.present(controller, animated: false, completion: nil)
    }
}

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
        return controller
    }
}
