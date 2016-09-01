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
    
    private var googleDirectionUrl: String?
    private var routesPoints = [String]()
    private var distances = [String]()
    private var durationInTraffic = ""
    struct Bounds {
        var northeast: CLLocationCoordinate2D?
        var southwest: CLLocationCoordinate2D?
    }
    
    private var viewport = Bounds()
    
    // MARK: Helper functions.
    
    func makeGoogleDirectionsUrl(baseUrl: String, origin: CLLocationCoordinate2D, dest: CLLocationCoordinate2D, depart: Int, key: String) {
        
        googleDirectionUrl = "\(baseUrl)" + "origin=\(origin.latitude),\(origin.longitude)" + "&destination=\(dest.latitude),\(dest.longitude)" + "&departure_time=\(depart)" + "&key=\(key)"
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
    
    private func getDistancesAndDurations(routes: NSArray) {
        for route in routes {
            if let legs = route["legs"] as? NSArray {
                for leg in legs {
                    if let distance = leg["distance"] as? NSDictionary {
                        distances.append(distance["text"] as! String)
                    }
                    // duration_in_traffic only exists in single leg.
                    if let durationInTraffic = leg["duration_in_traffic"] as? NSDictionary {
                        self.durationInTraffic = durationInTraffic["text"] as! String
                    }

                }
            }
        }
    }
    
    private func getViewport(routes: NSArray) {
        for route in routes {
            if let bounds = route["bounds"] as? NSDictionary {
                if let northeast = bounds["northeast"] as? NSDictionary,
                    southwest = bounds["southwest"] as? NSDictionary {
                        viewport.northeast = CLLocationCoordinate2DMake(northeast["lat"] as! CLLocationDegrees, northeast["lng"] as! CLLocationDegrees)
                        viewport.southwest = CLLocationCoordinate2DMake(southwest["lat"] as! CLLocationDegrees, southwest["lng"] as! CLLocationDegrees)
                }
            }
        }
    }
    
    func makeUrlRequest(completionHandler: (routesPoints: [String], distances: [String], durationInTraffic: String, viewport: Bounds) -> Void) {
        
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
                        self.getDistancesAndDurations(routes!)
                        self.getViewport(routes!)
                        completionHandler(routesPoints: self.routesPoints, distances: self.distances, durationInTraffic: self.durationInTraffic, viewport: self.viewport)
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