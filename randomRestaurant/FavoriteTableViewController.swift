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

class FavoriteTableViewController: CoreDataTableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    fileprivate var favoriteRestaurants = [Favorite]()
    fileprivate var filteredRestaurants = [Favorite]()
    
    fileprivate var searchResultsVC: SearchResultsTableViewController?
    fileprivate var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController()
        
        searchResultsVC = self.storyboard?.instantiateViewController(withIdentifier: "searchResultsVC") as? SearchResultsTableViewController
        
        //searchResultsVC = SearchResultsTableViewController()
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController?.searchResultsUpdater = self
        tableView.tableHeaderView = searchController?.searchBar
        definesPresentationContext = true
        
        searchController?.delegate = self
        
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = true
        searchController?.searchBar.searchBarStyle = .default
        searchController?.searchBar.sizeToFit()
    }
    
    // Fetch data from DB and reload table view.
    fileprivate func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        let categorySort = NSSortDescriptor(key: "category", ascending: true)
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [categorySort, nameSort]
        
        let moc = DataBase.managedObjectContext!
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: moc,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
    }
    
    fileprivate func removeFromFavorites(_ name: String) {
        let restaurant = Restaurant()
        restaurant!.name = name
        restaurant!.isFavorite = false
        
        DataBase.delete(restaurant!, in: "favorite")
        DataBase.updateInstanceState(restaurant!, in: "history")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "favorite"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FavoriteTableViewCell
        // Configure the cell...
        let restau: Favorite
        
        restau = fetchedResultsController?.sections?[indexPath.section].objects![indexPath.row] as! Favorite
        cell.textLabel?.text = restau.name
        
        //print("restau url: \(restau.url), restau category: \(restau.category)")
        cell.url = restau.url
        cell.rating = restau.rating
        cell.reviewCount = restau.reviewCount
        cell.price = restau.price
        cell.address = restau.address
        cell.coordinate = CLLocationCoordinate2DMake(restau.latitude!.doubleValue, restau.longitude!.doubleValue)
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
    override func tableView(_ tableView: UITableView, commit editingStyle:  UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let cell = tableView.cellForRow(at: indexPath) {
                // Remove from DB.
                removeFromFavorites((cell.textLabel?.text)!)
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
    
    // Method to conform to UISearchResultsUpdating protocol.
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            filteredRestaurants = favoriteRestaurants.filter { restaurant in
                //print("filtered: \(filteredRestaurants)")
                
                return restaurant.name!.lowercased().contains(inputText.lowercased())
            }
        }
        searchResultsVC?.filteredRestaurants = filteredRestaurants
    }
    
    // Notifications to hide/show navigation bar & segmented titles.
    func willPresentSearchController(_ searchController: UISearchController) {
        favoriteRestaurants.removeAll()
        for obj in (fetchedResultsController?.fetchedObjects)! {
            favoriteRestaurants.append(obj as! Favorite)
        }
        navigationController?.isNavigationBarHidden = true
        SlotMachineViewController.segmentedControl.isHidden = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationController?.isNavigationBarHidden = false
        SlotMachineViewController.segmentedControl.isHidden = false
    }

}
