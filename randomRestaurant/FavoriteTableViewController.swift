//
//  FavoriteTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class FavoriteTableViewController: CoreDataTableViewController {
    
    private var historyRestaurant: HistoryTableViewController?
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var restaurants = [Restaurant]()
    private var filteredRestaurants = [Restaurant]()
    private var restaurant = Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("favorite view did load")

        historyRestaurant = SlotMachineViewController.historyTableVC
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        /*
        restaurants.removeAll()
        for (_, rest) in fetchedResultsController!.fetchedObjects!.enumerate() {
            let fetchedRestaurant = rest as! History
            
            restaurant?.name = fetchedRestaurant.name
            restaurant?.price = fetchedRestaurant.price
            restaurant?.address = fetchedRestaurant.address
            restaurant?.rating = fetchedRestaurant.rating
            restaurant?.isFavorite = fetchedRestaurant.isFavorite?.boolValue
            restaurant?.reviewCount = fetchedRestaurant.reviewCount
            restaurant?.date = fetchedRestaurant.date?.integerValue
            
            restaurants.append(restaurant!)
            
            //tableView.reloadData()
        }
        */
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredRestaurants = restaurants.filter { restaurant in
            return restaurant.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    // MARK: Model
    func updateUI() {
        
        if let context = HistoryDB.managedObjectContext {
            
            let request = NSFetchRequest(entityName: "History")
            request.predicate = NSPredicate(format: "isFavorite == YES")
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
    }

    // MARK: - Table view data source
    /*
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active && searchController.searchBar.text != "" {
            return filteredRestaurants.count
        } else {
            return restaurants.count
        }
    }
    */
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellID = "favorite"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)

        // Configure the cell...
        let restau: Restaurant
        
        if searchController.active && searchController.searchBar.text != "" {
            restau = filteredRestaurants[indexPath.row]
            cell.textLabel?.text = restau.name
        } else {
            
            if let favRestaurant = fetchedResultsController?.objectAtIndexPath(indexPath) {
                var name: String?
                //var address: String?
                favRestaurant.managedObjectContext?.performBlockAndWait {
                    name = favRestaurant.name
                    //address = favRestaurant.address
                }
                cell.textLabel?.text = name
            }
        }

        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                // Remove star from History table cell.
                print("delete favorite cell: \((cell.textLabel?.text)!)")
                historyRestaurant!.removeFromFavorites((cell.textLabel?.text)!)
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
}

extension FavoriteTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
