//
//  CurrentPlace.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/25/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import GooglePlaces

class CurrentPlace {
    
    // Instantiate a pair of UILabels in Interface Builder
    fileprivate var name: String? = nil
    fileprivate var address: String? = nil
    fileprivate var placesClient: GMSPlacesClient? = nil
    
    // MARK: Initialization
    init() {
        placesClient = GMSPlacesClient.shared()
    }

    func getCurrentPlace(_ completionHandler: @escaping () -> Void) {
        
        placesClient?.currentPlace(callback: {
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: Error?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.name = "No current place"
            self.address = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let firstPlace = placeLikelihoodList.likelihoods.first?.place
                if let place = firstPlace {
                    self.name = place.name
                    self.address = place.formattedAddress!.components(separatedBy: ", ")
                        .joined(separator: ", ")
                }
            }
            completionHandler()
        } )
    }
    
    var currentPlaceName: String? {
        get {
            return name
        }
    }
    
    var currentPlaceAddress: String? {
        get {
            return address
        }
    }

}
