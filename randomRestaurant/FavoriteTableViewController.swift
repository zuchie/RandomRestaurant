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
    
    //var favRestaurant: SlotMachineViewController.Restaurant?

    override func viewDidLoad() {
        super.viewDidLoad()

        let restaurant = SlotMachineViewController.pickedRestaurant
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        updateDatabase(restaurant!)
    }
    
    
    //var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    // MARK: Model
    
    private func updateUI() {
        if let context = managedObjectContext {
            let request = NSFetchRequest(entityName: "Restaurant")
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

    private func updateDatabase(newRestaurant: SlotMachineViewController.Restaurant) {
        managedObjectContext?.performBlock {
            
            _ = Restaurant.restaurant(newRestaurant, inManagedObjectContext: self.managedObjectContext!)
            
            // Save context to database.
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core data error: \(error)")
            }
            
            self.updateUI()
        }

        //printFavoriteRestaurant()
        //updateUI()
    }
    /*
    private func printFavoriteRestaurant() {
        managedObjectContext?.performBlock {
            if let results = try? self.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Restaurant")).first {
                print("fav restaurant: \(results!)")
            }
        }
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellID = "favorite"
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)

        // Configure the cell...
        if let favRestaurant = fetchedResultsController?.objectAtIndexPath(indexPath) as? Restaurant {
            var name: String?
            var address: String?
            favRestaurant.managedObjectContext?.performBlockAndWait {
                name = favRestaurant.name
                address = favRestaurant.address
            }
            cell.textLabel?.text = "\(name!), \(address!)"
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
