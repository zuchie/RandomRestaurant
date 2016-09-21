//
//  History.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/18/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//


import Foundation
import CoreData

class History: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    class func history(restaurant: SlotMachineViewController.Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        
        let request = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", restaurant.name!)
        
        if let restaurant = (try? context.executeFetchRequest(request))?.first as? History {
            print("found entry in core data")
            return restaurant
        } else if let newRestaurant = NSEntityDescription.insertNewObjectForEntityForName("History", inManagedObjectContext: context) as? History {
            print("new entry added to core data")
            newRestaurant.name = restaurant.name
            newRestaurant.price = restaurant.price
            newRestaurant.rating = restaurant.rating
            newRestaurant.reviewCount = restaurant.reviewCount
            newRestaurant.address = restaurant.address
            print("new rest: \(newRestaurant)")
            return newRestaurant
        }
        
        return nil
    }
    
}
