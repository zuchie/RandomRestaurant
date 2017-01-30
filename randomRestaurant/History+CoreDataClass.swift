//
//  History+CoreDataClass.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 1/27/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import CoreData


public class History: NSManagedObject {
    // Insert code here to add functionality to your managed object subclass
    class func history(_ restaurant: Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", restaurant.name!)
        
        if let restaurantFound = (try? context.fetch(request))?.first as? History {
            
            print("found entry in database")
            
            return restaurantFound
        } else if let newRestaurant = NSEntityDescription.insertNewObject(forEntityName: "History", into: context) as? History {
            
            print("add new entry to database")
            
            newRestaurant.name = restaurant.name
            newRestaurant.price = restaurant.price
            newRestaurant.rating = restaurant.rating
            newRestaurant.reviewCount = restaurant.reviewCount
            newRestaurant.address = restaurant.address
            newRestaurant.isFavorite = restaurant.isFavorite as NSNumber?
            newRestaurant.date = restaurant.date as NSNumber?
            newRestaurant.url = restaurant.url
            
            return newRestaurant
        }
        
        return nil
    }
    
    class func updateState(_ restaurant: Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> History? {
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "History")
        request.predicate = NSPredicate(format: "name = %@", restaurant.name!)
        
        if let restaurantFound = (try? context.fetch(request))?.first as? History {
            restaurantFound.isFavorite = restaurant.isFavorite as NSNumber?
            print("update entry state in database")
            
            return restaurantFound
        }
        
        return nil
    }

}
