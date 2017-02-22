//
//  ResultsViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 1/30/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var bizInfo: UILabel!
    
    private var coordinate: CLLocationCoordinate2D?
    fileprivate var restaurant: Restaurant!
    fileprivate var isNavigationBarHidden: Bool?
        
    func getResults(name: String, price: String, rating: String, reviewCount: String, url: String, address: String, isFavorite: Bool, latitude: Double, longitude: Double, totalBiz: Int, randomNo: Int, category: String) {
        
        restaurant = Restaurant(name: name, price: price, rating: rating, reviewCount: reviewCount, address: address, isFavorite: false, date: 0, url: url, latitude: latitude, longitude: longitude, category: category, total: totalBiz, number: randomNo)
        
        coordinate = CLLocationCoordinate2DMake(restaurant.latitude, restaurant.longitude)
    }
    
    @IBAction func linkToYelp(_ sender: UIButton) {
        if restaurant.url != "" {
            UIApplication.shared.openURL(URL(string: restaurant.url)!)
        } else {
            alert()
        }
    }
    
    fileprivate func alert() {
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "No restaurant has been found.", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
        }))
        
        // Show the alert.
        self.present(alert, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if restaurant.name == "" {
            bizInfo.text = "No restaurant found"
        } else {
            //bizInfo.text = "\(restaurant.name)\nprice: \(restaurant.price), rating: \(restaurant.rating), review count: \(restaurant.reviewCount)\ntotal found: \(restaurant.total), picked no.: \(restaurant.number)\naddress: \(restaurant.address)\ncategory: \(restaurant.category)"
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
        let destinationVC = segue.destination
        
        if restaurant.address == "" || coordinate == nil {
            alert()
        } else {
            if let mapVC = destinationVC as? GoogleMapViewController {
                if let id = segue.identifier, id == "googleMap" {
                    mapVC.setBizLocation(restaurant.address)
                    mapVC.setBizCoordinate2D(coordinate!)
                    mapVC.setBizName(restaurant.name)
                    //********mapVC.setDepartureTime(YelpUrlQueryParameters.openAt!)
                }
            }
        }
    }

}
