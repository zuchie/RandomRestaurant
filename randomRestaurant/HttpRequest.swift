//
//  HttpRequest.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 5/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

class HttpRequest {
    
    // Properties.
    private var url: String
    private var httpMethod: String
    private struct HttpHeader {
        var value: String
        var field: String
    }
    private var httpHeader: HttpHeader
    private var cachePolicy: NSURLRequest.CachePolicy
    private var timeoutInterval: Double
    
    private var results: [String: Any]?
    
    var completion: ((_ results: [String: Any]?) -> Void)?
    //var delegate: HttpRequestDelegate?
    
    init(url: String, httpMethod: String, httpHeaderValue: String, httpHeaderField: String, cachePolicy: NSURLRequest.CachePolicy, timeoutInterval: Double) {
        
        self.url = url
        self.httpMethod = httpMethod
        self.httpHeader = HttpHeader(value: httpHeaderValue, field: httpHeaderField)
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }
    
    // Methods.
    func makeRequest() {
        guard let urlObj = URL(string: url) else {
            fatalError("Couldn't make an URL object from url string: \(url).")
        }
        var request = URLRequest(url: urlObj)
        request.httpMethod = httpMethod
        request.addValue(httpHeader.value, forHTTPHeaderField: httpHeader.field)
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            print("Cached response.")
            print("Disk usage/capacity: \(URLCache.shared.currentDiskUsage)/\(URLCache.shared.diskCapacity), memory usage/capacity: \(URLCache.shared.currentMemoryUsage)/\(URLCache.shared.memoryCapacity)")

            // TODO: Handle responses?
            results = jsonToDictionary(cachedResponse.data)
            completion?(results)
            
            //delegate?.getCachedResponse(data: cachedResponse.data, response: cachedResponse.response)
        } else {
            print("Fresh response.")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                let cacheResponse = CachedURLResponse(response: response!, data: data!)
                URLCache.shared.storeCachedResponse(cacheResponse, for: request)

                // TODO: Handle errors.
                self.results = self.jsonToDictionary(data!)
                self.completion?(self.results)
                
                //self.delegate?.getHttpRequestAndResults(request: request, data: data, response: response, error: error)
            }
            task.resume()
        }
    }
    
    // Helper functions.
    fileprivate func jsonToDictionary(_ data: Data) -> [String: Any]? {
        // Convert server json response to NSDictionary
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        return json as? [String: Any]
    }
}
