//
//  randomRestaurantTests.swift
//  randomRestaurantTests
//
//  Created by Zhe Cui on 3/23/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import XCTest
import CoreLocation
@testable import randomRestaurant

class randomRestaurantTests: XCTestCase, LocationManagerDelegate {
    
    //var mainViewController: MainTableViewController!
    
    override func setUp() {
        super.setUp()
        print("===Setup===")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC") as! MainTableViewController
        
        //let _ = mainViewController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        print("===Teardown===")
        
        //mainViewController = nil
    }
    
    func testMainView() {
        // Setup
        var mainViewController: MainTableViewController! = UIApplication.topViewController() as! MainTableViewController
        
        // Test
        XCTAssertNotNil(mainViewController.view, "Cannot find Main Tableview controller instance")
        
        // Teardown
        mainViewController = nil
    }
    
    func testQueryStrFormatter() {
        // Setup
        var yelpQueryStr: YelpUrlQueryParameters! = YelpUrlQueryParameters(latitude: nil, longitude: nil, category: nil, radius: nil, limit: nil, openAt: nil, sortBy: nil)

        // Test
        let param = yelpQueryStr.formatParameter(parameter: ("American", "categories"))
        
        XCTAssert(param == "&categories=newamerican,tradamerican", "Failed")
        
        // Teardown
        yelpQueryStr = nil
    }
    
    /**
     * LocationController
     */
    var expectation: XCTestExpectation!
    
    func testLocation() {
        var locationManager: LocationManager! = LocationManager.shared
        
        locationManager.delegate = self

        expectation = expectation(description: "Got location successfully")
        
        locationManager.requestLocation()
        
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Waiting for expectations timed out, error: \(String(describing: error))")
            
            locationManager.delegate = nil
            locationManager = nil
            
            print("Locaton test done")
        }
    }
    
    func updateLocation(location: CLLocation?) {
        print("Location updated")
        XCTAssertNotNil(location, "Location is nil")
        
        expectation.fulfill()
    }
    
    func updateLocationError(error: Error?) {
        print("Location error")
        XCTAssertNil(error, "Error isn't nil")
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

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let tabController = controller as? UITabBarController {
            return topViewController(controller: tabController.selectedViewController)
        }
        if let navController = controller as? UINavigationController {
            return topViewController(controller: navController.visibleViewController)
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
