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
    
    private var brain = RestaurantBrain()
    
    @IBAction func start() {

        // TODO: make params come from button/list
        brain.getUrlParameters("chinese", latitude: 37.786882, longitude: -122.399972, limit: 20)
        brain.makeBizSearchUrl("https://api.yelp.com/v3/businesses/search?")

        // Use this in production
        let access_token = token.text!

        
        brain.makeUrlRequest(access_token)
    }
    
/*
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
*/
}

