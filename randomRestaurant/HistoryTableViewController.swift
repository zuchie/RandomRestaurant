//
//  HistoryTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: CoreDataTableViewController {
    
    //fileprivate var favoriteRest = Restaurant()
    var favoriteVC = FavoriteTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
    }
    
    // Fetch data from DB..
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let moc = DataBase.managedObjectContext!
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //print("history cell section: \(indexPath.section) row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! HistoryTableViewCell
        
        // Configure the cell...
        if let fetched = fetchedResultsController?.object(at: indexPath) as? History {
            /*
            var name: String!
            var isFavorite: Bool!
            var url: String!
            var rating: String!
            var reviewCount: String!
            var price: String!
            var address: String!
            var coordinate: CLLocationCoordinate2D!
            var category: String!
 
            historyRestaurant.managedObjectContext?.performAndWait {
                name = historyRestaurant.name
                isFavorite = historyRestaurant.isFavorite?.boolValue
                url = historyRestaurant.url
                rating = historyRestaurant.rating
                reviewCount = historyRestaurant.reviewCount
                price = historyRestaurant.price
                address = historyRestaurant.address
                coordinate = CLLocationCoordinate2DMake((historyRestaurant.latitude?.doubleValue)!, (historyRestaurant.longitude?.doubleValue)!)
                category = historyRestaurant.category
            }
 
            cell.addToFav.isSelected = isFavorite!
            cell.historyLabel.text = name
            cell.url = url
            cell.rating = rating
            cell.reviewCount = reviewCount
            cell.price = price
            cell.address = address
            cell.coordinate = coordinate
            cell.category = category
            */
            
            //cell.restaurant = Restaurant(name: fetched.name!, price: fetched.price!, rating: fetched.rating!, reviewCount: fetched.reviewCount!, address: fetched.address!, isFavorite: (fetched.isFavorite?.boolValue)!, date: (fetched.date?.intValue)!, url: fetched.url!, latitude: (fetched.latitude?.doubleValue)!, longitude: (fetched.longitude?.doubleValue)!, category: fetched.category!)
            
            cell.historyLabel.text = fetched.name
            cell.favoriteButton.isSelected = (fetched.isFavorite?.boolValue)!
            
            cell.favoriteButton.restaurant = Restaurant(name: fetched.name!, price: fetched.price!, rating: fetched.rating!, reviewCount: fetched.reviewCount!, address: fetched.address!, url: fetched.url!, latitude: (fetched.latitude?.doubleValue)!, longitude: (fetched.longitude?.doubleValue)!, category: fetched.category!)
            
            cell.favoriteButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchDown)
            cell.favoriteButton.addTarget(favoriteVC, action: #selector(favoriteVC.updateDB(button:)), for: .touchDown)
        }
        
        return cell
    }
    
    fileprivate func updateButtonStatus(_ button: UIButton) {
        button.isSelected = button.isSelected ? false : true
    }
    
    func buttonTapped(_ sender: HistoryCellButton) {
        
        // Update database with isFavorite status change.
        //favoriteRest!.name = sender.cellText
        //let found = DataBase.retrieve(sender.restaurant!, in: "history")
        /*
        favoriteRest!.price = found.price
        favoriteRest!.address = found.address
        favoriteRest!.rating = found.rating
        favoriteRest!.reviewCount = found.reviewCount
        favoriteRest!.category = found.category
        favoriteRest!.date = found.date
        favoriteRest!.latitude = found.latitude
        favoriteRest!.longitude = found.longitude
        favoriteRest!.url = found.url
        */
        updateButtonStatus(sender)
        let restaurant = sender.restaurant
        restaurant?.isFavorite = sender.isSelected
        
        DataBase.updateInstanceState(restaurant!, in: "history")
        /*
        // Update favorite restaurant list and update table view.
        if found.isFavorite! {
            DataBase.add(favoriteRest!, to: "favorite")
        } else {
            DataBase.delete(favoriteRest!, in: "favorite")
        }
        */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ResultsViewController, segue.identifier == "recentsToResults" {
            if let cell = sender as? HistoryTableViewCell, let restaurant = cell.favoriteButton.restaurant {
                destinationVC.getResults(name: restaurant.name, price: restaurant.price, rating: restaurant.rating, reviewCount: restaurant.reviewCount, url: restaurant.url, address: restaurant.address, isFavorite: restaurant.isFavorite, latitude: restaurant.latitude, longitude: restaurant.longitude, totalBiz: 0, randomNo: 0, category: restaurant.category)
            }
        }
    }

}
