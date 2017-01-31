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
    
    private var name: String?
    private var price: String?
    private var rating: String?
    private var reviewCount: String?
    private var url: String?
    private var address: String?
    private var coordinate: CLLocationCoordinate2D?
    private var totalBiz: Int?
    private var randomNo: Int?
    
    private let mapVC = GoogleMapViewController()
    
    func getResults(name: String?, price: String?, rating: String?, reviewCount: String?, url: String?, address: String?, coordinate: CLLocationCoordinate2D?, totalBiz: Int?, randomNo: Int?) {

        self.name = name
        self.price = price
        self.rating = rating
        self.reviewCount = reviewCount
        self.url = url
        self.address = address
        self.coordinate = coordinate
        self.totalBiz = totalBiz
        self.randomNo = randomNo
    }
    
    @IBAction func linkToYelp(_ sender: UIButton) {
        if let yelpUrl = url {
            UIApplication.shared.openURL(URL(string: yelpUrl)!)
        } else {
            print("No Yelp URL has been got")
        }
    }
    
    @IBAction func linkToMap(_ sender: UIButton) {
        
        if address == nil || coordinate == nil {
            alert()
        } else {
            mapVC.setBizLocation(address!)
            mapVC.setBizCoordinate2D(coordinate!)
            mapVC.setBizName(name!)
            mapVC.setDepartureTime(YelpUrlQueryParameters.openAt!)
        }
    }

    
    fileprivate func alert() {
        
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "Please push \"Start\" button.", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
        }))
        
        // Show the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        if name == nil {
            bizInfo.text = "No restaurant found"
        } else {
            bizInfo.text = "\(name!)\nprice: \(price!), rating: \(rating!), review count: \(reviewCount!)\ntotal found: \(totalBiz!), picked no.: \(randomNo!), address: \(address!)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
