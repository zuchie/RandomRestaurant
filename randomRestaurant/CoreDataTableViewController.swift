//
//  CoreDataTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/17/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var fetchedResultsController: NSFetchedResultsController? {
        didSet {
            do {
                if let frc = fetchedResultsController {
                    frc.delegate = self
                    try frc.performFetch()
                }
                tableView.reloadData()
            } catch let error {
                print("NSFetchedResultsController.performFetch() failed: \(error)")
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchedResultsController?.sections where sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("table view begin updates")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert: tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                        print("insert section: \(sectionIndex)")
        case .Delete: tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                        print("delete section: \(sectionIndex)")
        default: break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            print("insert row \(newIndexPath!.row)")
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            print("delete row \(indexPath!.row)")
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            print("update row \(indexPath!.row)")
        case .Move:
            print("move row \(indexPath!.row) to row \(newIndexPath!.row)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("table view end updates")
        tableView.endUpdates()
    }

}
