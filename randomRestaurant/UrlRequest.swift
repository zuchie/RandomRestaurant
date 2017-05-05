//
//  UrlRequest.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 5/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation

protocol HttpRequestDelegate {
    func getHttpRequestAndResults(request: URLRequest?, data: Data?, response: URLResponse?, error: Error?)
    func getCachedResponse(data: Data?, response: URLResponse?)
}

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
    
    var delegate: HttpRequestDelegate?
    
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
            delegate?.getCachedResponse(data: cachedResponse.data, response: cachedResponse.response)
        } else {
            print("Fresh response.")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.delegate?.getHttpRequestAndResults(request: request, data: data, response: response, error: error)
            }
            task.resume()
        }
    }
}
