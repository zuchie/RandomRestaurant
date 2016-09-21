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
    
    private var favButtons = [UIButton]()
    private var favLabels = [String]()
    private var favVC = FavoriteTableViewController()
    private var historyRest = SlotMachineViewController.Restaurant()
    //private var favRest: Favorite?
    
    private let emptyStar = UIImage(named: "emptyStar")
    private let filledStar = UIImage(named: "filledStar")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let restaurant = SlotMachineViewController.pickedRestaurant {
            updateDatabase(restaurant)
        } else {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let context = managedObjectContext {
            let request = NSFetchRequest(entityName: "History")
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
            
            _ = History.history(newRestaurant, inManagedObjectContext: self.managedObjectContext!)
            
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
        
        // TOTHINK: Why need register? Search bar searching would crash without this.
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("history", forIndexPath: indexPath) as! HistoryTableViewCell
        
        cell.addToFav.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: .TouchDown)
        cell.addToFav.setImage(emptyStar, forState: .Normal)
        cell.addToFav.setImage(filledStar, forState: .Selected)
        
        // Configure the cell...
        if let historyRestaurant = fetchedResultsController?.objectAtIndexPath(indexPath) as? History {
            var name: String?
            //var address: String?
            historyRestaurant.managedObjectContext?.performBlockAndWait {
                name = historyRestaurant.name
                //address = favRestaurant.address
            }
            cell.historyLabel.text = name
            
            favButtons.append(cell.addToFav)
            favLabels.append(cell.historyLabel.text!)
        }
        
        return cell
    }
    
    private func updateButtonStatus(button: UIButton) {
        let index = favButtons.indexOf(button)

        if button.selected == false {
            print("button normal")
            button.selected = true
            favButtons[index!].selected = true
        } else {
            print("button selected")
            button.selected = false
            favButtons[index!].selected = false
            
            let favRest = Favorite()
            favRest.name = favLabels[index!]
            favRest.price = ""
            favRest.address = ""
            favRest.rating = ""
            favRest.reviewCount = ""
            favVC.deleteFromDatabase(favRest)
        }
    }
    
    func buttonTapped(sender: UIButton) {
        let index = favButtons.indexOf(sender)
        let labelText = favLabels[index!]
        
        updateButtonStatus(sender)
        
        // Pass to favorite restaurant database.
        historyRest.name = labelText
        historyRest.price = ""
        historyRest.address = ""
        historyRest.rating = ""
        historyRest.reviewCount = ""
        favVC.updateDatabase(historyRest)
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
