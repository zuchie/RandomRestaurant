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
    private var name: String? = nil
    private var address: String? = nil
    private var placesClient: GMSPlacesClient? = nil
    
    // MARK: Initialization
    init() {
        placesClient = GMSPlacesClient.sharedClient()
    }

    func getCurrentPlace(completionHandler: () -> Void) {
        
        placesClient?.currentPlaceWithCallback({
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.name = "No current place"
            self.address = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.name = place.name
                    self.address = place.formattedAddress!.componentsSeparatedByString(", ")
                        .joinWithSeparator(", ")
                }
            }
            completionHandler()
        })
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