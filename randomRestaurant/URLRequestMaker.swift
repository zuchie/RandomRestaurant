//
//  URLRequestMaker.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 5/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import UIKit

extension URLRequest {
    
    // Properties.
    /*
    private var url: String
    private var httpMethod: String
    private struct HttpHeader {
        var value: String
        var field: String
    }
    private var httpHeader: HttpHeader
    private var cachePolicy: NSURLRequest.CachePolicy
    private var timeoutInterval: Double
    */
    /*
    private var results: [String: Any]?
    
    var completion: ((_ results: [String: Any]?) -> Void)?
    
    init(url: String, httpMethod: String, httpHeaderValue: String, httpHeaderField: String, cachePolicy: NSURLRequest.CachePolicy, timeoutInterval: Double) {
        
        self.url = url
        self.httpMethod = httpMethod
        self.httpHeader = HttpHeader(value: httpHeaderValue, field: httpHeaderField)
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }
    */
    // Methods.
    public func makeRequest(completion: @escaping (_ data: Data) -> Void) {
        /*
        guard let urlObj = URL(string: url) else {
            fatalError("Couldn't make an URL object from url string: \(url).")
        }
        var request = URLRequest(url: urlObj)
        request.httpMethod = httpMethod
        request.addValue(httpHeader.value, forHTTPHeaderField: httpHeader.field)
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        */
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: self) {
            print("Cached response.")
            print("Disk usage/capacity: \(URLCache.shared.currentDiskUsage)/\(URLCache.shared.diskCapacity), memory usage/capacity: \(URLCache.shared.currentMemoryUsage)/\(URLCache.shared.memoryCapacity)")

            //results = jsonToDictionary(cachedResponse.data)
            completion(cachedResponse.data)
            
        } else {
            print("Fresh response.")
            let task = URLSession.shared.dataTask(with: self) { data, response, error in
                
                if let err = error {
                    let alert = UIAlertController(
                        title: "Error: \(err.localizedDescription)",
                        message: "Oops, looks like the server is not available now, please try again at a later time.",
                        actions: [.ok]
                    )
                    alert.show()
                    
                    return
                }
                
                guard let data = data, let response = response else {
                    fatalError("No data or response is received.")
                }
                
                let cacheResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cacheResponse, for: self)

                //self.results = self.jsonToDictionary(data)
                completion(data)
            }
            task.resume()
        }
    }
}
