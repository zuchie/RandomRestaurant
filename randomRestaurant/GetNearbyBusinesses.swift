//
//  GetNearbyBusinesses.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/21/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import CoreLocation

class GetNearbyBusinesses {
    
    // MARK: Properties

    fileprivate var urlParams = UrlParameters()
    fileprivate var businessesSearchUrl = String()
    
    fileprivate struct UrlParameters {
        var coordinates: CLLocationCoordinate2D?
        var categories: String?
        var radius: Int?
        var limit: Int?
        var open_at: Int?
    }
    
    fileprivate var pickedBusiness: [String:AnyObject]? = nil
    fileprivate var ratingBar: Double?
    fileprivate var totalSortedBiz = 0
    fileprivate var randomNo = 0

    var result: [String:AnyObject]? {
        get {
            //print("picked business: \(self.pickedBusiness)")
            return pickedBusiness
        }
        set {
            pickedBusiness = newValue
        }
    }
    
    func setRatingBar(_ ratingBar: Double) {
        self.ratingBar = ratingBar
    }
    
    fileprivate enum OperationTypes {
        case getStrByKey(([String:AnyObject], String) -> String)
        case getIntByKey(([String:AnyObject], String) -> String)
        case getDoubleByKey(([String:AnyObject], String) -> String)
    }

    // Get value by key and convert value into string or empty string if key doesn't exist.
    fileprivate var operations: [String : OperationTypes] = [
        "name": OperationTypes.getStrByKey {
            let val = $0[$1] as? String
            return val ?? ""
        },
        "price": OperationTypes.getStrByKey {
            let val = $0[$1] as? String
            return val ?? ""
        },
        "rating": OperationTypes.getDoubleByKey {
            if let val = $0[$1] as? Double {
                return String(val)
            } else {
                return ""
            }
        },
        "review_count": OperationTypes.getIntByKey {
            if let val = $0[$1] as? Int {
                return String(val)
            } else {
                return ""
            }
        },
        "image_url": OperationTypes.getStrByKey {
            let val = $0[$1] as? String
            return val ?? ""
        },
        "url": OperationTypes.getStrByKey {
            let val = $0[$1] as? String
            return val ?? ""
        }
    ]

    func getReturnedBusiness(_ dic: [String:AnyObject], key: String) -> String {
        var bizParam = ""
        if let op = operations[key] {
            switch op {
            case .getStrByKey(let function):
                bizParam = function(dic, key)
            case .getDoubleByKey(let function):
                bizParam = function(dic, key)
            case .getIntByKey(let function):
                bizParam = function(dic, key)
            }
        }
        return bizParam
    }
    
    // MARK: Helper functions
    func getUrlParameters(_ coordinates: CLLocationCoordinate2D?, categories: String?, radius: Int?, limit: Int?, open_at: Int?) {
        
        if coordinates != nil {
            urlParams.coordinates = coordinates
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
    
    
    func makeBusinessesSearchUrl(_ baseUrl: String) {
        businessesSearchUrl = baseUrl
        
        businessesSearchUrl += urlParams.coordinates?.latitude != nil ? "&latitude=\(urlParams.coordinates!.latitude)" : ""
        businessesSearchUrl += urlParams.coordinates?.longitude != nil ? "&longitude=\(urlParams.coordinates!.longitude)" : ""
        businessesSearchUrl += urlParams.categories != nil ? "&categories=\(urlParams.categories!)" : ""
        businessesSearchUrl += urlParams.radius != nil ? "&radius=\(urlParams.radius!)" : ""
        businessesSearchUrl += urlParams.limit != nil ? "&limit=\(urlParams.limit!)" : ""
        businessesSearchUrl += urlParams.open_at != nil ? "&open_at=\(urlParams.open_at!)" : ""
        // Convert string to URL query allowed string to escape spaces.
        businessesSearchUrl = businessesSearchUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        print("***business search url: \(businessesSearchUrl)")
    }
    
    // Make own completionHandler function.
    typealias completion = (_ totalBiz: Int, _ randomNo: Int) -> Void
    
    func makeUrlRequest(_ token: String, completionHanlder: @escaping completion) {
        
        let urlObj = URL(string: businessesSearchUrl)
        var request = URLRequest(url: urlObj!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
                
                self.sortAndRandomlyPickBiz(data)
                print("non-cached response data")
                print("current disk usage: \(URLCache.shared.currentDiskUsage), mem usage: \(URLCache.shared.currentMemoryUsage)")
                completionHanlder(self.totalSortedBiz, self.randomNo)
            }) 
            task.resume()
        } else {
            self.sortAndRandomlyPickBiz(cachedURLResponse?.data)
            print("cached response data")
            print("current disk usage: \(URLCache.shared.currentDiskUsage), mem usage: \(URLCache.shared.currentMemoryUsage)")
            completionHanlder(totalSortedBiz, randomNo)
        }
    }

    fileprivate func pickRandomBusiness(_ sortedBusinesses: [Dictionary<String, AnyObject>]) -> Dictionary<String, AnyObject>? {
        var indx = 0
        for (index, business) in sortedBusinesses.enumerated() {
            let businessRating = business["rating"] as! Double
            // Pick randomly from biz with rating >= rating bar, if all biz with rating >= rating bar, pick amongst all of them.
            print("===biz rating: \(businessRating), bar: \(ratingBar)")
            if businessRating < ratingBar! || index == sortedBusinesses.count - 1 {
                //print("index: \(index)")
                indx = index
                break
            }
            // TODO: Another way to sort, but not work, why?
            //let indexOfFisrtUnqualifiedBusiness = sortedBusinesses.indexOfObjectPassingTest({ $0["rating"] < 4.5 })
            //print("indexOfFisrtUnqualifiedBusiness: \(indexOfFisrtUnqualifiedBusiness)")
        }
        // Randomly pick one business from all qualified businesses(pick one from element < index). If no qualified biz, return nil.
        if indx == 0 {
            return nil
        }
        let randomNumber = Int(arc4random_uniform(UInt32(indx)))
        totalSortedBiz = indx
        randomNo = randomNumber
        print("total qualified biz: \(totalSortedBiz), random no. \(randomNo)")
        return sortedBusinesses[randomNumber]
    }
    
    fileprivate func sortAndRandomlyPickBiz(_ data: Data?) -> Void {
        // Convert server json response to NSDictionary
        do {
            if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, AnyObject> {
                
                // Print out dictionary
                //print("json: \(convertedJsonIntoDict)")
                //print(convertedJsonIntoDict)
                //self.sortAndRandomlyPickBiz(convertedJsonIntoDict)
                
                //let businesses = convertedJsonIntoDict["businesses"]! as! NSArray
                let sortedBusinesses = sortBusinesses(convertedJsonIntoDict["businesses"] as! [[String:AnyObject]])
                //print("sorted biz: \(sortedBusinesses)")
                
                pickedBusiness = pickRandomBusiness(sortedBusinesses)
                //print("picked biz: \(self.pickedBusiness)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

    fileprivate func sortBusinesses(_ businesses: [[String:AnyObject]]) -> [[String:AnyObject]] {
        return businesses.sorted(by: {$0["rating"] as! Double == $1["rating"] as! Double ?
            $0["review_count"] as! Int > $1["review_count"] as! Int : $0["rating"] as! Double > $1["rating"] as! Double})
    }

    
}
