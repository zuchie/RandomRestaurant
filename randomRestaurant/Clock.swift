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
        //var hourRad: Float?
        //var minuteRad: Float?
        //var isAM: Bool?
    }
    
    let calendar = Calendar.current
    let date = Date()
    
    //var trueTime = Time()
    var clockTime = Time()
    
    init() {
        /*
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
        */
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getClockDate(from hrRadDelta: Float, and minRadDelta: Float) -> Date {
        let hrDelta = Int(hrRadDelta * 6.0 / Float(Double.pi))
        let minDelta = Int(minRadDelta * 30.0 / Float(Double.pi))
        
        //print("clockTime hour: \(clockTime.hour!)")
        //print("hour delta: \(hrDelta)")
        clockTime.hour = clockTime.hour! + hrDelta
        clockTime.minute = clockTime.minute! + minDelta
        
        if clockTime.minute! >= 60 {
            //print("minute round back to 0")
            clockTime.minute = clockTime.minute! - 60
            clockTime.hour = clockTime.hour! + 1
        }
        if clockTime.minute! < 0 {
            clockTime.minute = clockTime.minute! + 60
            clockTime.hour = clockTime.hour! - 1
        }
        
        // Pass 0 instead of 24 to calendar to make it work.
        if clockTime.hour! >= 24 {
            clockTime.hour = clockTime.hour! - 24
        }
        if clockTime.hour! < 0 {
            clockTime.hour = clockTime.hour! + 24
        }

        print("**clockTime hour: \(clockTime.hour!)")
        print("**clockTime minute: \(clockTime.minute!)")

        let clockDate = calendar.date(bySettingHour: clockTime.hour!, minute: clockTime.minute!, second: 0, of: date)
        
        //print("clockDate: \(clockDate)")
        return clockDate!
    }
    
    // Get current clock arms angle.
    func getHourMinuteAnglesAMPM(from hr: Int, _ min: Int) -> (hour: Float, minute: Float, isAM: Bool) {
        //print("current Hour: Min: \(hour, minute)")
        let minuteArmAngle = Float(min) * Float(Double.pi) / 30.0
        //print("==hour: \(hr)")

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
        
        let hourArmAngle = Float(myHr) * Float(Double.pi) / 6.0 + minuteArmAngle / 12.0
        return (hourArmAngle, minuteArmAngle, isAM)
    }
    
    /*
    // Get Hour & Minutes from clock arms angle, angles have to be from 0 to 2PI.
    func getHourMinute(from hourRad: Float, _ minRad: Float, _ isAM: Bool) {
        var hour = Int(hourRad * 6.0 / Float(M_PI))
        let min = Int(minRad * 30.0 / Float(M_PI))
        
        // Plus 12 to PM Hours.
        if !isAM {
            hour += 12
        }
        
        clockTime.hourRad = hourRad
        clockTime.minuteRad = minRad
        clockTime.isAM = isAM
        clockTime.hour = hour
        clockTime.minute = min
    }
    */
}
