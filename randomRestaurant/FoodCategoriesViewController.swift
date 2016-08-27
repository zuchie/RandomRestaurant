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
    //private var nearbyBusiness = GetNearbyBusinesses()
    private var foodCategory = ""
    private var avgRating = 0.0
    
    func setAvgRating(rating: Double) {
        avgRating = rating
    }
    func setFoodCategory(category: String) {
        foodCategory = category
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFoodCategories()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadFoodCategories() {
        let mexicanPhoto = UIImage(named: "mexican")!
        let mexicanFood = FoodCategories(name: foodCategory, photo: mexicanPhoto, rating: avgRating)!
        foodCategories += [mexicanFood]
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
        cell.ratingControl.bizRating = foodCategory.rating

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    

}
