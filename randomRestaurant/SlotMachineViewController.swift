//
//  SlotMachineViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 7/31/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation

class SlotMachineViewController: UIViewController {

    @IBOutlet weak var bizPicked: UILabel!
    @IBOutlet weak var pickedBizAddress: UILabel!
    
    private var nearbyBusinesses = GetNearbyBusinesses()
    
    private var ratingBar = 0.0
    
    private var bizName = ""
    private var bizPrice = ""
    private var bizRating = ""
    private var bizReviewCount = ""
    private var bizLocationObj: PickedBusinessLocation?
    private var bizAddress = ""
    private var bizCoordinate2D: CLLocationCoordinate2D?
    
    
    var urlQueryParameters: UrlQueryParameters?
    
    func setUrlQueryParameters(urlParam: UrlQueryParameters) {
        urlQueryParameters = urlParam
        print("category: \(urlQueryParameters!.category), location: \(urlQueryParameters!.location), radius: \(urlQueryParameters!.radius), limit: \(urlQueryParameters!.limit), time: \(urlQueryParameters!.openAt)")
    }
    
    func getRatingBar(rating: Double) {
        ratingBar = rating
    }

    
    @IBAction func start() {
        
        let access_token = "XxrwsnAP8YyUtmYdSrC0RCHA6sgn8ggZILNUhNZQqkP8zBTNjondbANeyBLWw7V8LGX-cAb_H4jM2OMu_mnJpwVik5IU0g_S6ZOEJZTaU"
        
        //bizPicked.text = nil // Reset for following queries
        
        // Get businesses from Yelp API v3.
        nearbyBusinesses.getUrlParameters(urlQueryParameters?.location, categories: urlQueryParameters?.category, radius: urlQueryParameters?.radius, limit: urlQueryParameters?.limit, open_at: urlQueryParameters?.openAt)
        
        nearbyBusinesses.makeBusinessesSearchUrl("https://api.yelp.com/v3/businesses/search?")
        
        nearbyBusinesses.makeUrlRequest(access_token) { totalBiz, randomNo in
            
            //print("total biz: \(totalBiz), random no.: \(randomNo)")
            if let returnedBusiness = self.nearbyBusinesses.result {
                //print("business picked: \(returnedBusiness)")
                
                self.bizName = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "name")
                self.bizPrice = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "price")
                self.bizRating = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "rating")
                self.bizReviewCount = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "review_count")
                
                // Get picked business location object and convert to address string.
                if let pickedBizLocationObj = returnedBusiness["location"] as? NSDictionary {
                        self.bizLocationObj = PickedBusinessLocation(businessObj: pickedBizLocationObj)
                    
                        self.bizAddress = self.bizLocationObj!.getBizAddressString()
                        print("biz location: \(self.bizAddress)")
                } else {
                    print("No location information of picked business")
                }
                
                if let pickedBusinessCoordinatesObj = returnedBusiness["coordinates"] as? NSDictionary {
                    self.bizCoordinate2D = CLLocationCoordinate2DMake((pickedBusinessCoordinatesObj["latitude"] as? CLLocationDegrees)!, (pickedBusinessCoordinatesObj["longitude"] as? CLLocationDegrees)!)
                    print("biz latitude: \(self.bizCoordinate2D!.latitude), longitude: \(self.bizCoordinate2D!.longitude)")
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.bizPicked.text = "\(self.bizName)\nprice: \(self.bizPrice), rating: \(self.bizRating), review count: \(self.bizReviewCount)\ntotal found: \(totalBiz), picked no.: \(randomNo)"
                    self.pickedBizAddress.text = "\(self.bizAddress)"
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.bizPicked.text = "No restaurant found"
                })
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nearbyBusinesses.setRatingBar(ratingBar)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func alert() {
        
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "Please push \"Start\" button.", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            
        }))
        
        // Show the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationVC = segue.destinationViewController
        
        if bizAddress.isEmpty || bizCoordinate2D == nil {
            
            alert()
            
        } else {
            if let mapVC = destinationVC as? GoogleMapViewController {
                if let id = segue.identifier {
                    if id == "googleMap" {
                        mapVC.setBizLocation(bizAddress)
                        mapVC.setBizCoordinate2D(bizCoordinate2D!)
                        mapVC.setBizName(bizName)
                        mapVC.setDepartureTime(urlQueryParameters!.openAt)
                    }
                }
            }
        }
    }
    
}

