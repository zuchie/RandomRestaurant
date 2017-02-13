//
//  ObjectToObserve.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/13/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import Foundation
import UIKit


class MyObjectToObserve: NSObject {
    dynamic var myTableView = NSDate()
    func updateTableView() {
        myTableView = NSDate()
    }
}
