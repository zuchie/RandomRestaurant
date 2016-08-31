//
//  GetDirection.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/31/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import GoogleMaps

class GetDirection {
    
    private var googleDirectionUrl: String?
    private var routesPoints = [String]()
    // MARK: Helper functions.
    
    func makeGoogleDirectionsUrl(baseUrl: String, origin: CLLocationCoordinate2D, dest: CLLocationCoordinate2D, key: String) {
        
        googleDirectionUrl = "\(baseUrl)" + "origin=\(origin.latitude),\(origin.longitude)" + "&destination=\(dest.latitude),\(dest.longitude)" + "&key=\(key)"
    }
    
    private func getRoutesPoints(routes: NSArray) {
        for route in routes {
            if let routePoints = route["overview_polyline"] as? NSDictionary {
                if let points = routePoints["points"] as? String {
                    routesPoints.append(points)
                }
            }
        }
    }
    
    func makeUrlRequest(completionHandler: (routesPoints: [String]) -> Void) {
        
        let urlObj = NSURL(string: googleDirectionUrl!)
        let request = NSMutableURLRequest(URL: urlObj!)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 120
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error while getting Google Directions URL response: \(error)")
                return
            }
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    let status = convertedJsonIntoDict["status"] as? String
                    let routes = convertedJsonIntoDict["routes"] as? NSArray
                    
                    if status == "OK" {
                        self.getRoutesPoints(routes!)
                        completionHandler(routesPoints: self.routesPoints)
                    } else {
                        print("Google Directions returned status: \(status)")
                    }
                    
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }

        }
        task.resume()
        
    }
}