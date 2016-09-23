//
//  FavoriteTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/11/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class FavoriteTableViewController: CoreDataTableViewController {
    
    private var historyRestaurant: HistoryTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        historyRestaurant = HistoryTableViewController()
        updateUI()
    }
    
    
    // MARK: Model
    private func updateUI() {
        
        if let context = managedObjectContext {
            
            let request = NSFetchRequest(entityName: "Favorite")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
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

    func addToDatabase(newRestaurant: SlotMachineViewController.Restaurant) {
        
        managedObjectContext?.performBlock {
            
            _ = Favorite.addFavorite(newRestaurant, inManagedObjectContext: self.managedObjectContext!)
            
            // Save context to database.
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core data error: \(error)")
            }
            
            self.updateUI()
        }
    }
    
    func deleteFromDatabase(fav: SlotMachineViewController.Restaurant) {

        managedObjectContext?.performBlock {
            
            let restaurant = Favorite.getFavorite(fav, inManagedObjectContext: self.managedObjectContext!)
            
            self.managedObjectContext?.deleteObject(restaurant!)
            
            // Save context to database.
            do {
                try self.managedObjectContext?.save()
                
            } catch let error {
                print("Core data error: \(error)")
            }
            
            self.updateUI()
        }
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellID = "favorite"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)

        // Configure the cell...
        if let favRestaurant = fetchedResultsController?.objectAtIndexPath(indexPath) as? Favorite {
            var name: String?
            //var address: String?
            favRestaurant.managedObjectContext?.performBlockAndWait {
                name = favRestaurant.name
                //address = favRestaurant.address
            }
            cell.textLabel?.text = name
        }

        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            managedObjectContext?.performBlockAndWait {
                
                // Delete from database
                if let favRestaurant = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Favorite {
                    
                    // Remove star from History table cell.
                    self.historyRestaurant!.removeFromFavorites(favRestaurant.name!)
                    
                    self.managedObjectContext?.deleteObject(favRestaurant)
                    
                    // Save context to database.
                    do {
                        try self.managedObjectContext?.save()
                        
                    } catch let error {
                        print("Core data error: \(error)")
                    }
                    
                    self.updateUI()
                }
            }
            
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
    
}
