//
//  Alert.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 4/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

//import Foundation
import UIKit

protocol AlertProtocol {
    // Alerts can't be presented by themselves, must have a UIViewController to present them.
    weak var alertPresentingVC: UIViewController? { get set }
}

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
            case .ok:
                alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            case .cancel:
                alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            case .openSettings:
                alertAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        DispatchQueue.main.async {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            }
            self.addAction(alertAction)
        }
    }
}
