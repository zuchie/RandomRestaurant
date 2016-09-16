//
//  Restaurant.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/15/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation
import CoreData

class Restaurant: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    class func restaurant(restaurant: SlotMachineViewController.restaurant, inManagedObjectContext context: NSManagedObjectContext) -> Restaurant? {
        
        let request = NSFetchRequest(entityName: "Restaurant")
        request.predicate = NSPredicate(format: "name = %@", restaurant.name!)
        
        if let restaurant = (try? context.executeFetchRequest(request))?.first as? Restaurant {
            print("found entry in core data")
            return restaurant
        } else if let newRestaurant = NSEntityDescription.insertNewObjectForEntityForName("Restaurant", inManagedObjectContext: context) as? Restaurant {
            print("new entry added to core data")
            newRestaurant.name = restaurant.name
            newRestaurant.price = restaurant.price
            newRestaurant.rating = restaurant.rating
            newRestaurant.reviewCount = restaurant.reviewCount
            newRestaurant.address = restaurant.address
            return newRestaurant
        }
        
        return nil
    }

}
