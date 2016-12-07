//
//  DateViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 12/2/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class DateViewController: UIViewController {

    @IBOutlet weak var clockArmHour: UIImageView!
    @IBOutlet weak var clockArmHourWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockArmHourHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var clockArmMinute: UIImageView!
    @IBOutlet weak var clockArmMinuteWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockArmMinuteHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var clockDial: UIImageView!
    
    // Angle by radian.
    private var clockArmHourAngle: CGFloat?
    private var clockArmMinuteAngle: CGFloat?
    
    private var hourArmToXAxisAngle: CGFloat = CGFloat(M_PI / 2)
    
    let calendar = Calendar.current
    let currentDate = Date()
    
    private var currentHour: Int?
    private var currentMinute: Int?
    
    private var clockDialWidth: CGFloat?
    private var clockDialHeight: CGFloat?

    @IBAction func handleHourArmRotation(_ sender: UIPanGestureRecognizer) {
        let touchPosition = sender.location(in: clockDial)
        // Move coordinate system from upperleft corner to center.
        let touchPositionToCenterX = touchPosition.x - clockDialWidth! / 2
        let touchPositionToCenterY = touchPosition.y - clockDialHeight! / 2
        // Get touch position angle.
        clockArmHourAngle = atan2(touchPositionToCenterY, touchPositionToCenterX) + hourArmToXAxisAngle
        clockArmMinuteAngle = getClockMinuteArmAngle(by: clockArmHourAngle!)
        
        // Rotate clock arms.
        self.clockArmHour.transform = CGAffineTransform(rotationAngle: clockArmHourAngle!)
        self.clockArmMinute.transform = CGAffineTransform(rotationAngle: clockArmMinuteAngle!)
        
        print("hour angle: \(clockArmHourAngle! * (180.0 / CGFloat(M_PI))), min angle: \(clockArmMinuteAngle! * (180.0 / CGFloat(M_PI)))")
        
        /*
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: [],
            animations: {
                    self.clockArmHour.transform = CGAffineTransform(rotationAngle: clockArmHourAngle!)
        },
            completion: { finished in
                if finished {
                    print("animation done")
                }
        })
        */
    }

    private func getClockMinuteArmAngle(by clockHourArmAngle: CGFloat) -> CGFloat {
        let minuteToHourAngularVelocity: CGFloat = 12.0
        return clockHourArmAngle * minuteToHourAngularVelocity
    }
    
    private func getCurrentDate() {
        currentHour = calendar.component(.hour, from: currentDate)
        currentMinute = calendar.component(.minute, from: currentDate)
        let currentSecond = calendar.component(.second, from: currentDate)
        
        print("current Hour: Min: \(currentHour, currentMinute)")
        
        /*
         * Yelp API v3 is using unixTime(business.literalHours) to compare with open_at.
         * So users have to offset unixTime(date) with secondsFromUTC(userTimeZone) to make it work.
         * e.g. User is querying date=4pm PDT, unixTime(date) is actually 11pm UTC, comparing with literal business hours 3pm - 9pm which would give false. So user has to offset with seconds from PDT to UTC, which is (-7 * 3600) to get 4pm comparing with 3pm - 9pm which would give true then.
         * Update 09/06/2016: Yelp has updated API that no conversion from UTC to local time is needed from users.
         */
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.long
        
        let curDate = dateFormatter.string(from: currentDate)
        
        print("current date: \(curDate)")
        print("current date in unix: \(Int(currentDate.timeIntervalSince1970) - currentSecond)")
    }
    
    // Get current clock arms angle.
    private func getClockArmAngle(from hour: Int, _ minute: Int) -> (hour: CGFloat, minute: CGFloat) {
        let minuteArmAngle = CGFloat(minute) * CGFloat(M_PI / 30)
        let hourArmAngle = CGFloat(hour) * CGFloat(M_PI / 6) + CGFloat(minuteArmAngle / 12)
        
        return (hourArmAngle, minuteArmAngle)
    }
    
    private func getHourMinute(from hourArm: CGFloat, _ minArm: CGFloat) -> (hour: Int, min: Int) {
        let min = Int(minArm * 30 / CGFloat(M_PI))
        //let hour = Int((hourArm - minArm / 12) * (6 / CGFloat(M_PI)))
        let hour = Int(hourArm * (6 / CGFloat(M_PI)))
        
        return (hour, min)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Date category: \(YelpUrlQueryParameters.category), coordinates: \(YelpUrlQueryParameters.coordinates), radius: \(YelpUrlQueryParameters.radius), limit: \(YelpUrlQueryParameters.limit), time: \(YelpUrlQueryParameters.openAt)")

        getCurrentDate()
        
        clockDialWidth = clockDial.bounds.size.width
        clockDialHeight = clockDial.bounds.size.height
        
        let clockArmsAngle = getClockArmAngle(from: currentHour!, currentMinute!)
        clockArmHourAngle = clockArmsAngle.hour
        clockArmMinuteAngle = clockArmsAngle.minute
        
        // Dynamically update width & height according to superview size.
        let clockArmHourHeight: CGFloat = clockDial.bounds.size.height / 4
        let clockArmHourWidth: CGFloat = clockArmHourHeight / 10
        clockArmHourHeightConstraint.constant = clockArmHourHeight
        clockArmHourWidthConstraint.constant = clockArmHourWidth
        
        // Set rotation anchor point to the arm head.
        clockArmHour.layer.anchorPoint.y = 1
        clockArmHour.transform = CGAffineTransform(rotationAngle: clockArmHourAngle!)
        
        let clockArmMinuteHeight: CGFloat = clockDial.bounds.size.height / 3
        let clockArmMinuteWidth: CGFloat = clockArmMinuteHeight / 15
        clockArmMinuteHeightConstraint.constant = clockArmMinuteHeight
        clockArmMinuteWidthConstraint.constant = clockArmMinuteWidth
        
        clockArmMinute.layer.anchorPoint.y = 1
        clockArmMinute.transform = CGAffineTransform(rotationAngle: clockArmMinuteAngle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let hourMin = getHourMinute(from: clockArmHourAngle!, clockArmMinuteAngle!)
        
        print("hour, min: \(hourMin.hour, hourMin.min)")
        // Minutes precision, in order to use cached data when re-query is made in 1 min.
        if let proposedDate = calendar.date(bySettingHour: hourMin.hour, minute: hourMin.min, second: 0, of: currentDate) {
            YelpUrlQueryParameters.openAt = Int(proposedDate.timeIntervalSince1970)
        }
    }

}
