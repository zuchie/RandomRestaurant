//
//  Favorite+CoreDataProperties.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/1/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite");
    }

    @NSManaged public var address: String?
    @NSManaged public var category: String?
    @NSManaged public var date: NSNumber?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var price: String?
    @NSManaged public var rating: String?
    @NSManaged public var reviewCount: String?
    @NSManaged public var name: String?
    @NSManaged public var url: String?

}
