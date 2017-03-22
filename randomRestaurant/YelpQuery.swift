//
//  YelpQuery.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

class YelpQuery: NSObject {
    //fileprivate var nearbyBusinesses = GetNearbyBusinesses()
    //fileprivate var restaurant = Restaurant()
    //fileprivate var bizLocationObj: PickedBusinessLocation?
    
    
    // Properties.
    fileprivate var queryResults: [[String: Any]]?
    var results: [[String: Any]]? {
        if queryResults == nil {
            print("No query results")
        }
        return queryResults
    }
    
    fileprivate var queryParameters: YelpUrlQueryParameters?
    var parameters: YelpUrlQueryParameters? {
        get {
            return queryParameters
        }
        set {
            queryParameters = newValue
            if queryParameters == nil {
                print("No query parameters")
            }
        }
    }
    
    dynamic var queryDone: Bool = false
    
    fileprivate let access_token = "BYJYCVjjgIOuchrzOPICryariCWPw8OMD9aZqE1BsYTsah8NX1TQbv5O-kVbMWEmQUxFHegLlZPPR5Vi38fUH0MXV74MhDVhzTgSm6PM7e3IA-VE46HkB126lFmJWHYx"
    
    fileprivate var url = String()
    fileprivate var businesses = [[String: Any]]()

    
    // Methods.
    // Get businesses from Yelp API v3.
    func startQuery() {
        queryDone = false
        // Make query url.
        makeQueryUrl()
        // Make url request.
        makeUrlRequest()
    }
    
    fileprivate func makeQueryUrl() {
        if let param = queryParameters {
            url = "https://api.yelp.com/v3/businesses/search?"
            url += param.latitude.queryString + param.longitude.queryString + param.category.queryString + param.radius.queryString + param.limit.queryString + param.openAt.queryString + "&sort_by=rating"
            
            // Convert string to URL query allowed string to escape spaces.
            url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            print("Yelp query url: \(url)")
        } else {
            print("No query parameters.")
        }
    }

    // Make own completionHandler function.
    //typealias completion = (_ totalBiz: Int, _ randomNo: Int) -> Void
    
    fileprivate func makeUrlRequest() {
        
        let urlObj = URL(string: url)
        var request = URLRequest(url: urlObj!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad
        request.timeoutInterval = 120
        
        let cachedURLResponse = URLCache.shared.cachedResponse(for: request as URLRequest)
        if cachedURLResponse == nil {
            let task = URLSession.shared.dataTask(with: request, completionHandler: {
                data, response, error in
                
                // Check for error
                if error != nil
                {
                    print("error while retrieving URL response: \(error)")
                    return
                }
                
                // Print out response string
                //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print("responseString = \(responseString)")
                
                let cacheResponse = CachedURLResponse(response: response!, data: data!)
                URLCache.shared.storeCachedResponse(cacheResponse, for: request)
                
                print("non-cached response data")
                print("current disk usage: \(URLCache.shared.currentDiskUsage), mem usage: \(URLCache.shared.currentMemoryUsage)")
                //completionHanlder(self.totalSortedBiz, self.randomNo)
                self.jsonToDictionary(data)
                self.filterByRating()
                self.queryDone = true
            })
            task.resume()
        } else {
            //self.sortAndRandomlyPickBiz(cachedURLResponse?.data)
            print("cached response data")
            print("current disk usage: \(URLCache.shared.currentDiskUsage), mem usage: \(URLCache.shared.currentMemoryUsage)")
            //completionHanlder(totalSortedBiz, randomNo)
            self.jsonToDictionary(cachedURLResponse?.data)
            filterByRating()
            self.queryDone = true
        }
    }
    
    fileprivate func jsonToDictionary(_ data: Data?) {
        // Convert server json response to NSDictionary
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: data!, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        guard let item = json as? [String: Any],
            let businesses = item["businesses"] as? [[String: Any]] else {
                fatalError("Unexpected JSON: \(json)")
        }
        self.businesses = businesses
        //print("businesses: \(self.businesses), total: \(total)")
    }
    
    fileprivate func filterByRating() {
        queryResults = [[String: Any]]()
        queryResults = businesses.filter { $0["rating"] as! Float >= (queryParameters?.rating)! }
        print("query rating: \(queryParameters?.rating)")
        //print("filtered: \(queryResults)")
    }
    /*
    fileprivate func sortBusinesses(_ businesses: [[String:AnyObject]]) -> [[String:AnyObject]] {
        return businesses.sorted(by: {$0["rating"] as! Double == $1["rating"] as! Double ?
            $0["review_count"] as! Int > $1["review_count"] as! Int : $0["rating"] as! Double > $1["rating"] as! Double})
    }
    */
}
