//
//  GetNearbyBusinesses.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/21/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class GetNearbyBusinesses {
    
    // MARK: Properties
    private var location: String?
    private var avgRating = 0.0
    
    var rating: Double {
        get {
            //print("average rating: \(avgRating)")
            return avgRating
        }
    }
    var category: String {
        get {
            return urlParams.categories ?? "No food category found"
        }
    }
    
    var place: String? {

        didSet {
            if let loc = place {
                print("search businesses near: \(loc)")
                location = loc
            } else {
                print("No place has been input")
            }
        }
    }
    private var urlParams = UrlParameters()
    private var businessesSearchUrl = String()
    
    private struct UrlParameters {
        var location: String?
        var categories: String?
        var radius: Int?
        var limit: Int?
        var open_at: Int?
    }
    /*
    private enum OperationTypes {
        case GetStrByKey((NSDictionary, String) -> String)
        case GetIntByKey((NSDictionary, String) -> String)
        case GetDoubleByKey((NSDictionary, String) -> String)
    }
    */
    /*
    // Get value by key and convert value into string or empty string if key doesn't exist.
    private var operations: [String: OperationTypes] = [
        "name": OperationTypes.GetStrByKey {
            let val = $0[$1] as? String
            return val ?? ""
        },
        "price": OperationTypes.GetStrByKey {
            let val = $0[$1] as? String
            return val ?? ""
        },
        "rating": OperationTypes.GetDoubleByKey {
            if let val = $0[$1] as? Double {
                return String(val)
            } else {
                return ""
            }
        },
        "review_count": OperationTypes.GetIntByKey {
            if let val = $0[$1] as? Int {
                return String(val)
            } else {
                return ""
            }
        }
    ]
    */
    /*
    func performOperations(dic: NSDictionary, key: String) -> String {
        var bizParam = ""
        if let op = operations[key] {
            switch op {
            case .GetStrByKey(let function):
                bizParam = function(dic, key)
            case .GetDoubleByKey(let function):
                bizParam = function(dic, key)
            case .GetIntByKey(let function):
                bizParam = function(dic, key)
            }
        }
        return bizParam
    }
    */
    
    // MARK: Helper functions
    func getUrlParameters(location: String?, categories: String?, radius: Int?, limit: Int?, open_at: Int?) {
        
        if location != nil {
            urlParams.location = location
        }
        if categories != nil {
            urlParams.categories = categories
        }
        if radius != nil {
            urlParams.radius = radius
        }
        if limit != nil {
            urlParams.limit = limit
        }
        if open_at != nil {
            urlParams.open_at = open_at
        }
    }
    
    
    func makeBusinessesSearchUrl(baseUrl: String) {
        businessesSearchUrl = baseUrl
        
        businessesSearchUrl += urlParams.location != nil ? "location=\(urlParams.location!)" : ""
        businessesSearchUrl += urlParams.categories != nil ? "&categories=\(urlParams.categories!)" : ""
        businessesSearchUrl += urlParams.radius != nil ? "&radius=\(urlParams.radius!)" : ""
        businessesSearchUrl += urlParams.limit != nil ? "&limit=\(urlParams.limit!)" : ""
        businessesSearchUrl += urlParams.open_at != nil ? "&open_at=\(urlParams.open_at!)" : ""
        // Convert string to URL query allowed string to escape spaces.
        businessesSearchUrl = businessesSearchUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }

    private func getAvgRating(data: NSData?) -> Void {
        // Convert server json response to NSDictionary
        do {
            if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                
                // Print out dictionary
                //print(convertedJsonIntoDict)
                //self.sortAndRandomlyPickBiz(convertedJsonIntoDict)
                var ratingSum = 0.0
                let businesses = convertedJsonIntoDict["businesses"]! as! NSArray
                for business in businesses.enumerate() {
                    let biz = business.element as! NSDictionary
                    ratingSum += biz["rating"] as! Double
                }
                avgRating = ratingSum / Double(businesses.count)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

    
    // Make own completionHandler function.
    typealias completion = () -> Void
    
    func makeUrlRequest(token: String, completionHanlder: completion) {
        
        let urlObj = NSURL(string: businessesSearchUrl)
        let request = NSMutableURLRequest(URL: urlObj!)
        request.HTTPMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.cachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        request.timeoutInterval = 120
        
        let cachedURLResponse = NSURLCache.sharedURLCache().cachedResponseForRequest(request)
        if cachedURLResponse == nil {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
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
                let cacheResponse = NSCachedURLResponse(response: response!, data: data!)
                NSURLCache.sharedURLCache().storeCachedResponse(cacheResponse, forRequest: request)
                
                self.getAvgRating(data)
                print("non-cached response data")
                print("current disk usage: \(NSURLCache.sharedURLCache().currentDiskUsage), mem usage: \(NSURLCache.sharedURLCache().currentMemoryUsage)")
                completionHanlder()
            }
            task.resume()
        } else {
            self.getAvgRating(cachedURLResponse?.data)
            print("cached response data")
            print("current disk usage: \(NSURLCache.sharedURLCache().currentDiskUsage), mem usage: \(NSURLCache.sharedURLCache().currentMemoryUsage)")
            completionHanlder()
        }
    }

    
}
