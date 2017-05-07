//
//  YelpQuery.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

/*
protocol YelpQueryDelegate {
    func getYelpQueryResults(results: [[String: Any]]?)
}
*/

class YelpQuery: HttpRequestResults {
    
    // Properties.
    //fileprivate var queryResults: [[String: Any]]? = [[String: Any]]()
    
    var businesses: (([[String: Any]]?) -> Void)?
    
    fileprivate var url: String
    
    fileprivate var httpRequest: HttpRequest!
    
    fileprivate let accessToken = "BYJYCVjjgIOuchrzOPICryariCWPw8OMD9aZqE1BsYTsah8NX1TQbv5O-kVbMWEmQUxFHegLlZPPR5Vi38fUH0MXV74MhDVhzTgSm6PM7e3IA-VE46HkB126lFmJWHYx"
    
    //var delegate: YelpQueryDelegate?
    
    init?(queryString: String) {
        guard let query = queryString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            print("Couldn't make query string from string: \(queryString)")
            return nil
        }
        self.url = query
    }
        
    // Methods.
    // Get businesses from Yelp API v3.
    func startQuery() {
        print("Start query")
        httpRequest = HttpRequest(
            url: url,
            httpMethod: "GET",
            httpHeaderValue: "Bearer \(accessToken)",
            httpHeaderField: "Authorization",
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 120.0
        )
        httpRequest.delegate = self
        
        httpRequest.makeRequest()
    }
    /*
    func getBusinesses() {
        businesses?(results["businesses"] as? [[String: Any]])
        
    }
    */
    
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
