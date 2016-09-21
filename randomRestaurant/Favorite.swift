//
//  Favorite.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/18/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//


import Foundation
import CoreData

class Favorite: NSManagedObject {
    
    class func favorite(history: SlotMachineViewController.Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> Favorite? {
        
        let request = NSFetchRequest(entityName: "Favorite")
        request.predicate = NSPredicate(format: "name = %@", history.name!)
        
        if let restaurant = (try? context.executeFetchRequest(request))?.first as? Favorite {
            print("found entry in core data")
            return restaurant
        } else if let newRestaurant = NSEntityDescription.insertNewObjectForEntityForName("Favorite", inManagedObjectContext: context) as? Favorite {
            print("new entry added to core data")
            newRestaurant.name = history.name
            newRestaurant.price = history.price
            newRestaurant.rating = history.rating
            newRestaurant.reviewCount = history.reviewCount
            newRestaurant.address = history.address
            return newRestaurant
        }
        
        return nil
    }
    
}
