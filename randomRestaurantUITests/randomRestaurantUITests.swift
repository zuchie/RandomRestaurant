//
//  randomRestaurantUITests.swift
//  randomRestaurantUITests
//
//  Created by Zhe Cui on 4/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import XCTest
import CoreLocation

class randomRestaurantUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("==UI test set up==")
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        print("==UI test app launch==")
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        print("==UI test tear down==")
        
        app.terminate()
        app = nil
    }
    
    func testLocationAuthorizationDenied() {
        app.alerts["Allow “randomRestaurant” to access your location while you use the app?"].buttons["Don’t Allow"].tap()
        XCTAssert(CLLocationManager.authorizationStatus() == .denied, "Authorization status is not denied.")
    }
    
    func testLocationAuthorizationWhenInUse() {
        app.alerts["Allow “randomRestaurant” to access your location while you use the app?"].buttons["Allow"].tap()
        XCTAssert(CLLocationManager.authorizationStatus() == .authorizedWhenInUse, "Authorization status is not authorized when in use.")
    }
    
    func testLocationAuthorization() {
        let authorization = CLLocationManager.authorizationStatus()
        switch authorization {
        case .denied:
            print("authorization denied")
            
            let app = XCUIApplication()
            app.alerts["Allow “randomRestaurant” to access your location while you use the app?"].buttons["Don’t Allow"].tap()
            app.tables["What: all"].staticTexts["What: all"].tap()
            app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Italian").element.tap()
            app.alerts["Location Access Disabled"].buttons["Open Settings"].tap()
            XCUIDevice.shared().orientation = .portrait
            XCUIDevice.shared().orientation = .portrait
            app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.swipeUp()
            
        case .authorizedWhenInUse:
            print("authorized when in use")
        default:
            break
        }
    }
    
    /*
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    */
}
