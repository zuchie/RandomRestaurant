//
//  Clock.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 12/9/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class Clock {
    private var hour: Int {
        set {
            self.hour = newValue
        }
        get {
            return self.hour
        }
    }
    private var minute: Int {
        set {
            self.minute = newValue
        }
        get {
            return self.minute
        }
    }
    private var hourArmRad: Float {
        set {
            self.hourArmRad = newValue
        }
        get {
            return self.hourArmRad
        }
    }
    private var minuteArmRad: Float {
        set {
            self.minuteArmRad = newValue
        }
        get {
            return self.minuteArmRad
        }
    }
    private var isAm: Bool?
    
    init() {
        let calendar = Calendar.current
        let date = Date()

        hour = calendar.component(.hour, from: date)
        minute = calendar.component(.minute, from: date)
        
        if hour < 12 {
            isAm = true
        } else {
            isAm = false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.long
        
        let curDate = dateFormatter.string(from: date)
        
        print("current date: \(curDate)")
    }
}
