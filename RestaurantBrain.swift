//
//  RestaurantBrain.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/1/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class RestaurantBrain {
    
    private var pickedBusiness: NSDictionary? = nil
    private var urlParams = urlParameters()
    private var bizSearchUrl = ""
    private var ratingBar: Float?

    var result: NSDictionary? {
        get {
            //print("picked business: \(self.pickedBusiness)")
            return pickedBusiness
        }
        set {
            pickedBusiness = newValue
        }
    }
    
    private struct urlParameters {
        var term: String?
        var latitude: Double?
        var longitude: Double?
        var limit: Int?
    }
    
    func getUrlParameters(term: String?, latitude: Double?, longitude: Double?, limit: Int?) {
        //urlParams = urlParameters(term: term!, latitude: latitude!, longitude: longitude!, limit: limit!)
        //urlParams = urlParameters()

        if term != nil {
            urlParams.term = term
        }
        if latitude != nil {
            urlParams.latitude = latitude
        }
        if longitude != nil {
            urlParams.longitude = longitude
        }
        if limit != nil {
            urlParams.limit = limit
        }
    }
    
    
    func makeBizSearchUrl(baseUrl: String) {
        bizSearchUrl = baseUrl
        
        if urlParams.term != nil {
            bizSearchUrl += "term=\(urlParams.term!)"
        }
        if urlParams.latitude != nil {
            bizSearchUrl += "&latitude=\(urlParams.latitude!)"
        }
        if urlParams.longitude != nil {
            bizSearchUrl += "&longitude=\(urlParams.longitude!)"
        }
        if urlParams.limit != nil {
            bizSearchUrl += "&limit=\(urlParams.limit!)"
        }
    }
    
    private func sortBusinesses(businesses: NSArray) -> NSArray {
        return businesses.sort({$0["rating"] as! Double == $1["rating"] as! Double ?
            $0["review_count"] as! Int > $1["review_count"] as! Int : $0["rating"] as! Double > $1["rating"] as! Double})
    }
    
    func setRatingBar(rating: Float?) {
        ratingBar = rating
        //print("rating bar: \(ratingBar)")
    }
    
    private func pickRandomBusiness(sortedBusinesses: NSArray) -> NSDictionary? {
        var index = 0
        for business in sortedBusinesses {
            let businessRating = business["rating"] as! Float
            // Pick randomly from biz with rating >= rating bar, if all biz with rating >= rating bar, pick amongst all of them.
            if businessRating < ratingBar || business as! NSObject == sortedBusinesses.lastObject as! NSObject {
                index = sortedBusinesses.indexOfObject(business)
                //print("index: \(index)")
                break
            }
            // TODO: Another way to sort, but not work, why?
            //let indexOfFisrtUnqualifiedBusiness = sortedBusinesses.indexOfObjectPassingTest({ $0["rating"] < 4.5 })
            //print("indexOfFisrtUnqualifiedBusiness: \(indexOfFisrtUnqualifiedBusiness)")
        }
        // Randomly pick one business from all qualified businesses(pick one from element < index). If no qualified biz, return [:]
        if index == 0 {
            return nil
        }
        let randomNumber = Int(arc4random_uniform(UInt32(index)))
        print("total qualified biz: \(index), random no. \(randomNumber)")
        return sortedBusinesses[randomNumber] as? NSDictionary
    }
    
    private func sortAndRandomlyPickBiz(data: NSData?) -> Void {
        // Convert server json response to NSDictionary
        do {
            if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                
                // Print out dictionary
                //print(convertedJsonIntoDict)
                //self.sortAndRandomlyPickBiz(convertedJsonIntoDict)
                
                //let businesses = convertedJsonIntoDict["businesses"]! as! NSArray
                let sortedBusinesses = sortBusinesses(convertedJsonIntoDict["businesses"] as! NSArray)
                //print("sorted biz: \(sortedBusinesses)")
                
                pickedBusiness = pickRandomBusiness(sortedBusinesses)
                //print("picked biz: \(self.pickedBusiness)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }
    
    // Make own completionHandler function.
    typealias completion = (success: Bool) -> Void
    
    func makeUrlRequest(token: String, completionHanlder: completion) {
        
        let urlObj = NSURL(string: bizSearchUrl)
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
                    print("error=\(error)")
                    return
                }
                
                // Print out response string
                //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print("responseString = \(responseString)")
                let cacheResponse = NSCachedURLResponse(response: response!, data: data!)
                NSURLCache.sharedURLCache().storeCachedResponse(cacheResponse, forRequest: request)
                
                self.sortAndRandomlyPickBiz(data)
                print("non-cached response data")
                print("current disk usage: \(NSURLCache.sharedURLCache().currentDiskUsage), mem usage: \(NSURLCache.sharedURLCache().currentMemoryUsage)")
                let flag = true
                completionHanlder(success: flag)
            }
            task.resume()
        } else {
            self.sortAndRandomlyPickBiz(cachedURLResponse?.data)
            print("cached response data")
            print("current disk usage: \(NSURLCache.sharedURLCache().currentDiskUsage), mem usage: \(NSURLCache.sharedURLCache().currentMemoryUsage)")
            let flag = true
            completionHanlder(success: flag)
        }
    }
}
