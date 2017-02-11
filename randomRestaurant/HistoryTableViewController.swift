//
//  HistoryTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class HistoryTableViewController: CoreDataTableViewController {
    
    //private var favoriteRestaurant: FavoriteTableViewController?
    fileprivate var favoriteRest = Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("history view did load")
        
        //favoriteRestaurant = SlotMachineViewController.favoriteTableVC
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

    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.navigationBar.topItem?.title = "History"
    }
    */
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //print("history cell section: \(indexPath.section) row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! HistoryTableViewCell
        
        // Configure the cell...
        if let historyRestaurant = fetchedResultsController?.object(at: indexPath) as? History {
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
            
            cell.addToFav.cellText = cell.historyLabel.text
            cell.addToFav.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchDown)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HistoryTableViewCell
        
        // Get results.
        SlotMachineViewController.resultsVC.getResults(name: cell.historyLabel.text, price: cell.price, rating: cell.rating, reviewCount: cell.reviewCount, url: cell.url, address: cell.address, coordinate: cell.coordinate, totalBiz: 0, randomNo: 0, category: cell.category)
        
        //self.present(SlotMachineViewController.resultsVC, animated: false, completion: nil)
        self.navigationController?.pushViewController(SlotMachineViewController.resultsVC, animated: false)
    }
    
    fileprivate func updateButtonStatus(_ button: UIButton) {

        if button.isSelected == false {
            button.isSelected = true
        } else {
            button.isSelected = false
        }
    }
    
    func buttonTapped(_ sender: HistoryCellButton) {
        
        // Update database with isFavorite status change.
        favoriteRest!.name = sender.cellText
        
        let found = DataBase.retrieve(favoriteRest!, in: "history")
        
        favoriteRest!.price = found.price
        favoriteRest!.address = found.address
        favoriteRest!.rating = found.rating
        favoriteRest!.reviewCount = found.reviewCount
        favoriteRest!.category = found.category
        favoriteRest!.date = found.date
        favoriteRest!.latitude = found.latitude
        favoriteRest!.longitude = found.longitude
        favoriteRest!.url = found.url
        
        updateButtonStatus(sender)
        found.isFavorite = sender.isSelected
        
        DataBase.updateInstanceState(found, in: "history")
        //updateUI()
        
        // Update favorite restaurant list and update table view.
        if found.isFavorite! {
            DataBase.add(favoriteRest!, to: "favorite")
        } else {
            DataBase.delete(favoriteRest!, in: "favorite")
        }
    }

}
