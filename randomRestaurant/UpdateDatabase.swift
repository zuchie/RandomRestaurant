//
//  UpdateDatabase.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/29/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData

class DataBase {
    
    static var managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    
    class func add(_ instance: Restaurant, to entity: String) {
        managedObjectContext?.performAndWait {
            
            if entity == "history" {
                _ = History.addNew(instance, inManagedObjectContext: self.managedObjectContext!)
                let count = History.countEntityInstances(inManagedObjectContext: self.managedObjectContext!)
                if count > 30 {
                    // Delete the first instance.
                    print("DB to delete first instance")
                    History.deleteFirst(inManagedObjectContext: managedObjectContext!)
                }
            } else if entity == "favorite" {
                print("DB trying to add instance to favorite entity")
                 _ = Favorite.addNew(instance, inManagedObjectContext: self.managedObjectContext!)
            } else {
                print("Error entity type")
                return
            }
            
            print("context has any changes? \(self.managedObjectContext?.hasChanges)")
            if (self.managedObjectContext?.hasChanges)! {
                // Save context to database.
                do {
                    try self.managedObjectContext?.save()
                    print("context saved")
                } catch let error {
                    print("Core data error: \(error)")
                }
            }
        }
    }
    
    class func retrieve(_ instance: Restaurant, in entity: String) -> Restaurant {
        var found: History?
        let restaurant = Restaurant()!
        managedObjectContext?.performAndWait {
            if entity == "history" {
                found = History.retrieve(instance, inManagedObjectContext: self.managedObjectContext!)!
                print("DB retrieved instance in history entity")
            }
        }
        restaurant.name = found?.name
        restaurant.address = found?.address
        restaurant.category = found?.category
        restaurant.date = found?.date?.intValue
        restaurant.isFavorite = found?.isFavorite?.boolValue
        restaurant.latitude = found?.latitude?.doubleValue
        restaurant.longitude = found?.longitude?.doubleValue
        restaurant.price = found?.price
        restaurant.rating = found?.rating
        restaurant.reviewCount = found?.reviewCount
        restaurant.url = found?.url
        
        return restaurant
    }
    
    class func updateInstanceState(_ instance: Restaurant, in entity: String) {
        managedObjectContext?.performAndWait {
            if entity == "history" {
                _ = History.updateState(instance, inManagedObjectContext: self.managedObjectContext!)
            } else {
                print("instance is not History type")
                return
            }
            
            print("context has any changes? \(self.managedObjectContext?.hasChanges)")
            if (self.managedObjectContext?.hasChanges)! {
                // Save context to database.
                do {
                    try self.managedObjectContext?.save()
                    print("context saved")
                } catch let error {
                    print("Core data error: \(error)")
                }
            }
        }
    }
    
    class func delete(_ instance: Restaurant, in entity: String) {
        print("delete instance")
        managedObjectContext?.performAndWait {
            if entity == "favorite" {
                Favorite.delete(instance, inManagedObjectContext: self.managedObjectContext!)
            }
            print("context has any changes? \(self.managedObjectContext?.hasChanges)")
            if (self.managedObjectContext?.hasChanges)! {
                // Save context to database.
                do {
                    try self.managedObjectContext?.save()
                    print("context saved")
                } catch let error {
                    print("Core data error: \(error)")
                }
            }
        }
    }

}
