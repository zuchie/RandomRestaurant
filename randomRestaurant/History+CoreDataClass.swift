//
//  History+CoreDataClass.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 1/27/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData


public class History: NSManagedObject {
    // Insert code here to add functionality to your managed object subclass
    class func addNew(_ instance: Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", instance.name!)
        
        if let instanceFound = (try? context.fetch(request))?.first as? History {
            print("found instance in history entity")
            return instanceFound
        } else if let newInstance = NSEntityDescription.insertNewObject(forEntityName: "History", into: context) as? History {
            print("add new instance to history entity")
            
            newInstance.name = instance.name
            newInstance.price = instance.price
            newInstance.rating = instance.rating
            newInstance.reviewCount = instance.reviewCount
            newInstance.address = instance.address
            newInstance.isFavorite = instance.isFavorite as NSNumber?
            newInstance.date = instance.date as NSNumber?
            newInstance.url = instance.url
            newInstance.latitude = instance.latitude as NSNumber?
            newInstance.longitude = instance.longitude as NSNumber?
            newInstance.category = instance.category
            
            return newInstance
        }
        
        return nil
    }
    
    class func retrieve(_ instance: Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", instance.name!)
        
        if let instanceFound = (try? context.fetch(request))?.first as? History {
            print("found instance in history entity")
            return instanceFound
        } else {
            print("didn't find instance")
            return nil
        }
    }
    
    class func updateState(_ instance: Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", instance.name!)
        
        if let instanceFound = (try? context.fetch(request))?.first as? History {
            instanceFound.isFavorite = instance.isFavorite as NSNumber?
            print("update instance state in history entity")
            
            return instanceFound
        }
        return nil
    }
    
    class func countEntityInstances(inManagedObjectContext context: NSManagedObjectContext) -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "History")
        var count: Int?
        
        do {
            try count = context.count(for: request)
        } catch let error {
            print("Count for Fetch Request error: \(error)")
        }
        
        return count!
    }
    
    class func deleteFirst(inManagedObjectContext context: NSManagedObjectContext) {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "History")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        if let restaurantFound = (try? context.fetch(request))?.first as? History {
            context.delete(restaurantFound)
        }
    }
    
}
