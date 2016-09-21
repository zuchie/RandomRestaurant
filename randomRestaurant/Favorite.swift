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
    
    // Insert code here to add functionality to your managed object subclass
    class func favorite(restaurantName: String, inManagedObjectContext context: NSManagedObjectContext) -> Favorite? {
        
        let request = NSFetchRequest(entityName: "Favorite")
        request.predicate = NSPredicate(format: "name = %@", restaurantName)
        
        if let restaurant = (try? context.executeFetchRequest(request))?.first as? Favorite {
            print("found entry in core data")
            return restaurant
        } else if let newRestaurant = NSEntityDescription.insertNewObjectForEntityForName("Favorite", inManagedObjectContext: context) as? Favorite {
            print("new entry added to core data")
            newRestaurant.name = restaurantName
            newRestaurant.price = ""
            newRestaurant.rating = ""
            newRestaurant.reviewCount = ""
            newRestaurant.address = ""
            return newRestaurant
        }
        
        return nil
    }
    
}
