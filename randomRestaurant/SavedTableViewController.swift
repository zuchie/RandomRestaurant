//
//  SavedTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class SavedTableViewController: CoreDataTableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    fileprivate var savedRestaurants = [SavedMO]()
    fileprivate var filteredRestaurants = [SavedMO]()
    
    fileprivate var searchResultsVC: UITableViewController!
    fileprivate var searchController: UISearchController!
    
    fileprivate var rowCount = 0 {
        willSet {
            if newValue == 0 {
                setEditing(false, animated: false)
                editButtonItem.isEnabled = false
            } else {
                editButtonItem.isEnabled = true
            }
        }
    }
    
    //fileprivate var shouldSegue: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem

        initializeFetchedResultsController()
        
        let nib = UINib(nibName: "SavedTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "savedCell")
        
        searchResultsVC = UITableViewController(style: .plain)
        //searchResultsVC = CoreDataTableViewController()
        searchResultsVC.tableView.register(nib, forCellReuseIdentifier: "savedCell")
        searchResultsVC.tableView.dataSource = self
        searchResultsVC.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchResultsUpdater = self
        tableView.tableHeaderView = searchController?.searchBar
        definesPresentationContext = true
        
        searchController.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.sizeToFit()
        
        /* [Warning] Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UISearchController: 0x10194f3e0>), Bug: UISearchController doesn't load its view until it's be deallocated. Reference: http://www.openradar.me/22250107
        */
        /*
        if #available(iOS 9.0, *) {
            searchController.loadViewIfNeeded()
        } else {
            let _ = searchController.view
        }
        */
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        shouldSegue = false
    }
    */
    /*
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
    */
    
    fileprivate func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Saved")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: MainTableViewController.moc!, sectionNameKeyPath: nil, cacheName: nil)
    }
 
    /*
    func updateDB(button: HistoryCellButton) {
        let restaurant = Restaurant()
        
        restaurant.name = (button.restaurant?.name)!
        restaurant.price = (button.restaurant?.price)!
        restaurant.address = (button.restaurant?.address)!
        restaurant.rating = (button.restaurant?.rating)!
        restaurant.reviewCount = (button.restaurant?.reviewCount)!
        restaurant.category = (button.restaurant?.category)!
        restaurant.latitude = (button.restaurant?.latitude)!
        restaurant.longitude = (button.restaurant?.longitude)!
        restaurant.url = (button.restaurant?.url)!
        
        if button.isSelected {
            DataBase.add(restaurant, to: "favorite")
        } else {
            DataBase.delete(restaurant, in: "favorite")
        }
    }
    */
    /*
    fileprivate func removeFromSaved(name: String) {
        let restaurant = Restaurant()
        restaurant.name = name
        
        DataBase.delete(restaurant, in: "favorite")
        DataBase.updateInstanceState(restaurant, in: "history")
    }
    */
    /*
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return shouldSegue
    }
    */
    
    fileprivate func updateSaved(cell: SavedTableViewCell) {
        
        let request: NSFetchRequest<SavedMO> = NSFetchRequest(entityName: "Saved")
        request.predicate = NSPredicate(format: "name == %@", cell.name.text!)
        
        guard let object = try? MainTableViewController.moc?.fetch(request).first else {
            fatalError("Error fetching from context")
        }
        
        guard let obj = object else {
            print("Didn't find object in context")
            return
        }
        
        MainTableViewController.moc?.delete(obj)
        print("Deleted from Saved entity")
        
        if let index = filteredRestaurants.index(of: obj) {
            filteredRestaurants.remove(at: index)
            searchResultsVC.tableView.reloadData()
            print("Deleted from filtered")
        }
        
        if (MainTableViewController.moc?.hasChanges)! {
            do {
                try MainTableViewController.moc?.save()
                print("context saved")
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    
    fileprivate func alert() {
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "No restaurant has been found.", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
        }))
        
        // Show the alert.
        self.present(alert, animated: false, completion: nil)
    }
    
    // MARK: - Table view data source
    
    fileprivate func configureCell(_ cell: SavedTableViewCell, _ object: SavedMO) {
        
        cell.name.text = object.name
        cell.categories.text = object.categories
        cell.yelpUrl = object.yelpUrl
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return fetchedResultsController?.sections?.count ?? 0
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            rowCount = fetchedResultsController?.sections?[section].numberOfObjects ?? 0
            return rowCount
        } else {
            return filteredRestaurants.count
        }
    }
    /*
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            return 0
        } else {
            return 40
        }
    }
    */
    /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView {
            return fetchedResultsController?.sections?[section].name.uppercased()
        } else {
            return "Restaurants found"
        }
    }
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let restaurant: SavedMO
        
        // Configure the cell...
        if tableView == self.tableView {
            guard let object = fetchedResultsController?.object(at: indexPath) as? SavedMO else {
                fatalError("Unexpected object in FetchedResultsController")
            }
            restaurant = object
        } else {
            restaurant = filteredRestaurants[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedCell", for: indexPath) as! SavedTableViewCell
        
        configureCell(cell, restaurant)
        
        return cell
    }
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 380.0
    }
    */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SavedTableViewCell else {
            fatalError("Unexpected indexPath: \(indexPath)")
        }
        
        guard let url = cell.yelpUrl else {
            fatalError("Unexpected url: \(String(describing: cell.yelpUrl))")
        }
        
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle:  UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let cell = tableView.cellForRow(at: indexPath) as? SavedTableViewCell else {
                fatalError("Unexpected indexPath: \(indexPath)")
            }
            // Remove from DB.
            updateSaved(cell: cell)

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    /*
    // Customize section header, make sure all the headers are rendered when they are inserted.
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.lightGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    */
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Method to conform to UISearchResultsUpdating protocol.
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            filteredRestaurants = savedRestaurants.filter {
                
                guard let name = $0.name,
                    let categories = $0.categories else {
                    print("No restaurant found")
                    return false
                }
                
                //print("rest: \($0)")
                return (name.lowercased().contains(inputText.lowercased()) || categories.lowercased().contains(inputText.lowercased()))
 
                //return ($0.name?.lowercased().contains(inputText.lowercased()))!
            }
            //print("filtered: \(filteredRestaurants)")
        }
        searchResultsVC.tableView.reloadData()
        //searchResultsVC?.filteredRestaurants = filteredRestaurants
    }
    
    // Notifications to hide/show navigation bar & segmented titles.
    func willPresentSearchController(_ searchController: UISearchController) {
        savedRestaurants.removeAll()
        for obj in (fetchedResultsController?.fetchedObjects)! {
            savedRestaurants.append(obj as! SavedMO)
        }
        //searchResultsVC?.favorites = savedRestaurants
        //navigationController?.isNavigationBarHidden = true
    }
    /*
    func willDismissSearchController(_ searchController: UISearchController) {
        //navigationController?.isNavigationBarHidden = false
    }
    */
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap" {

            guard let cell = sender as? MainAndSavedTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            let destinationVC = segue.destination

            if cell.address == "" {
                alert()
            } else {
                if let mapVC = destinationVC as? GoogleMapViewController {
                    
                    mapVC.setBizLocation(cell.address)
                    mapVC.setBizCoordinate2D(CLLocationCoordinate2DMake(cell.latitude
                        , cell.longitude))
                    mapVC.setBizName(cell.name.text!)
                    mapVC.setDepartureTime(Int(Date().timeIntervalSince1970))
                }
            }
        }
    }
    */
}
