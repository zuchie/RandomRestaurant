//
//  FavoriteTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class FavoriteTableViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var searchActive = false
    
    private var historyRestaurant: HistoryTableViewController?
    
    private var favoriteRestaurants = [Restaurant]()
    private var filteredRestaurants = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("favorite view did load")

        searchBar.delegate = self
        
        historyRestaurant = SlotMachineViewController.historyTableVC
        //fetchFavoritesFromHistoryDB()
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchFavoritesFromHistoryDB()
    }

    // MARK: Model
    private var fetchedResultsController: NSFetchedResultsController? {
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
    
    private func fetchFavoritesFromHistoryDB() {
        if let context = HistoryDB.managedObjectContext {
            
            let request = NSFetchRequest(entityName: "History")
            request.predicate = NSPredicate(format: "isFavorite == YES")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            print("fetch favorites from DB")
            
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
            let fetchedRestaurant = obj as! History
            let restaurant = Restaurant()
            
            restaurant?.name = fetchedRestaurant.name
            restaurant?.price = fetchedRestaurant.price
            restaurant?.address = fetchedRestaurant.address
            restaurant?.rating = fetchedRestaurant.rating
            restaurant?.isFavorite = fetchedRestaurant.isFavorite?.boolValue
            restaurant?.reviewCount = fetchedRestaurant.reviewCount
            restaurant?.date = fetchedRestaurant.date?.integerValue
            
            favoriteRestaurants.append(restaurant!)
        }

        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
 
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredRestaurants = favoriteRestaurants.filter { restaurant in
            return restaurant.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        if filteredRestaurants.count == 0 {
            searchActive = false
        } else {
            searchActive = true
        }
        
        tableView.reloadData()
    }


    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive && searchBar.text != "" {
            return filteredRestaurants.count
        } else {
            return favoriteRestaurants.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellID = "favorite"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
        
        // Configure the cell...
        let restau: Restaurant
        
        if searchActive && searchBar.text != "" {
            restau = filteredRestaurants[indexPath.row]
            cell.textLabel?.text = restau.name
        } else {
            
            restau = favoriteRestaurants[indexPath.row]
            cell.textLabel?.text = restau.name
        }

        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                // Remove star from History table cell.
                print("delete favorite cell: \((cell.textLabel?.text)!)")
                favoriteRestaurants.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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
