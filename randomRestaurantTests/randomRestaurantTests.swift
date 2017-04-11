//
//  randomRestaurantTests.swift
//  randomRestaurantTests
//
//  Created by Zhe Cui on 3/23/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import XCTest
@testable import randomRestaurant

class randomRestaurantTests: XCTestCase {
    
    var vc: MainTableViewController!
    var yelpQueryStr: YelpUrlQueryParameters!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC") as! MainTableViewController
        
        yelpQueryStr = YelpUrlQueryParameters(latitude: nil, longitude: nil, category: nil, radius: nil, limit: nil, openAt: nil, sortBy: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testQueryStrFormatter() {
        let param = yelpQueryStr.formatParameter(parameter: ("American", "categories"))
        
        XCTAssert(param == "&categories=newamerican,tradamerican", "Failed")
    }
    
    /*
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        print("test done")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    */
}
