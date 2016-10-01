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
    
    private var historyRest = SlotMachineViewController.Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("history view did load")
        
        updateUI()
    }
    
    private func updateUI() {
        
        if let context = HistoryDB.managedObjectContext {
            
            let request = NSFetchRequest(entityName: "History")
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            print("updating history UI")
            
            self.fetchedResultsController = NSFetchedResultsController(
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
        var restaurant = SlotMachineViewController.Restaurant()
        restaurant.name = name
        restaurant.isFavorite = false
        
        HistoryDB.updateEntryState(restaurant)
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("history cell section: \(indexPath.section) row: \(indexPath.row)")
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
        historyRest.name = sender.cellText
        historyRest.price = ""
        historyRest.address = ""
        historyRest.rating = ""
        historyRest.reviewCount = ""
        
        updateButtonStatus(sender)
        
        historyRest.isFavorite = sender.selected
        
        HistoryDB.updateEntryState(historyRest)
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
}
