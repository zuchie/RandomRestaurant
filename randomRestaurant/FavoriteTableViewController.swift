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
        
        favoriteRestaurants.removeAll()
        
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
        }

        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredRestaurants = favoriteRestaurants.filter { restaurant in
            return restaurant.name!.lowercased().contains(searchText.lowercased())
        }
        
        if filteredRestaurants.count == 0 {
            searchActive = false
        } else {
            searchActive = true
        }
        
        tableView.reloadData()
    }


    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive && searchBar.text != "" {
            return filteredRestaurants.count
        } else {
            return favoriteRestaurants.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "favorite"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FavoriteTableViewCell
        
        // Configure the cell...
        let restau: Restaurant
        
        if searchActive && searchBar.text != "" {
            restau = filteredRestaurants[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = restau.name
        } else {
            
            restau = favoriteRestaurants[(indexPath as NSIndexPath).row]
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
        self.navigationController?.pushViewController(SlotMachineViewController.resultsVC, animated: true)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let cell = tableView.cellForRow(at: indexPath) {
                // Remove star from History table cell.
                print("delete favorite cell: \((cell.textLabel?.text)!)")
                favoriteRestaurants.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
