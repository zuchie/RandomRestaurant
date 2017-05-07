//
//  HttpRequestResults.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 5/6/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

class HttpRequestResults: HttpRequestDelegate {
    
    var completion: ((_ results: [String: Any]?) -> Void)?
    fileprivate var results: [String: Any]? {
        didSet {
            completion?(results)
        }
    }
    
    // Delegate methods.
    func getHttpRequestAndResults(request: URLRequest?, data: Data?, response: URLResponse?, error: Error?) {
        
        // TODO: Handle errors.
        jsonToDictionary(data!)
        
        let cacheResponse = CachedURLResponse(response: response!, data: data!)
        URLCache.shared.storeCachedResponse(cacheResponse, for: request!)
        
    }
    
    func getCachedResponse(data: Data?, response: URLResponse?) {
        
        // TODO: Handle responses?
        jsonToDictionary(data!)
        
        print("Disk usage/capacity: \(URLCache.shared.currentDiskUsage)/\(URLCache.shared.diskCapacity), memory usage/capacity: \(URLCache.shared.currentMemoryUsage)/\(URLCache.shared.memoryCapacity)")
    }

    // Helper functions.
    fileprivate func jsonToDictionary(_ data: Data) {
        print("json to dict")
        // Convert server json response to NSDictionary
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        results = json as? [String: Any]
        
        //self.delegate?.getYelpQueryResults(results: results)
        //print("businesses: \(self.businesses), total: \(total)")
    }

}
