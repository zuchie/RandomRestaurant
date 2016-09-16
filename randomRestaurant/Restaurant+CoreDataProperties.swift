//
//  Restaurant+CoreDataProperties.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/15/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Restaurant {

    @NSManaged var name: String?
    @NSManaged var price: String?
    @NSManaged var rating: String?
    @NSManaged var reviewCount: String?
    @NSManaged var address: String?

}
