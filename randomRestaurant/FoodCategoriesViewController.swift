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
    
    private var foodCategoriesName = ["Mexican", "Chinese", "Italian", "American", "French"]
    
    private var location = ""
    private var category = ""
    
    func setLocation(place: String) {
        location = place
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
        category = selectedCell.nameLabel.text!
        print("category: \(category), location: \(location)")
    }
    
    // MARK: - Navigation
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destinationVC = segue.destinationViewController
        if let navCtrl = destinationVC as? UINavigationController {
            destinationVC = navCtrl.visibleViewController ?? destinationVC
        }
        if let timeVC = destinationVC as? TimeViewController {
            if let id = segue.identifier {
                if id == "time" {
                    timeVC.setLocationAndCategory(location, category: category)
                }
            }
        }
        
    }
    */

}
