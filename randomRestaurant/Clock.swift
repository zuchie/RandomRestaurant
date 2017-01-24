//
//  Clock.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 12/9/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class Clock {
    
    struct Time {
        var hour: Int?
        var minute: Int?
        var hourRad: Float?
        var minuteRad: Float?
        var isAM: Bool?
    }
    
    let calendar = Calendar.current
    let date = Date()
    
    var trueTime = Time()
    var faceTime = Time()
    
    init() {
        trueTime.hour = calendar.component(.hour, from: date)
        trueTime.minute = calendar.component(.minute, from: date)
        
        let clockArmAngles = getHourMinuteAnglesAMPM(from: trueTime.hour!, trueTime.minute!)
        trueTime.hourRad = clockArmAngles.hour
        trueTime.minuteRad = clockArmAngles.minute
        trueTime.isAM = clockArmAngles.isAM
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.long
        
        let curDate = dateFormatter.string(from: date)
        
        print("current date: \(curDate)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Get current clock arms angle.
    private func getHourMinuteAnglesAMPM(from hr: Int, _ min: Int) -> (hour: Float, minute: Float, isAM: Bool) {
        //print("current Hour: Min: \(hour, minute)")
        let minuteArmAngle = Float(min) * Float(M_PI) / 30.0
        // Round Hour to less than 12.
        let isAM: Bool
        let myHr: Int
        if hr >= 12 {
            myHr = hr - 12
            isAM = false
        } else {
            myHr = hr
            isAM = true
        }
        
        let hourArmAngle = Float(myHr) * Float(M_PI) / 6.0 + minuteArmAngle / 12.0
        return (hourArmAngle, minuteArmAngle, isAM)
    }
    
    // Get Hour & Minutes from clock arms angle, angles have to be from 0 to 2PI.
    func getHourMinute(from hourRad: Float, _ minRad: Float, _ isAM: Bool) {
        var hour = Int(hourRad * 6.0 / Float(M_PI))
        let min = Int(minRad * 30.0 / Float(M_PI))
        
        // Plus 12 to PM Hours.
        if !isAM {
            hour += 12
        }
        
        faceTime.hourRad = hourRad
        faceTime.minuteRad = minRad
        faceTime.isAM = isAM
        faceTime.hour = hour
        faceTime.minute = min
    }
}
