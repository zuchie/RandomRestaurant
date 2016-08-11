//
//  ViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 7/31/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var token: UITextField!
    @IBOutlet weak var paramPicker: UIPickerView!
    @IBOutlet weak var bizPicked: UILabel!
    
    private var brain = RestaurantBrain()
    //private var map = MapViewController()
    
    private var term = ""
    private var rating: Float = 0.0
    private let locationManager = CLLocationManager()
    
    private var myLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D()
    private var bizLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D()
    
    private var paramPickerData = [
        ["Mexican", "Chinese", "Italian", "American"],
        ["4", "4.5", "5"]
    ]
    
    enum PickerComponent: Int {
        case term = 0
        case rating = 1
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var destinationVC = segue.destinationViewController
        if let navCon = destinationVC as? UINavigationController {
            destinationVC = navCon.visibleViewController ?? destinationVC
        }
        if let mapVC = destinationVC as? MapViewController {
            if let id = segue.identifier {
                if id == "map" {
                    if myLocation != nil {
                        mapVC.setMyLocation(CLLocationCoordinate2D(latitude: myLocation!.latitude, longitude: myLocation!.longitude))
                        if bizLocation != nil {
                            mapVC.setBizLocation(CLLocationCoordinate2D(latitude: bizLocation!.latitude, longitude: bizLocation!.longitude))
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func start() {
    
        bizPicked.text = nil // Reset for following queries
        // TODO: make params come from button/list
        print("latitude: \(myLocation!.latitude), longitude: \(myLocation!.longitude)")
        //brain.getUrlParameters(term, latitude: 37.786882, longitude: -122.399972, limit: 20)
        brain.getUrlParameters(term, latitude: myLocation?.latitude, longitude: myLocation?.longitude, limit: 20)

        brain.makeBizSearchUrl("https://api.yelp.com/v3/businesses/search?")

        // Use this in production
        let access_token = token.text!



        brain.setRatingBar(rating)
        brain.makeUrlRequest(access_token) { success in
            if success {
                print("brain.result: \(self.brain.result)")
                if let pickedBiz = self.brain.result {
                    //print("name: \(pickedBiz["name"]!)")
                    let coordinates = pickedBiz["coordinates"] as! NSDictionary
                    self.bizLocation!.latitude = (coordinates["latitude"] as? Double)!
                    self.bizLocation!.longitude = (coordinates["longitude"] as? Double)!
                    dispatch_async(dispatch_get_main_queue(), {
                        self.bizPicked.text = "\(pickedBiz["name"]!), \(pickedBiz["price"]!), \(pickedBiz["review_count"]!), \(pickedBiz["rating"]!)"
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.bizPicked.text = "No found, change search parameters"
                    })
                }
                
                self.brain.result = nil // Clear result
                //pickedBiz = [:]
                //print("Biz picked!!")
            } else {
                print("Biz not picked yet")
            }
        }
    }

    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        print("columns: \(paramPickerData.count)")
        return paramPickerData.count
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("row: \(paramPickerData[component].count)")
        return paramPickerData[component].count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("data: \(paramPickerData[component][row])")
        return paramPickerData[component][row]
    }
    
    private func updateLabel(){
        let termComponent = PickerComponent.term.rawValue
        let ratingComponent = PickerComponent.rating.rawValue
        term = paramPickerData[termComponent][paramPicker.selectedRowInComponent(termComponent)] // Can't use paramPickerData[0][row], picker would be inaccurate.
        rating = Float(paramPickerData[ratingComponent][paramPicker.selectedRowInComponent(ratingComponent)])!
        print("term: \(term), rating: \(rating)")
    }
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        updateLabel()
    }
    
    // Get current location.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.last {
            myLocation!.latitude = location.coordinate.latitude
            myLocation!.longitude = location.coordinate.longitude
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error updating location: \(error.localizedDescription)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        paramPicker.delegate = self
        paramPicker.dataSource = self
        paramPicker.selectRow(1, inComponent: PickerComponent.term.rawValue, animated: false)
        paramPicker.selectRow(1, inComponent: PickerComponent.rating.rawValue, animated: false)
        updateLabel()
        
        let cacheSizeMemory = 1 * 1024 * 1024
        let cacheSizeDisk = 2 * 1024 * 1024
        let urlCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "urlCache")
        NSURLCache.setSharedURLCache(urlCache)
        
        // Get location info.
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
}

