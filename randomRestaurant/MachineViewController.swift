//
//  MachineViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/8/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

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
    fileprivate var restaurant = Restaurant()

    fileprivate var bizLocationObj: PickedBusinessLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("set rating bar: \(ratingBar)")
        //nearbyBusinesses.setRatingBar(ratingBar)
    }
    
    fileprivate func startAnimation() {
        
        animation.animationImages = animationImages
        animation.animationDuration = 2.0
        animation.animationRepeatCount = 1
        
        animation.startAnimating()
    }
    /*
    func getRatingBar(_ rating: Double) {
        print("get rating bar: \(ratingBar)")
        ratingBar = rating
    }
    */
    func afterAnimation() {
        performSegue(withIdentifier: "machineToResults", sender: self)
    }
    
    @IBAction func start(_ sender: UIButton) {
        startAnimation()
        
        // Register things to do when animation is done.
        self.perform(#selector(afterAnimation), with: nil, afterDelay: animation.animationDuration)
        
        // Start Yelp API query.
        let access_token = "BYJYCVjjgIOuchrzOPICryariCWPw8OMD9aZqE1BsYTsah8NX1TQbv5O-kVbMWEmQUxFHegLlZPPR5Vi38fUH0MXV74MhDVhzTgSm6PM7e3IA-VE46HkB126lFmJWHYx"
        
        // Get businesses from Yelp API v3.
        //********nearbyBusinesses.getUrlParameters(YelpUrlQueryParameters.coordinates, categories: YelpUrlQueryParameters.category, radius: YelpUrlQueryParameters.radius, limit: YelpUrlQueryParameters.limit, open_at: YelpUrlQueryParameters.openAt)
        
        nearbyBusinesses.makeBusinessesSearchUrl("https://api.yelp.com/v3/businesses/search?")
        nearbyBusinesses.makeUrlRequest(access_token) { totalBiz, randomNo in
            
            if let returnedBusiness = self.nearbyBusinesses.result {
                
                self.restaurant.name = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "name")
                self.restaurant.price = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "price")
                self.restaurant.rating = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "rating")
                self.restaurant.reviewCount = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "review_count")
                
                // Get picked business location object and convert to address string.
                if let pickedBizLocationObj = returnedBusiness["location"] as? NSDictionary {
                    self.bizLocationObj = PickedBusinessLocation(businessObj: pickedBizLocationObj)
                    self.restaurant.address = self.bizLocationObj!.getBizAddressString()
                } else {
                    print("No location information of picked business")
                }
                
                if let pickedBusinessCoordinatesObj = returnedBusiness["coordinates"] as? NSDictionary {
                    self.restaurant.latitude = (pickedBusinessCoordinatesObj["latitude"] as? Double)!
                    self.restaurant.longitude = (pickedBusinessCoordinatesObj["longitude"] as? Double)!
                }
                
                self.restaurant.url = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "url")
                //********self.restaurant.category = YelpUrlQueryParameters.category!
                self.restaurant.total = totalBiz
                self.restaurant.number = randomNo
                self.restaurant.date = Int(Date().timeIntervalSince1970)
                
                // Update History database.
                DataBase.add(self.restaurant, to: "history")
            } else {
                print("Couldn't get a restaurant")
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
        if let destinationVC = segue.destination as? ResultsViewController, segue.identifier == "machineToResults" {
                destinationVC.getResults(name: restaurant.name, price: restaurant.price, rating: restaurant.rating, reviewCount: restaurant.reviewCount, url: restaurant.url, address: restaurant.address, isFavorite: restaurant.isFavorite, latitude: restaurant.latitude, longitude: restaurant.longitude, totalBiz: restaurant.total, randomNo: restaurant.number, category: restaurant.category)
        }
    }

}
