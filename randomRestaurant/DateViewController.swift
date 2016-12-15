//
//  DateViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 12/2/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class DateViewController: UIViewController {
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var clockDial: UIImageView!
    @IBOutlet weak var amPM: UIImageView!
    @IBOutlet weak var clockArmMinute: UIImageView!
    @IBOutlet weak var clockArmHour: UIImageView!
    
    @IBOutlet weak var hourArmBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var minuteArmBottomConstraint: NSLayoutConstraint!
    
    private let clock = Clock()
    
    private var bgImageName = ""
    
    // Angle by radian.
    private var clockArmHourRad: Float?
    private var clockArmMinuteRad: Float?
    
    private var currentHour: Int?
    private var currentMinute: Int?
    
    private var isAM: Bool?
    
    private var currentAngle: Float = 0.0
    private var previousAngle: Float = 0.0
    
    @IBAction func handleHourArmRotation(_ sender: UIPanGestureRecognizer) {
        let touchPosition = sender.location(in: clockDial)
        // Move coordinate system from upperleft corner to center.
        let touchPositionToCenterX = Float(touchPosition.x - clockDial.frame.width / 2)
        let touchPositionToCenterY = Float(touchPosition.y - clockDial.frame.height / 2)
        
        // Get the angles the arms should rotate.
        // Because arms' origin direction is upright(0 rad), while 0 rad of coordinate system is to the right,
        // so that 0 rad of coordinate system is actually PI/2 rad of arms; -10 degree of coordinate sys is
        // actually 80 degree of arms.
        clockArmHourRad = atan2(touchPositionToCenterY, touchPositionToCenterX) + Float(M_PI) / 2
        // Convert negative rads to positive.
        if clockArmHourRad! < 0 {
            clockArmHourRad! += 2 * Float(M_PI)
        }
        
        clockArmMinuteRad = getClockMinuteArmAngle(by: clockArmHourRad!)
        
        print("hr Rad: \(clockArmHourRad! * (180 / Float(M_PI)))")
        print("min Rad: \(clockArmMinuteRad! * (180 / Float(M_PI)))")
        
        // Rotate clock arms.
        clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmHourRad!))
        clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmMinuteRad!))
        
        setAMPM()
        setBackgroundImage()
    }
 
    private func setAMPM() {
        // When Hour arm passes 12 o'clock, switch AM/PM.
        currentAngle = clockArmHourRad!
        if abs(currentAngle - previousAngle) > 300 * Float(M_PI) / 180.0 {
            isAM = (isAM! ? false : true)
            amPM.image = isAM! ? UIImage(named: "am") : UIImage(named: "pm")
        }
        previousAngle = currentAngle
    }
 
    private func setBackgroundImage() {
        //
        var imageName = ""
        if isAM! {
            if (clockArmHourRad! >= Float(0)) && (clockArmHourRad! < 2 * Float(M_PI) / 6) {
                imageName = "night4"
            } else if clockArmHourRad! < 4 * Float(M_PI) / 6 {
                imageName = "night5"
            } else if clockArmHourRad! < 6 * Float(M_PI) / 6 {
                imageName = "night6"
            } else if clockArmHourRad! < 8 * Float(M_PI) / 6 {
                imageName = "day1"
            } else if clockArmHourRad! < 10 * Float(M_PI) / 6 {
                imageName = "day2"
            } else {
                imageName = "day3"
            }
        } else {
            if (clockArmHourRad! >= Float(0)) && (clockArmHourRad! < 2 * Float(M_PI) / 6) {
                imageName = "day4"
            } else if clockArmHourRad! < 4 * Float(M_PI) / 6 {
                imageName = "day5"
            } else if clockArmHourRad! < 6 * Float(M_PI) / 6 {
                imageName = "day6"
            } else if clockArmHourRad! < 8 * Float(M_PI) / 6 {
                imageName = "night1"
            } else if clockArmHourRad! < 10 * Float(M_PI) / 6 {
                imageName = "night2"
            } else {
                imageName = "night3"
            }
        }
        
        // Set when image is different.
        if bgImageName != imageName {
            //print("hour angle: \(clockArmHourAngle! * 180.0 / Float(M_PI))")
            //print("image name: \(imageName)")
            background.image = UIImage(named: imageName)
            bgImageName = imageName
        }
    }
    
    private func getClockMinuteArmAngle(by clockHourArmAngle: Float) -> Float {
        let minuteToHourAngularVelocity: Float = 12.0
        let minRad = (clockHourArmAngle * minuteToHourAngularVelocity).truncatingRemainder(dividingBy: 2.0 * (Float)(M_PI))
        // Angle in 2 * PI.
        // TODO: minRad could be 2PI(e.g. 6:00), why?
        /*
        var minRad = clockHourArmAngle * 12.0
        while minRad >= 2.0 * (Float)(M_PI) {
            minRad -= 2.0 * (Float)(M_PI)
        }
        */
        
        return minRad
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Date category: \(YelpUrlQueryParameters.category), coordinates: \(YelpUrlQueryParameters.coordinates), radius: \(YelpUrlQueryParameters.radius), limit: \(YelpUrlQueryParameters.limit), time: \(YelpUrlQueryParameters.openAt)")
        
        currentHour = clock.trueTime.hour
        currentMinute = clock.trueTime.minute
        clockArmHourRad = clock.trueTime.hourRad
        clockArmMinuteRad = clock.trueTime.minuteRad
        isAM = clock.trueTime.isAM
        
        if isAM! {
            amPM.image = UIImage(named: "am")
        } else {
            amPM.image = UIImage(named: "pm")
        }
        
        // Save for setAMPM() use.
        previousAngle = clockArmHourRad!
        
        setBackgroundImage()
        
        //print("view did load hour arm frame, bounds: \(clockArmHour.frame, clockArmHour.bounds)")
        //print("view did load dial frame, bounds: \(clockDial.frame, clockDial.bounds)")
        
        // Set rotation anchor point to the arm head.
        clockArmHour.layer.anchorPoint.y = 1
        hourArmBottomConstraint.constant += clockArmHour.frame.height / 2
        // Rotate.
        clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmHourRad!))

        clockArmMinute.layer.anchorPoint.y = 1
        minuteArmBottomConstraint.constant += clockArmMinute.frame.height / 2
        clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmMinuteRad!))
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
        clock.getHourMinute(from: clockArmHourRad!, clockArmMinuteRad!, isAM!)
        let calendar = clock.calendar
        let date = clock.date
        let hour = clock.faceTime.hour!
        let minute = clock.faceTime.minute!
        print("proposed hourrad, minrad: \(clockArmHourRad!, clockArmMinuteRad!)")
        print("proposed hour, min: \(hour, minute)")
        
        // Minutes precision, in order to use cached data when re-query is made in 1 min.
        if let proposedDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) {
            YelpUrlQueryParameters.openAt = Int(proposedDate.timeIntervalSince1970)
        }
    }
}
