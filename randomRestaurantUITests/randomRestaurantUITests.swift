//
//  randomRestaurantUITests.swift
//  randomRestaurantUITests
//
//  Created by Zhe Cui on 4/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import XCTest

class randomRestaurantUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocationAuthorizationDenied() {
        XCUIApplication().alerts["Allow “randomRestaurant” to access your location while you use the app?"].buttons["Don’t Allow"].tap()
        
    }
    
    func testLocationAuthorizationWhenInUse() {
        
    }
    
    /*
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    */
}
