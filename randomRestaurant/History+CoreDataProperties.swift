//
//  History+CoreDataProperties.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 1/31/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History");
    }

    @NSManaged public var address: String?
    @NSManaged public var date: NSNumber?
    @NSManaged public var isFavorite: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var price: String?
    @NSManaged public var rating: String?
    @NSManaged public var reviewCount: String?
    @NSManaged public var url: String?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var category: String?

}
