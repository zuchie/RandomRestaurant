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
    class func history(restaurant: Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        
        let request = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", restaurant.name!)
        
        if let restaurantFound = (try? context.executeFetchRequest(request))?.first as? History {
            
            print("found entry in database")

            return restaurantFound
        } else if let newRestaurant = NSEntityDescription.insertNewObjectForEntityForName("History", inManagedObjectContext: context) as? History {

            print("add new entry to database")

            newRestaurant.name = restaurant.name
            newRestaurant.price = restaurant.price
            newRestaurant.rating = restaurant.rating
            newRestaurant.reviewCount = restaurant.reviewCount
            newRestaurant.address = restaurant.address
            newRestaurant.isFavorite = restaurant.isFavorite
            newRestaurant.date = restaurant.date
            
            return newRestaurant
        }
        
        return nil
    }
 
    class func updateState(restaurant: Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        
        let request = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", restaurant.name!)
        
        if let restaurantFound = (try? context.executeFetchRequest(request))?.first as? History {
            restaurantFound.isFavorite = restaurant.isFavorite
            print("update entry state in database")

            return restaurantFound
        }
        
        return nil
    }
}
