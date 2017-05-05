//
//  YelpQuery.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

protocol YelpQueryDelegate {
    func getYelpQueryResults(results: [[String: Any]]?)
}

class YelpQuery: HttpRequestDelegate {
    
    // Properties.
    fileprivate var queryResults: [[String: Any]]? = [[String: Any]]()
    
    fileprivate var url: String
    
    fileprivate var httpRequest: HttpRequest!
    
    fileprivate let access_token = "BYJYCVjjgIOuchrzOPICryariCWPw8OMD9aZqE1BsYTsah8NX1TQbv5O-kVbMWEmQUxFHegLlZPPR5Vi38fUH0MXV74MhDVhzTgSm6PM7e3IA-VE46HkB126lFmJWHYx"
    
    var delegate: YelpQueryDelegate?
    
    init?(queryString: String) {
        guard let query = queryString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            print("Couldn't make query string from string: \(queryString)")
            return nil
        }
        self.url = query
    }
    
    func getHttpRequestAndResults(request: URLRequest?, data: Data?, response: URLResponse?, error: Error?) {
        
        // TODO: Handle errors.
        jsonToDictionary(data)
        
        let cacheResponse = CachedURLResponse(response: response!, data: data!)
        URLCache.shared.storeCachedResponse(cacheResponse, for: request!)

    }
    
    func getCachedResponse(data: Data?, response: URLResponse?) {
        
        // TODO: Handle responses?
        jsonToDictionary(data)
        
        print("Disk usage/capacity: \(URLCache.shared.currentDiskUsage)/\(URLCache.shared.diskCapacity), memory usage/capacity: \(URLCache.shared.currentMemoryUsage)/\(URLCache.shared.memoryCapacity)")
    }
    
    // Methods.
    // Get businesses from Yelp API v3.
    func startQuery() {
        print("Start query")
        httpRequest = HttpRequest(
            url: url,
            httpMethod: "GET",
            httpHeaderValue: "Bearer \(access_token)",
            httpHeaderField: "Authorization",
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 120.0
        )
        httpRequest.delegate = self
        
        httpRequest.makeRequest()
    }
    
    fileprivate func jsonToDictionary(_ data: Data?) {
        print("json to dict")
        // Convert server json response to NSDictionary
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: data!, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        let results: [[String: Any]]?
        if let item = json as? [String: Any],
            let businesses = item["businesses"] as? [[String: Any]] {
            print("got businesses")
            results = businesses
        } else {
            results = nil
        }
        print("Here")
        self.delegate?.getYelpQueryResults(results: results)
        //print("businesses: \(self.businesses), total: \(total)")
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
