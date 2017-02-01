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

class FavoriteTableViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate var searchActive = false
    
    fileprivate var historyRestaurant: HistoryTableViewController?
    
    fileprivate var favoriteRestaurants = [Restaurant]()
    fileprivate var filteredRestaurants = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("favorite view did load")

        searchBar.delegate = self
        
        historyRestaurant = SlotMachineViewController.historyTableVC
        //fetchFavoritesFromHistoryDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFavoritesFromHistoryDB()
    }

    // MARK: Model
    fileprivate var fetchedResultsController: NSFetchedResultsController<History>? {
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
    
    fileprivate func fetchFavoritesFromHistoryDB() {
        if let context = HistoryDB.managedObjectContext {
            
            let request: NSFetchRequest<History> = NSFetchRequest(entityName: "History")
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
        print("here 0")
        favoriteRestaurants.removeAll()
        print("here 1")
        for obj in fetchedResultsController!.fetchedObjects! {
            let fetchedRestaurant = obj
            let restaurant = Restaurant()
            
            restaurant?.name = fetchedRestaurant.name
            restaurant?.price = fetchedRestaurant.price
            restaurant?.address = fetchedRestaurant.address
            restaurant?.rating = fetchedRestaurant.rating
            restaurant?.isFavorite = fetchedRestaurant.isFavorite?.boolValue
            restaurant?.reviewCount = fetchedRestaurant.reviewCount
            restaurant?.date = fetchedRestaurant.date?.intValue
            restaurant?.category = fetchedRestaurant.category
            restaurant?.latitude = fetchedRestaurant.latitude?.doubleValue
            restaurant?.longitude = fetchedRestaurant.longitude?.doubleValue
            restaurant?.url = fetchedRestaurant.url
            
            favoriteRestaurants.append(restaurant!)
            print("here 2")
        }

        print("here 3")
        tableView.reloadData()
        print("here 4")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("here 10")
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("here 11")
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("here 12")
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("here 13")
        searchActive = false;
    }
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredRestaurants = favoriteRestaurants.filter { restaurant in
            return restaurant.name!.lowercased().contains(searchText.lowercased())
        }
        
        if filteredRestaurants.count == 0 {
            print("here 14")
            searchActive = false
        } else {
            print("here 15")
            searchActive = true
        }
        
        tableView.reloadData()
    }


    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("search active \(searchActive), searchBar text \(searchBar.text)")
        if searchBar.text != "" {
            print("filter row count: \(filteredRestaurants.count)")
            return filteredRestaurants.count
        } else {
            print("fav row count: \(favoriteRestaurants.count)")

            return favoriteRestaurants.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "favorite"
        print("here 5")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FavoriteTableViewCell
        print("here 6")
        // Configure the cell...
        let restau: Restaurant
        
        print("1 search active \(searchActive), searchBar text \(searchBar.text)")
        if searchBar.text != "" {
            print("here **")
            restau = filteredRestaurants[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = restau.name
        } else {
            print("here ##")
            restau = favoriteRestaurants[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = restau.name
        }
        print("here 7")
        //print("restau url: \(restau.url), restau category: \(restau.category)")
        cell.url = restau.url
        cell.rating = restau.rating
        cell.reviewCount = restau.reviewCount
        cell.price = restau.price
        cell.address = restau.address
        cell.coordinate = CLLocationCoordinate2DMake(restau.latitude!, restau.longitude!)
        cell.category = restau.category
        print("here 8")
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
                    if restaurant.name == cell.textLabel?.text {
                        favoriteRestaurants.remove(at: index)
                    }
                }
                // Delete from filtered.
                for (index, restaurant) in filteredRestaurants.enumerated() {
                    if restaurant.name == cell.textLabel?.text {
                        filteredRestaurants.remove(at: index)
                    }
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
