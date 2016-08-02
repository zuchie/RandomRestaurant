//
//  ViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 7/31/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var token: UITextField!
    @IBOutlet weak var termPicker: UIPickerView!
    @IBOutlet weak var bizPicked: UILabel!
    
    private var termPickerData = [[String]]()
    private var brain = RestaurantBrain()
    
    @IBAction func start() {
    
        // TODO: make params come from button/list
        brain.getUrlParameters(term, latitude: 37.786882, longitude: -122.399972, limit: 20)
        brain.makeBizSearchUrl("https://api.yelp.com/v3/businesses/search?")

        // Use this in production
        let access_token = token.text!

        
        brain.setRatingBar(rating)
        brain.makeUrlRequest(access_token)
        
        var pickedBiz: NSDictionary = [:]
        //TODO: Use event interrupt instead of polling
        repeat {
            pickedBiz = brain.result
        } while pickedBiz["name"] == nil

        print("name: \(pickedBiz["name"]!)")
        bizPicked.text = "\(pickedBiz["name"]!), \(pickedBiz["price"]!), \(pickedBiz["review_count"]!), \(pickedBiz["url"]!)"
    }
    
    private var term = ""
    private var rating = 0.0
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return termPickerData.count
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return termPickerData[component].count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return termPickerData[component][row]
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        term = termPickerData[0][row]
        rating = Double(termPickerData[1][row])!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.termPicker.delegate = self
        self.termPicker.dataSource = self
        termPickerData = [
                            ["Mexican", "Chinese", "Italian", "American"],
                            ["4", "4.5", "5"]
                        ]
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

