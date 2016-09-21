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
    
    //private var favToBeDeleted: Favorite?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let restaurant = SlotMachineViewController.pickedRestaurant
        //updateDatabase(restaurant!)
        //favToBeDeleted = Favorite()
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

    func updateDatabase(newRestaurant: SlotMachineViewController.Restaurant) {
        managedObjectContext?.performBlock {
            
            _ = Favorite.favorite(newRestaurant, inManagedObjectContext: self.managedObjectContext!)
            
            // Save context to database.
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core data error: \(error)")
            }
            
            self.updateUI()
        }
    }
    
    func deleteFromDatabase(fav: Favorite) {

        /*
        print("delete from database, name: \(history.name)")
        let favToBeDeleted = Favorite()
        print("hello")
        favToBeDeleted.name = history.name
        favToBeDeleted.price = history.price
        favToBeDeleted.rating = history.rating
        favToBeDeleted.reviewCount = history.reviewCount
        favToBeDeleted.address = history.address
        
        managedObjectContext?.deleteObject(favToBeDeleted)
        */
        managedObjectContext?.deleteObject(fav)
        // Save context to database.
        do {
            try self.managedObjectContext?.save()
        } catch let error {
            print("Core data deleting error: \(error)")
        }
        
        self.updateUI()
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
}
