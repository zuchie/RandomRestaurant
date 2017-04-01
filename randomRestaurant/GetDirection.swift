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
    
    // MARK: Properties.
    
    fileprivate var googleDirectionUrl: String?
    fileprivate var routesPoints = [String]()
    fileprivate var distances = [String]()
    fileprivate var durationInTraffic = ""
    struct Bounds {
        var northeast: CLLocationCoordinate2D?
        var southwest: CLLocationCoordinate2D?
    }
    
    fileprivate var viewport = Bounds()
    
    // MARK: Helper functions.
    
    func makeGoogleDirectionsUrl(_ baseUrl: String, origin: CLLocationCoordinate2D, dest: CLLocationCoordinate2D, depart: Int, key: String) {
        
        googleDirectionUrl = "\(baseUrl)" + "origin=\(origin.latitude),\(origin.longitude)" + "&destination=\(dest.latitude),\(dest.longitude)" + "&departure_time=\(depart)" + "&key=\(key)"
    }
    
    fileprivate func getRoutesPoints(_ routes: [Dictionary<String, AnyObject>]) {
        for route in routes {
            if let routePoints = route["overview_polyline"] as? Dictionary<String, AnyObject> {
                if let points = routePoints["points"] as? String {
                    routesPoints.append(points)
                }
            }
        }
    }
    
    fileprivate func getDistancesAndDurations(_ routes: [Dictionary<String, AnyObject>]) {
        for route in routes {
            if let legs = route["legs"] as? [Dictionary<String, AnyObject>] {
                for leg in legs {
                    if let distance = leg["distance"] as? Dictionary<String, AnyObject> {
                        distances.append(distance["text"] as! String)
                    }
                    // duration_in_traffic only exists in single leg.
                    if let durationInTraffic = leg["duration_in_traffic"] as? Dictionary<String, AnyObject> {
                        self.durationInTraffic = durationInTraffic["text"] as! String
                    }

                }
            }
        }
    }
    
    fileprivate func getViewport(_ routes: [Dictionary<String, AnyObject>]) {
        for route in routes {
            if let bounds = route["bounds"] as? Dictionary<String, AnyObject> {
                if let northeast = bounds["northeast"] as? Dictionary<String, AnyObject>,
                    let southwest = bounds["southwest"] as? Dictionary<String, AnyObject> {
                        viewport.northeast = CLLocationCoordinate2DMake(northeast["lat"] as! CLLocationDegrees, northeast["lng"] as! CLLocationDegrees)
                        viewport.southwest = CLLocationCoordinate2DMake(southwest["lat"] as! CLLocationDegrees, southwest["lng"] as! CLLocationDegrees)
                }
            }
        }
    }
    
    func makeUrlRequest(_ completionHandler: @escaping (_ routesPoints: [String], _ distances: [String], _ durationInTraffic: String, _ viewport: Bounds) -> Void) {
        
        let urlObj = URL(string: googleDirectionUrl!)
        var request = URLRequest(url: urlObj!)
        request.httpMethod = "GET"
        request.timeoutInterval = 120
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error while getting Google Directions URL response: \(String(describing: error))")
                return
            }
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, AnyObject> {
                    
                    let status = convertedJsonIntoDict["status"] as? String
                    let routes = convertedJsonIntoDict["routes"] as? [Dictionary<String, AnyObject>]
                    
                    if status == "OK" {
                        self.getRoutesPoints(routes!)
                        self.getDistancesAndDurations(routes!)
                        self.getViewport(routes!)
                        completionHandler(self.routesPoints, self.distances, self.durationInTraffic, self.viewport)
                    } else {
                        print("Google Directions returned status: \(String(describing: status))")
                    }
                    
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }

        }) 
        task.resume()
        
    }
}
