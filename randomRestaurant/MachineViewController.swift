//
//  MachineViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/8/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation

class MachineViewController: UIViewController {
    
    @IBOutlet weak var animation: UIImageView!
    
    fileprivate let animationImages = [
        UIImage(named: "image0")!,
        UIImage(named: "image1")!,
        UIImage(named: "image2")!,
        UIImage(named: "image3")!,
        UIImage(named: "image4")!,
        UIImage(named: "image5")!,
        UIImage(named: "image6")!
    ]
    
    fileprivate var ratingBar = 0.0
    fileprivate var nearbyBusinesses = GetNearbyBusinesses()
    fileprivate var pickedRestaurant: Restaurant?

    fileprivate var bizName = ""
    fileprivate var bizPrice = ""
    fileprivate var bizRating = ""
    fileprivate var bizReviewCount = ""
    fileprivate var bizLocationObj: PickedBusinessLocation?
    fileprivate var bizAddress = ""
    fileprivate var bizCoordinate2D: CLLocationCoordinate2D?
    fileprivate var bizUrl = ""
    fileprivate var bizCategory = ""
    fileprivate var total: Int?
    fileprivate var random: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nearbyBusinesses.setRatingBar(ratingBar)
    }
    
    fileprivate func startAnimation() {
        
        animation.animationImages = animationImages
        animation.animationDuration = 2.0
        animation.animationRepeatCount = 1
        
        animation.startAnimating()
    }
    
    func getRatingBar(_ rating: Double) {
        ratingBar = rating
    }
    
    func afterAnimation() {
        performSegue(withIdentifier: "results", sender: self)
    }
    
    @IBAction func start(_ sender: UIButton) {
        startAnimation()
        
        // Register things to do when animation is done.
        self.perform(#selector(afterAnimation), with: nil, afterDelay: animation.animationDuration)
        
        // Start Yelp API query.
        let access_token = "BYJYCVjjgIOuchrzOPICryariCWPw8OMD9aZqE1BsYTsah8NX1TQbv5O-kVbMWEmQUxFHegLlZPPR5Vi38fUH0MXV74MhDVhzTgSm6PM7e3IA-VE46HkB126lFmJWHYx"
        
        // Get businesses from Yelp API v3.
        nearbyBusinesses.getUrlParameters(YelpUrlQueryParameters.coordinates, categories: YelpUrlQueryParameters.category, radius: YelpUrlQueryParameters.radius, limit: YelpUrlQueryParameters.limit, open_at: YelpUrlQueryParameters.openAt)
        
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
                
                self.bizUrl = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "url")
                
                self.bizCategory = YelpUrlQueryParameters.category!
                
                // Params going to pass to Core Data of History Restaurant.
                self.pickedRestaurant = Restaurant(name: self.bizName, price: self.bizPrice, rating: self.bizRating, reviewCount: self.bizReviewCount, address: self.bizAddress, isFavorite: false, date: Int(Date().timeIntervalSince1970), url: self.bizUrl, latitude: (self.bizCoordinate2D?.latitude)!, longitude: (self.bizCoordinate2D?.longitude)!, category: self.bizCategory, total: totalBiz, number: randomNo)
                
                // Update History database.
                DataBase.add(self.pickedRestaurant!, to: "history")
            } else {
                print("Couldn't get a restaurant")
                //self.pickedRestaurant = Restaurant(name: "", price: "", rating: "", reviewCount: "", address: "", isFavorite: false, date: 0, url: "", latitude: 0, longitude: 0, category: "", total: 0, number: 0)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationVC = segue.destination as? ResultsViewController, segue.identifier == "results" {
                destinationVC.getResults(name: pickedRestaurant?.name, price: pickedRestaurant?.price, rating: pickedRestaurant?.rating, reviewCount: pickedRestaurant?.reviewCount, url: pickedRestaurant?.url, address: pickedRestaurant?.address, coordinate: bizCoordinate2D, totalBiz: pickedRestaurant?.total, randomNo: pickedRestaurant?.number, category: pickedRestaurant?.category)
        }
    }

}
