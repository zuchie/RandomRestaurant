//
//  History.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/21/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import CoreData

class History: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    class func history(restaurant: SlotMachineViewController.Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        
        let request = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", restaurant.name!)
        
        if let restaurantFound = (try? context.executeFetchRequest(request))?.first as? History {
            
            return restaurantFound
        } else if let newRestaurant = NSEntityDescription.insertNewObjectForEntityForName("History", inManagedObjectContext: context) as? History {
            
            newRestaurant.name = restaurant.name
            newRestaurant.price = restaurant.price
            newRestaurant.rating = restaurant.rating
            newRestaurant.reviewCount = restaurant.reviewCount
            newRestaurant.address = restaurant.address
            newRestaurant.isFavorite = restaurant.isFavorite
            newRestaurant.date = restaurant.date
            //print("new rest: \(newRestaurant)")
            return newRestaurant
        }
        
        return nil
    }
 
    class func updateState(restaurant: SlotMachineViewController.Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        
        let request = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", restaurant.name!)
        
        if let restaurantFound = (try? context.executeFetchRequest(request))?.first as? History {
            print("update restaurant state")
            restaurantFound.isFavorite = restaurant.isFavorite
            return restaurantFound
        }
        
        return nil
    }
}
