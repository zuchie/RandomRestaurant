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

    private var favLabels = [String]()
    private var favVC: FavoriteTableViewController?
    
    private var historyRest = SlotMachineViewController.Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("history view did load")
        
        favVC = SlotMachineViewController.favoriteTableVC
        /*
        if let restaurant = SlotMachineViewController.pickedRestaurant {
            print("machine picked restaurant name: \(restaurant.name)")
            updateDatabase(restaurant)
        } else {
            updateUI()
        }
        */
        //updateUI()
    }

    private func updateUI() {
        
        if let context = managedObjectContext {
            
            let request = NSFetchRequest(entityName: "History")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
            print("updating history UI")
            
            // WHY here self.fetchedResultsController will trigger viewDidLoad()?
            self.fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
        } else {
            
            print("managedObjectContext is nil")
        }
        
    }
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    func updateDatabase(newRestaurant: SlotMachineViewController.Restaurant) {
        print("updating history database")
        managedObjectContext?.performBlock {
            
            _ = History.history(newRestaurant, inManagedObjectContext: self.managedObjectContext!)
            
            // Save context to database.
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core data error: \(error)")
            }
            //print("will update history UI")
            self.updateUI()
        }
    }
    
    func removeFromFavorites(name: String) {
        var restaurant = SlotMachineViewController.Restaurant()
        restaurant.name = name
        restaurant.isFavorite = false
        
        updateRestaurantState(restaurant)
    }
    
    private func updateRestaurantState(newRestaurant: SlotMachineViewController.Restaurant) {
        
        managedObjectContext?.performBlock {
            
            _ = History.updateState(newRestaurant, inManagedObjectContext: self.managedObjectContext!)
            
            // Save context to database.
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core data error: \(error)")
            }
            
            //self.updateUI()
        }
    }

    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // TOTHINK: Why need register? Search bar searching would crash without this.
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        print("history cell for row...")
        let cell = tableView.dequeueReusableCellWithIdentifier("history", forIndexPath: indexPath) as! HistoryTableViewCell
        
        cell.addToFav.index = indexPath.row
        cell.addToFav.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: .TouchDown)
        //cell.addToFav.setImage(emptyStar, forState: .Normal)
        //cell.addToFav.setImage(filledStar, forState: .Selected)
        
        // Configure the cell...
        if let historyRestaurant = fetchedResultsController?.objectAtIndexPath(indexPath) as? History {
            var name: String?
            var isFavorite: Bool?
            //var address: String?
            historyRestaurant.managedObjectContext?.performBlockAndWait {
                name = historyRestaurant.name
                isFavorite = historyRestaurant.isFavorite?.boolValue
                //print("rest: \(name), is fav? \(isFavorite)")
                //address = favRestaurant.address
            }
            cell.addToFav.selected = isFavorite!
            cell.historyLabel.text = name
            
            //favButtons.append(cell.addToFav)
            favLabels.append(cell.historyLabel.text!)
        }
        
        return cell
    }
    
    private func updateButtonStatus(button: UIButton) {
        //let index = favButtons.indexOf(button)

        if button.selected == false {
            //print("button normal")
            button.selected = true
            //favButtons[index!].selected = true
            
            favVC!.addToDatabase(historyRest)
        } else {
            //print("button selected")
            button.selected = false
            //favButtons[index!].selected = false

            favVC!.deleteFromDatabase(historyRest)
        }
    }
    
    func buttonTapped(sender: HistoryCellButton) {
        //let index = favButtons.indexOf(sender)
        let labelText = favLabels[sender.index!]
        
        //updateButtonStatus(sender)
        
        // Pass to favorite restaurant database.
        historyRest.name = labelText
        historyRest.price = ""
        historyRest.address = ""
        historyRest.rating = ""
        historyRest.reviewCount = ""
        
        updateButtonStatus(sender)
        
        historyRest.isFavorite = sender.selected
        
        updateRestaurantState(historyRest)
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
