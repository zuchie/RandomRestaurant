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
    fileprivate var foodCategories = [FoodCategories]()
    
    fileprivate var foodCategoriesName = ["Chinese", "Mexican", "Italian", "NewAmerican", "TradAmerican", "French"]
    
    fileprivate var category = ""
    
    var urlQueryParameters: YelpUrlQueryParameters?
    func setYelpUrlQueryParameters(_ urlParam: YelpUrlQueryParameters) {
        urlQueryParameters = urlParam
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for categoryName in foodCategoriesName.enumerated() {
            loadFoodCategories(categoryName.element)
        }
    }
    
    func loadFoodCategories(_ name: String) {
        let photo = UIImage(named: name.lowercased())!
        let food = FoodCategories(name: name, photo: photo)!
        foodCategories += [food]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return foodCategories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FoodCategoriesTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FoodCategoriesTableViewCell
        
        let foodCategory = foodCategories[(indexPath as NSIndexPath).row]

        // Configure the cell...
        cell.nameLabel.text = foodCategory.name
        cell.photoImageView.image = foodCategory.photo

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! FoodCategoriesTableViewCell
        // Food category has to be lower case for API to recognize.
        category = selectedCell.nameLabel.text!.lowercased()
    }


    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var destinationVC = segue.destination
        if let navCtrl = destinationVC as? UINavigationController {
            destinationVC = navCtrl.visibleViewController ?? destinationVC
        }
        
        if let timeVC = destinationVC as? TimeViewController {
            if let id = segue.identifier {
                if id == "time" {
                    urlQueryParameters?.category = category
                    timeVC.setYelpUrlQueryParameters(urlQueryParameters!)
                }
            }
        }
        
    }

}
