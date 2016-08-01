//
//  ViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 7/31/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var token: UITextField!
    
    @IBAction func start() {
        let myUrl = "https://api.yelp.com/v3/businesses/search?term=chinese&latitude=37.786882&longitude=-122.399972&limit=20"
        
        let urlObj = NSURL(string: myUrl)
        
        let request = NSMutableURLRequest(URL: urlObj!)
        
        request.HTTPMethod = "GET"
        
        // Use this in production
        let access_token = token.text!
        

        
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString)")
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    //print(convertedJsonIntoDict)
                    let businesses = convertedJsonIntoDict["businesses"]! as! NSArray
                    let sortedBusinesses: NSArray = businesses.sort({$0["rating"] as! Double == $1["rating"] as! Double ?
                        $0["review_count"] as! Int > $1["review_count"] as! Int : $0["rating"] as! Double > $1["rating"] as! Double})
                    print("\(sortedBusinesses)")
                    
                    //let indexOfFisrtUnqualifiedBusiness = sortedBusinesses.indexOfObjectPassingTest({ $0["rating"] < 4.5 }) // TODO: Why this not work?
                    //print("indexOfFisrtUnqualifiedBusiness: \(indexOfFisrtUnqualifiedBusiness)")
                    
                    for business in sortedBusinesses {
                        let businessRating = business["rating"] as! Double
                        if businessRating < 4 {
                            let index = sortedBusinesses.indexOfObject(business)
                            print("\(index)")
                            break
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

