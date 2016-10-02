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
    
    private var favoriteRestaurant: FavoriteTableViewController?
    private var historyRest = Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("history view did load")
        
        favoriteRestaurant = SlotMachineViewController.favoriteTableVC
        
    }
    
    // Fetch data from DB and reload table view.
    func updateUI() {
        if let context = HistoryDB.managedObjectContext {
            let request = NSFetchRequest(entityName: "History")
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            print("updating history UI")
            
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

    func removeFromFavorites(name: String) {
        let restaurant = Restaurant()
        restaurant!.name = name
        restaurant!.isFavorite = false
        
        HistoryDB.updateEntryState(restaurant!)
        updateUI()
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //print("history cell section: \(indexPath.section) row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCellWithIdentifier("history", forIndexPath: indexPath) as! HistoryTableViewCell
        
        // Configure the cell...
        if let historyRestaurant = fetchedResultsController?.objectAtIndexPath(indexPath) as? History {
            var name: String?
            var isFavorite: Bool?
            
            historyRestaurant.managedObjectContext?.performBlockAndWait {
                name = historyRestaurant.name
                isFavorite = historyRestaurant.isFavorite?.boolValue
            }
            cell.addToFav.selected = isFavorite!
            cell.historyLabel.text = name
            
            cell.addToFav.cellText = cell.historyLabel.text
            cell.addToFav.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: .TouchDown)
        }
        
        return cell
    }
    
    private func updateButtonStatus(button: UIButton) {

        if button.selected == false {
            button.selected = true
        } else {
            button.selected = false
        }
    }
    
    func buttonTapped(sender: HistoryCellButton) {
        
        // Pass to favorite restaurant database.
        historyRest!.name = sender.cellText
        historyRest!.price = ""
        historyRest!.address = ""
        historyRest!.rating = ""
        historyRest!.reviewCount = ""
        
        updateButtonStatus(sender)
        
        historyRest!.isFavorite = sender.selected
        
        HistoryDB.updateEntryState(historyRest!)
        updateUI()
        
        favoriteRestaurant!.updateUI()
        
    }

}
