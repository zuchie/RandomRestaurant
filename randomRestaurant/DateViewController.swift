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
    private var clockArmHourAngle: Float?
    private var clockArmMinuteAngle: Float?
    
    private let calendar = Calendar.current
    private let currentDate = Date()
    
    private var currentHour: Int?
    private var currentMinute: Int?
    
    private var clockDialWidth: Float?
    private var clockDialHeight: Float?

    @IBAction func handleHourArmRotation(_ sender: UIPanGestureRecognizer) {
        let touchPosition = sender.location(in: clockDial)
        // Move coordinate system from upperleft corner to center.
        let touchPositionToCenterX = Float(touchPosition.x) - clockDialWidth! / 2
        let touchPositionToCenterY = Float(touchPosition.y) - clockDialHeight! / 2
        
        //print("touch x, y: \(touchPositionToCenterX, touchPositionToCenterY)")
        // Get the angles the arms should rotate.
        // Because arms' origin direction is upright(0 rad), while 0 rad of coordinate system is to the right,
        // so that 0 rad of coordinate system is actually PI/2 rad of arms; -10 degree of coordinate sys is
        // actually 80 degree of arms.
        clockArmHourAngle = atan2(touchPositionToCenterY, touchPositionToCenterX) + Float(M_PI) / 2
        // Convert negative rads to positive.
        if clockArmHourAngle! < 0 {
            clockArmHourAngle! += 2 * Float(M_PI)
        }
        
        clockArmMinuteAngle = getClockMinuteArmAngle(by: clockArmHourAngle!)
        
        //print("hr angle: \(clockArmHourAngle! * (180 / Float(M_PI)))")
        //print("min angle: \(clockArmMinuteAngle! * (180 / Float(M_PI)))")
        
        // Rotate clock arms.
        self.clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmHourAngle!))
        self.clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmMinuteAngle!))
        
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
        //self.clockArmHour.transform = CGAffineTransform.identity
    }

    private func getClockMinuteArmAngle(by clockHourArmAngle: Float) -> Float {
        let minuteToHourAngularVelocity: Float = 12.0
        // Angle in 2 * PI.
        return (clockHourArmAngle * minuteToHourAngularVelocity).truncatingRemainder(dividingBy: 2 * Float(M_PI))
    }
    
    private func getCurrentDate() {
        currentHour = calendar.component(.hour, from: currentDate)
        currentMinute = calendar.component(.minute, from: currentDate)
        //let currentSecond = calendar.component(.second, from: currentDate)
        
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
        //print("current date in unix: \(Int(currentDate.timeIntervalSince1970) - currentSecond)")
    }
    
    // Get current clock arms angle.
    private func getClockArmAngle(from hour: Int, _ minute: Int) -> (hour: Float, minute: Float) {
        //print("current Hour: Min: \(hour, minute)")
        let minuteArmAngle = Float(minute) * Float(M_PI) / 30.0
        let hourArmAngle = Float(hour) * Float(M_PI) / 6.0 + minuteArmAngle / 12.0
        return (hourArmAngle, minuteArmAngle)
    }
    
    // Get Hour & Minutes from clock arms angle, angles have to be from 0 to 2PI.
    private func getHourMinute(from hourArm: Float, _ minArm: Float) -> (hour: Int, min: Int) {
        let hour = Int(hourArm * 6.0 / Float(M_PI))
        let min = Int(minArm * 30.0 / Float(M_PI))
        
        return (hour, min)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Date category: \(YelpUrlQueryParameters.category), coordinates: \(YelpUrlQueryParameters.coordinates), radius: \(YelpUrlQueryParameters.radius), limit: \(YelpUrlQueryParameters.limit), time: \(YelpUrlQueryParameters.openAt)")
        
        getCurrentDate()

        let clockArmsAngle = getClockArmAngle(from: currentHour!, currentMinute!)
        clockArmHourAngle = clockArmsAngle.hour
        clockArmMinuteAngle = clockArmsAngle.minute
    }
    
    // Finalize views' bounds.
    override func viewDidLayoutSubviews() {
        clockDialWidth = Float(clockDial.bounds.size.width)
        clockDialHeight = Float(clockDial.bounds.size.height)
        
        // Dynamically update width & height according to superview size.
        let clockArmHourHeight = clockDial.bounds.size.height / 4
        let clockArmHourWidth = clockArmHourHeight / 10
        clockArmHourHeightConstraint.constant = clockArmHourHeight
        clockArmHourWidthConstraint.constant = clockArmHourWidth
        
        // Set rotation anchor point to the arm head.
        clockArmHour.layer.anchorPoint.y = 1
        clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmHourAngle!))
        
        let clockArmMinuteHeight = clockDial.bounds.size.height / 3
        let clockArmMinuteWidth = clockArmMinuteHeight / 15
        clockArmMinuteHeightConstraint.constant = clockArmMinuteHeight
        clockArmMinuteWidthConstraint.constant = clockArmMinuteWidth
        
        clockArmMinute.layer.anchorPoint.y = 1
        clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmMinuteAngle!))
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
        print("proposed hour, min: \(hourMin.hour, hourMin.min)")
        
        // Minutes precision, in order to use cached data when re-query is made in 1 min.
        if let proposedDate = calendar.date(bySettingHour: hourMin.hour, minute: hourMin.min, second: 0, of: currentDate) {
            YelpUrlQueryParameters.openAt = Int(proposedDate.timeIntervalSince1970)
        }
    }

}
