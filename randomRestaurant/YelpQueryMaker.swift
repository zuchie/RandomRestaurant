//
//  YelpQueryMaker.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import UIKit

class YelpQuery {
    
    // Properties.
    private var url: String
    //private var httpRequest: URLRequest!
    private let accessToken = "BYJYCVjjgIOuchrzOPICryariCWPw8OMD9aZqE1BsYTsah8NX1TQbv5O-kVbMWEmQUxFHegLlZPPR5Vi38fUH0MXV74MhDVhzTgSm6PM7e3IA-VE46HkB126lFmJWHYx"
    
    var completion: ((_ results: [[String: Any]]) -> Void)?
    var completionWithError: ((_ error: Error) -> Void)?
    
    private var queryURL: YelpQueryURL!
    
    init(latitude: Double?, longitude: Double?, category: String?, radius: Int?, limit: Int?, openAt: Int?, sortBy: String?) {
        
        queryURL = YelpQueryURL(latitude: latitude, longitude: longitude, category: category, radius: radius, limit: limit, openAt: openAt, sortBy: sortBy)
        url = queryURL.queryString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
    }
    /*
    init?(_ queryString: String) {
        guard let query = queryString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            print("Couldn't make query string from string: \(queryString)")
            return nil
        }
        self.url = query
    }
    */
    // Methods.
    // Get businesses from Yelp API v3.
    func startQuery() {
        print("Start query")
        guard let urlObj = URL(string: url) else {
            fatalError("Couldn't make an URL object from url string: \(url).")
        }
        var request = URLRequest(url: urlObj)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        request.makeRequest { error, data in
            if let err = error {
                self.completionWithError?(err)
                return
            }
            
            guard let dat = data,
                let results = dat.jsonToDictionary() else {
                fatalError("Didn't get expected results.")
            }
            
            guard let businesses = results["businesses"] as? [[String: Any]] else {
                fatalError("Couldn't get businesses from results.")
            }
            
            //print("businesses: \(businesses)")
            self.completion?(businesses)
        }        
    }
    
    /*
    fileprivate func filterByRating() {
        queryResults = [[String: Any]]()
        queryResults = businesses.filter { $0["rating"] as! Float >= (queryParameters?.rating)! }
        print("query rating: \(queryParameters?.rating)")
        //print("filtered: \(queryResults)")
    }
    */
    /*
    fileprivate func sortBusinesses(_ businesses: [[String:AnyObject]]) -> [[String:AnyObject]] {
        return businesses.sorted(by: {$0["rating"] as! Double == $1["rating"] as! Double ?
            $0["review_count"] as! Int > $1["review_count"] as! Int : $0["rating"] as! Double > $1["rating"] as! Double})
    }
    */
}

extension Data {
    // Helper functions.
    public func jsonToDictionary() -> [String: Any]? {
        // Convert server json response to NSDictionary
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: self, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        return json as? [String: Any]
    }
}
