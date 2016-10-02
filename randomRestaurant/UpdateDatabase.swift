//
//  UpdateDatabase.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/29/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class HistoryDB {
    
    static var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    class func addEntry(entry: Restaurant) {
        managedObjectContext?.performBlockAndWait {
            
            _ = History.history(entry, inManagedObjectContext: self.managedObjectContext!)
            
            // Save context to database.
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core data error: \(error)")
            }
        }
    }
    
    class func updateEntryState(entry: Restaurant) {
        managedObjectContext?.performBlockAndWait {
            
            _ = History.updateState(entry, inManagedObjectContext: self.managedObjectContext!)
            
            // Save context to database.
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core data error: \(error)")
            }
            
        }
    }
}