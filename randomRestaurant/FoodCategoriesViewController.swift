//
//  FoodCategoriesViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/18/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class FoodCategoriesViewController: UITableViewController {
    
    // MARK: Properties
    private var foodCategories = [FoodCategories]()
    
    private var foodCategoriesName = ["Chinese", "Mexican", "Italian", "NewAmerican", "TradAmerican", "French"]
    
    private var category = ""
    
    var urlQueryParameters: UrlQueryParameters?
    func setUrlQueryParameters(urlParam: UrlQueryParameters) {
        urlQueryParameters = urlParam
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for categoryName in foodCategoriesName.enumerate() {
            loadFoodCategories(categoryName.element)
        }
    }
    
    func loadFoodCategories(name: String) {
        let photo = UIImage(named: name.lowercaseString)!
        let food = FoodCategories(name: name, photo: photo)!
        foodCategories += [food]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return foodCategories.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "FoodCategoriesTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FoodCategoriesTableViewCell
        
        let foodCategory = foodCategories[indexPath.row]

        // Configure the cell...
        cell.nameLabel.text = foodCategory.name
        cell.photoImageView.image = foodCategory.photo

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! FoodCategoriesTableViewCell
        // Food category has to be lower case for API to recognize.
        category = selectedCell.nameLabel.text!.lowercaseString
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destinationVC = segue.destinationViewController
        if let navCtrl = destinationVC as? UINavigationController {
            destinationVC = navCtrl.visibleViewController ?? destinationVC
        }
        if let timeVC = destinationVC as? TimeViewController {
            if let id = segue.identifier {
                if id == "time" {
                    urlQueryParameters?.category = category
                    timeVC.setUrlQueryParameters(urlQueryParameters!)
                }
            }
        }
        
    }

}
