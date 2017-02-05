//
//  FavoriteTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class FavoriteTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate var historyRestaurant: HistoryTableViewController?
    
    //fileprivate var favoriteRestaurants = [Restaurant]()
    //fileprivate var filteredRestaurants = [Restaurant]()
    
    fileprivate var favoriteRestaurants = [(category: String, restaurants: [Restaurant])]()
    fileprivate var filteredRestaurants = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("favorite view did load")

        searchBar.delegate = self
        
        historyRestaurant = SlotMachineViewController.historyTableVC
        //updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    // Fetch data from DB and reload table view.
    fileprivate func updateUI() {
        if let context = DataBase.managedObjectContext {
            let request = NSFetchRequest<Favorite>(entityName: "Favorite")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            print("updating favorite UI")
            
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
        } else {
            fetchedResultsController = nil
            print("managedObjectContext is nil")
        }
        
        favoriteRestaurants.removeAll()
        
        for obj in fetchedResultsController!.fetchedObjects! {
            let fetchedRestaurant = obj
            let restaurant = Restaurant()
            
            restaurant?.name = fetchedRestaurant.name
            restaurant?.price = fetchedRestaurant.price
            restaurant?.address = fetchedRestaurant.address
            restaurant?.rating = fetchedRestaurant.rating
            restaurant?.reviewCount = fetchedRestaurant.reviewCount
            restaurant?.date = fetchedRestaurant.date?.intValue
            restaurant?.category = fetchedRestaurant.category
            restaurant?.latitude = fetchedRestaurant.latitude?.doubleValue
            restaurant?.longitude = fetchedRestaurant.longitude?.doubleValue
            restaurant?.url = fetchedRestaurant.url
            restaurant?.isFavorite = nil
            
            var newCategory = true
            //favoriteRestaurants.append(restaurant!)
            for (index, member) in favoriteRestaurants.enumerated() {
                if restaurant?.category == member.category {
                    newCategory = false
                    favoriteRestaurants[index].restaurants.append(restaurant!)
                }
            }
            if newCategory {
                favoriteRestaurants.append((category: (restaurant?.category)!, restaurants: [restaurant!]))
            }
        }
        tableView.reloadData()
    }
    
    // MARK: Model
    fileprivate var fetchedResultsController: NSFetchedResultsController<Favorite>? {
        didSet {
            do {
                if let frc = fetchedResultsController {
                    frc.delegate = self
                    try frc.performFetch()
                }
                //tableView.reloadData()
            } catch let error {
                print("NSFetchedResultsController.performFetch() failed: \(error)")
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /*
         filteredRestaurants = favoriteRestaurants.filter { restaurant in
         for member in restaurant.restaurants {
         result = member.name!.lowercased().contains(searchText.lowercased())
         }
         return result!
         }
         */
        var filtered = [Restaurant]()
        for member in favoriteRestaurants {
            for restaurant in member.restaurants {
                filtered.append(restaurant)
            }
        }
        
        filteredRestaurants = filtered.filter { restaurant in
            return restaurant.name!.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchBar.text != "" {
            return 1
        } else {
            print("number of sections: \(favoriteRestaurants.count)")
            return favoriteRestaurants.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBar.text != "" {
            return filteredRestaurants.count
        } else {
            return favoriteRestaurants[section].restaurants.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchBar.text != "" {
        
            return nil
        
        } else {
            if section < favoriteRestaurants.count {
                return favoriteRestaurants[section].category.uppercased()
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "favorite"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FavoriteTableViewCell
        // Configure the cell...
        let restau: Restaurant
        
        if searchBar.text != "" {
            restau = filteredRestaurants[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = restau.name
        } else {
            restau = favoriteRestaurants[(indexPath as NSIndexPath).section].restaurants[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = restau.name
        }
        //print("restau url: \(restau.url), restau category: \(restau.category)")
        cell.url = restau.url
        cell.rating = restau.rating
        cell.reviewCount = restau.reviewCount
        cell.price = restau.price
        cell.address = restau.address
        cell.coordinate = CLLocationCoordinate2DMake(restau.latitude!, restau.longitude!)
        cell.category = restau.category
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteTableViewCell
        
        // Get results.
        SlotMachineViewController.resultsVC.getResults(name: cell.textLabel?.text, price: cell.price, rating: cell.rating, reviewCount: cell.reviewCount, url: cell.url, address: cell.address, coordinate: cell.coordinate, totalBiz: 0, randomNo: 0, category: cell.category)
        
        //self.present(SlotMachineViewController.resultsVC, animated: false, completion: nil)
        self.navigationController?.pushViewController(SlotMachineViewController.resultsVC, animated: false)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let cell = tableView.cellForRow(at: indexPath) {
                // Remove star from History table cell.
                //print("delete from favorite and filtered: \((cell.textLabel?.text)!)")
                // Delete from favorite.
                for (index, restaurant) in favoriteRestaurants.enumerated() {
                    for (idx, member) in restaurant.restaurants.enumerated() {
                        if member.name == cell.textLabel?.text {
                            print("remove at: \(indexPath.section, indexPath.row)")
                            favoriteRestaurants[index].restaurants.remove(at: idx)
                            print("index: \(index)")
                        }
                    }
                    /*
                    // Delete section when there is no members in it.
                    if restaurant.restaurants.count == 0 {
                        favoriteRestaurants.remove(at: index)
                    }
                    */
                }
                // Delete from filtered.
                for (index, restaurant) in filteredRestaurants.enumerated() {
                    
                    if restaurant.name == cell.textLabel?.text {
                        filteredRestaurants.remove(at: index)
                    }
                    
                    /*
                     // Delete section when there is no members in it.
                     if filteredRestaurants[index].restaurants.count == 0 {
                     filteredRestaurants.remove(at: index)
                     }
                     */
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                // Remove from DB.
                historyRestaurant!.removeFromFavorites((cell.textLabel?.text)!)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

}
