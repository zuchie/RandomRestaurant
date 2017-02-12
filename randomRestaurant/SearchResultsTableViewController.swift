//
//  SearchResultsTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/6/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation

class SearchResultsTableViewController: UITableViewController {

    var filteredRestaurants = [Favorite]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //print("search results view did load")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredRestaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "searchResults"
        //tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: cellID)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FavoriteTableViewCell
        
        // Configure the cell...
        let restaurant = filteredRestaurants[indexPath.row]
        cell.textLabel!.text = restaurant.name
        cell.url = restaurant.url
        cell.rating = restaurant.rating
        cell.reviewCount = restaurant.reviewCount
        cell.price = restaurant.price
        cell.address = restaurant.address
        cell.coordinate = CLLocationCoordinate2DMake(restaurant.latitude!.doubleValue, restaurant.longitude!.doubleValue)
        cell.category = restaurant.category
        
        return cell
    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteTableViewCell
        
        // Get results.
        //restaurant = Restaurant(name: (cell.textLabel?.text)!, price: cell.price, rating: cell.rating, reviewCount: cell.reviewCount, address: cell.address, isFavorite: false, date: 0, url: cell.url, latitude: cell.coordinate.latitude, longitude: cell.coordinate.longitude, category: cell.category)
        
        SlotMachineViewController.resultsVC.getResults(name: cell.textLabel?.text, price: cell.price, rating: cell.rating, reviewCount: cell.reviewCount, url: cell.url, address: cell.address, coordinate: cell.coordinate, totalBiz: 0, randomNo: 0, category: cell.category)
 
        //print("self.navi: \(self.navigationController)")
        //print("perform segue")
        //self.performSegue(withIdentifier: "resultsVC", sender: self)
        
        //self.present(SlotMachineViewController.resultsVC, animated: false, completion: nil)
        //self.navigationController?.pushViewController(SlotMachineViewController.resultsVC, animated: false)
        //view.addSubview(SlotMachineViewController.resultsVC.view)
        // self.navigationController is nil, have to use favoriteVC's navigationController to present resultsVC.
        
        SlotMachineViewController.favoriteTableVC.navigationController?.pushViewController(SlotMachineViewController.resultsVC, animated: false)
        //print("navi: \(self.navigationController)")
        //self.navigationController?.pushViewController(SlotMachineViewController.resultsVC, animated: false)
    }
    */
    /*
    // Method to conform to UISearchResultsUpdating protocol.
    public func updateSearchResults(for searchController: UISearchController) {
        print("==update search results")
        
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            filteredRestaurants = favoriteRestaurants.filter { restaurant in
                //print("filtered: \(filteredRestaurants)")
                
                return restaurant.name!.lowercased().contains(inputText.lowercased())
            }
        }
        //searchResultsVC?.filteredRestaurants = filteredRestaurants
    }
    */
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let resultsVC = segue.destination as? ResultsViewController, segue.identifier == "searchToResultss" {
            if let restaurant = sender as? FavoriteTableViewCell {
                resultsVC.getResults(name: restaurant.textLabel?.text, price: restaurant.price, rating: restaurant.rating, reviewCount: restaurant.reviewCount, url: restaurant.url, address: restaurant.address, coordinate: restaurant.coordinate, totalBiz: 0, randomNo: 0, category: restaurant.category)
            }
        }
    }
}
