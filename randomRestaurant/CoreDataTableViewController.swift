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

    var fetchedResultsController: NSFetchedResultsController<History>? {
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchedResultsController?.sections , sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("table view begin updates")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                        print("insert section: \(sectionIndex)")
        case .delete: tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                        print("delete section: \(sectionIndex)")
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            print("insert row \((newIndexPath! as NSIndexPath).row)")
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            print("delete row \((indexPath! as NSIndexPath).row)")
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            print("update row \((indexPath! as NSIndexPath).row)")
        case .move:
            print("move row \((indexPath! as NSIndexPath).row) to row \((newIndexPath! as NSIndexPath).row)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("table view end updates")
        tableView.endUpdates()
    }

}
