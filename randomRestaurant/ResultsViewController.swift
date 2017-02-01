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
    private var category: String?
        
    func getResults(name: String?, price: String?, rating: String?, reviewCount: String?, url: String?, address: String?, coordinate: CLLocationCoordinate2D?, totalBiz: Int?, randomNo: Int?, category: String?) {

        self.name = name
        self.price = price
        self.rating = rating
        self.reviewCount = reviewCount
        self.url = url
        self.address = address
        self.coordinate = coordinate
        self.totalBiz = totalBiz
        self.randomNo = randomNo
        self.category = category
    }
    
    @IBAction func linkToYelp(_ sender: UIButton) {
        if let yelpUrl = url {
            UIApplication.shared.openURL(URL(string: yelpUrl)!)
        } else {
            alert()
        }
    }

    // Dismiss view controller.
    @IBAction func dismiss(_ sender: UIButton) {
        //self.dismiss(animated: true, completion: nil)
        _ = self.navigationController?.popViewController(animated: false)
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
    
    // Restore Navi Bar.
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        if name == nil {
            bizInfo.text = "No restaurant found"
        } else {
            bizInfo.text = "\(name!)\nprice: \(price!), rating: \(rating!), review count: \(reviewCount!)\ntotal found: \(totalBiz!), picked no.: \(randomNo!)\naddress: \(address!)\ncategory: \(category!)"
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
        
        if address == nil || coordinate == nil {
            alert()
        } else {
            if let mapVC = destinationVC as? GoogleMapViewController {
                if let id = segue.identifier, id == "googleMap" {
                    mapVC.setBizLocation(address!)
                    mapVC.setBizCoordinate2D(coordinate!)
                    mapVC.setBizName(name!)
                    mapVC.setDepartureTime(YelpUrlQueryParameters.openAt!)
                }
            }
        }
    }

}
