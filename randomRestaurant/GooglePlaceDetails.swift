//
//  GooglePlaceDetails.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 11/17/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import GooglePlaces

class GooglePlaceDetails {
    
    private var coordinates: CLLocationCoordinate2D?
    
    func getCoordinates(from placeID: String, completionHandler: @escaping (_ coordinates: CLLocationCoordinate2D) -> Void) {
        let googlePlaceDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?" + "placeid=\(placeID)" + "&key=AIzaSyARb5tLyClE1TXO_Lnj_I2OEuIyk-WI8SA"
        
        let urlObj = URL(string: googlePlaceDetailsUrl)
        var request = URLRequest(url: urlObj!)
        request.httpMethod = "GET"
        request.timeoutInterval = 120
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error while getting Google Place Details URL response: \(error)")
                return
            }
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, AnyObject> {
                    
                    let status = convertedJsonIntoDict["status"] as! String
                    let result = convertedJsonIntoDict["result"] as! [String : AnyObject]
                    
                    if status == "OK" {
                        let geometry = result["geometry"] as! [String : AnyObject]
                        let location = geometry["location"] as! [String : AnyObject]
                        let latitude = location["lat"] as! Double
                        let longitude = location["lng"] as! Double
                        self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        completionHandler(self.coordinates!)
                    } else {
                        print("Google Place Details returned status: \(status)")
                    }
                    
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        })
        task.resume()
    }
}
