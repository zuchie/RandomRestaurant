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
            newRestaurant.latitude = restaurant.latitude as NSNumber?
            newRestaurant.longitude = restaurant.longitude as NSNumber?
            newRestaurant.category = restaurant.category
            
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
        if let restaurantFound = (try? context.fetch(request))?.first as? History {
            context.delete(restaurantFound)
        }
    }
    
}
