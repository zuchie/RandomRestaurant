//
//  Alert.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 4/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import UIKit


class Alert: UIViewController {
    var controller: UIAlertController
    
    enum Actions {
        case ok, cancel, openSettings
    }
    
    init(title: String, message: String, actions: [Actions]) {
        controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        super.init(nibName: nil, bundle: nil)
        
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentAlert() {
        UIApplication.topViewController()?.present(controller, animated: false, completion: nil)
    }
}

extension UIApplication {
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
