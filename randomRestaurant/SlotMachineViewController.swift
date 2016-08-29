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

    @IBOutlet weak var token: UITextField!
    @IBOutlet weak var bizPicked: UILabel!
    
    private var nearbyBusinesses = GetNearbyBusinesses()
    
    private var ratingBar = 0.0
    
    private var bizName = ""
    private var bizPrice = ""
    private var bizRating = ""
    private var bizReviewCount = ""
    
    
    var urlQueryParameters: UrlQueryParameters?
    
    func setUrlQueryParameters(urlParam: UrlQueryParameters) {
        urlQueryParameters = urlParam
        print("category: \(urlQueryParameters!.category), location: \(urlQueryParameters!.location), radius: \(urlQueryParameters!.radius), limit: \(urlQueryParameters!.limit), time: \(urlQueryParameters!.openAt)")
    }
    
    func getRatingBar(rating: Double) {
        ratingBar = rating
        //print("rating bar: \(ratingBar)")
    }

    
    @IBAction func start() {
        
        let access_token = "XxrwsnAP8YyUtmYdSrC0RCHA6sgn8ggZILNUhNZQqkP8zBTNjondbANeyBLWw7V8LGX-cAb_H4jM2OMu_mnJpwVik5IU0g_S6ZOEJZTaU"
        
        bizPicked.text = nil // Reset for following queries
        
        // Get businesses from Yelp API v3.
        nearbyBusinesses.getUrlParameters(urlQueryParameters?.location, categories: urlQueryParameters?.category, radius: urlQueryParameters?.radius, limit: urlQueryParameters?.limit, open_at: urlQueryParameters?.openAt)
        
        nearbyBusinesses.makeBusinessesSearchUrl("https://api.yelp.com/v3/businesses/search?")
        
        nearbyBusinesses.makeUrlRequest(access_token) {
            
            if let returnedBusiness = self.nearbyBusinesses.result {
                //print("business picked: \(returnedBusiness)")
                
                self.bizName = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "name")
                self.bizPrice = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "price")
                self.bizRating = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "rating")
                self.bizReviewCount = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "review_count")
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.bizPicked.text = "\(self.bizName), \(self.bizPrice), \(self.bizRating), \(self.bizReviewCount)"
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
    
    /*
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destinationVC = segue.destinationViewController
        if let navCon = destinationVC as? UINavigationController {
            destinationVC = navCon.visibleViewController ?? destinationVC
        }
        if let mapVC = destinationVC as? MapViewController {
            if let id = segue.identifier {
                if id == "map" {
                    if myLocation != nil {
                        mapVC.setMyLocation(CLLocationCoordinate2D(latitude: myLocation!.latitude, longitude: myLocation!.longitude))
                    }
                    if bizLocation != nil {
                        mapVC.setBizLocation(CLLocationCoordinate2D(latitude: bizLocation!.latitude, longitude: bizLocation!.longitude))
                    }
                }
            }
        }
    }
    */
}

