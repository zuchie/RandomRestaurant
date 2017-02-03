//
//  Favorite+CoreDataClass.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/1/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData


public class Favorite: NSManagedObject {
    
    class func addNew(_ instance: Restaurant, inManagedObjectContext context: NSManagedObjectContext) -> Favorite? {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Favorite")
        request.predicate = NSPredicate(format: "name = %@", instance.name!)
        
        if let instanceFound = (try? context.fetch(request))?.first as? Favorite {
            print("found instance in favoirte entity")
            return instanceFound
            
        } else if let newInstance = NSEntityDescription.insertNewObject(forEntityName: "Favorite", into: context) as? Favorite {
            print("add new instance to favorite entity")
            
            newInstance.name = instance.name
            newInstance.price = instance.price
            newInstance.rating = instance.rating
            newInstance.reviewCount = instance.reviewCount
            newInstance.address = instance.address
            newInstance.date = instance.date as NSNumber?
            newInstance.url = instance.url
            newInstance.latitude = instance.latitude as NSNumber?
            newInstance.longitude = instance.longitude as NSNumber?
            newInstance.category = instance.category
            
            return newInstance
        }
        return nil
    }

    class func delete(_ instance: Restaurant, inManagedObjectContext context: NSManagedObjectContext) {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Favorite")
        request.predicate = NSPredicate(format: "name = %@", instance.name!)
        
        if let instanceFound = (try? context.fetch(request))?.first as? Favorite {
            context.delete(instanceFound)
        }
        print("deleted in favorite entity")
    }
    
}
