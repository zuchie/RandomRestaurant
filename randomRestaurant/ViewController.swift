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
    @IBOutlet weak var paramPicker: UIPickerView!
    @IBOutlet weak var bizPicked: UILabel!
    
    private var brain = RestaurantBrain()
    
    @IBAction func start() {
    
        bizPicked.text = nil // Reset for following queries
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
        
        brain.result = [:] // Clear result

        print("name: \(pickedBiz["name"]!)")
        bizPicked.text = "\(pickedBiz["name"]!), \(pickedBiz["price"]!), \(pickedBiz["review_count"]!), \(pickedBiz["rating"]!)"
    }
    
    private var term = ""
    private var rating = 0.0
    
    private var paramPickerData = [
                                    ["Mexican", "Chinese", "Italian", "American"],
                                    ["4", "4.5", "5"]
                                ]
    
    enum pickerComponent: Int {
        case term = 0
        case rating = 1
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        print("columns: \(paramPickerData.count)")
        return paramPickerData.count
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("row: \(paramPickerData[component].count)")
        return paramPickerData[component].count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("data: \(paramPickerData[component][row])")
        return paramPickerData[component][row]
    }
    
    private func updateLabel(){
        let termComponent = pickerComponent.term.rawValue
        let ratingComponent = pickerComponent.rating.rawValue
        term = paramPickerData[termComponent][paramPicker.selectedRowInComponent(termComponent)] // Can't use paramPickerData[0][row], picker would be inaccurate.
        rating = Double(paramPickerData[ratingComponent][paramPicker.selectedRowInComponent(ratingComponent)])!
        print("term: \(term), rating: \(rating)")
    }
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        updateLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        paramPicker.delegate = self
        paramPicker.dataSource = self
        paramPicker.selectRow(1, inComponent: pickerComponent.term.rawValue, animated: false)
        paramPicker.selectRow(1, inComponent: pickerComponent.rating.rawValue, animated: false)
        updateLabel()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

