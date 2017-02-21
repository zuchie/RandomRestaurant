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
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveButtonHeight: NSLayoutConstraint!
    
    private let calendar = Calendar.current
    private let date = Date()
    private let clock = Clock()
    
    private var bgImageName = ""
    
    // Angle by radian.
    private var clockArmHourRad: Float?
    private var clockArmMinuteRad: Float?
    
    //private var currentHour: Int?
    //private var currentMinute: Int?
    
    private var isAM: Bool?
    
    private var currentHourAngle: Float = 0.0
    private var previousHourAngle: Float = 0.0
    private var currentMinuteAngle: Float = 0.0
    private var previousMinuteAngle: Float = 0.0
    
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

        var delta = clockArmHourRad! - previousHourAngle
        //print("delta: \(delta * (180 / Float(M_PI)))")
        
        if abs(delta) >= Float(M_PI) / 6.0 {
            //print("previous hr: \(previousHourAngle * (180 / Float(M_PI)))")
            //print("current hr: \(clockArmHourRad! * (180 / Float(M_PI)))")
            // Take care when crossing 12'o clock. Angle would be coming from 358 degree to 1 degree.
            if abs(delta) > (300.0 * Float(M_PI) / 180.0) {
                if delta < 0 {
                    delta = delta + 2.0 * Float(M_PI)
                    //print("delta: \(delta * (180 / Float(M_PI)))")
                } else {
                    delta = delta - 2.0 * Float(M_PI)
                }
            }
            // Rotate clock arms.
            let quotient = Int(delta.divided(by: Float(M_PI) / 6.0))
            //print("quotient in Float: \(Float(quotient))")
            let formalizedDelta = Float(quotient) * Float(M_PI) / 6.0
            //clockArmHourRad = previousHourAngle + Float(quotient) * Float(M_PI) / 6.0
            let clockDate = clock.getClockDate(from: formalizedDelta, and: 0.0)
            
            let clockArmRads = clock.getHourMinuteAnglesAMPM(from: calendar.component(.hour, from: clockDate), calendar.component(.minute, from: clockDate))
            
            clockArmHourRad = clockArmRads.hour
            isAM = clockArmRads.isAM
            
            //print("==isAM: \(isAM)")
            // Round to decimal 2 to make inaccurate Float work, otherwise 6:00 could give 6:59.
            //clockArmHourRad = (clockArmHourRad! * pow(10.0, 2.0)).rounded() / pow(10.0, 2.0)
            //clockArmMinuteRad = getClockMinuteArmAngle(by: clockArmHourRad!)
            
            //print("===after hr: \(clockArmHourRad! * (180 / Float(M_PI)))")
            
            //clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmHourRad!))
            setClockArms(hourArmRad: clockArmHourRad!, minuteArmRad: nil)
            
            setAMPM(isAM: isAM!)
            setBackgroundImage()
            
            previousHourAngle = clockArmHourRad!
            
            //print("hr Rad: \(clockArmHourRad! * (180 / Float(M_PI)))")
            //print("min Rad: \(clockArmMinuteRad! * (180 / Float(M_PI)))")
        }
        
        //clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmMinuteRad!))
    }
 
    @IBAction func handleMinuteArmRotation(_ sender: UIPanGestureRecognizer) {
        let touchPosition = sender.location(in: clockDial)
        // Move coordinate system from upperleft corner to center.
        let touchPositionToCenterX = Float(touchPosition.x - clockDial.frame.width / 2)
        let touchPositionToCenterY = Float(touchPosition.y - clockDial.frame.height / 2)
        
        // Get the angles the arms should rotate.
        // Because arms' origin direction is upright(0 rad), while 0 rad of coordinate system is to the right,
        // so that 0 rad of coordinate system is actually PI/2 rad of arms; -10 degree of coordinate sys is
        // actually 80 degree of arms.
        clockArmMinuteRad = atan2(touchPositionToCenterY, touchPositionToCenterX) + Float(M_PI) / 2
        // Convert negative rads to positive.
        if clockArmMinuteRad! < 0 {
            clockArmMinuteRad! += 2 * Float(M_PI)
        }
        
        var delta = clockArmMinuteRad! - previousMinuteAngle
        
        if abs(delta) >= Float(M_PI) / 30.0 {
            //print("previous min: \(previousMinuteAngle * (180 / Float(M_PI)))")
            //print("current min: \(clockArmMinuteRad! * (180 / Float(M_PI)))")
            //print("delta: \(delta * (180 / Float(M_PI)))")

            // Take care when crossing 12'o clock. Angle would be coming from 358 degree to 1 degree.
            if abs(delta) > (300.0 * Float(M_PI) / 180.0) {
                if delta < 0 {
                    delta = delta + 2.0 * Float(M_PI)
                } else {
                    delta = delta - 2.0 * Float(M_PI)
                }
            }
            // Rotate clock arms.
            let quotient = Int(delta.divided(by: Float(M_PI) / 30.0))
            //print("quotient in Float: \(Float(quotient))")
            let formalizedDelta = Float(quotient) * Float(M_PI) / 30.0
            
            let hourRadDelta = getHourRad(by: formalizedDelta)
            //print("hour delta: \(hourRadDelta)")
            //clockArmHourRad = previousHourAngle + Float(quotient) * Float(M_PI) / 6.0
            let clockDate = clock.getClockDate(from: hourRadDelta, and: formalizedDelta)
            
            let clockArmRads = clock.getHourMinuteAnglesAMPM(from: calendar.component(.hour, from: clockDate), calendar.component(.minute, from: clockDate))
            
            clockArmHourRad = clockArmRads.hour
            clockArmMinuteRad = clockArmRads.minute
            isAM = clockArmRads.isAM
            
            //print("==isAM: \(isAM)")
            // Round to decimal 2 to make inaccurate Float work, otherwise 6:00 could give 6:59.
            //clockArmHourRad = (clockArmHourRad! * pow(10.0, 2.0)).rounded() / pow(10.0, 2.0)
            //clockArmMinuteRad = getClockMinuteArmAngle(by: clockArmHourRad!)
            
            //print("===after hr: \(clockArmHourRad! * (180 / Float(M_PI)))")
            
            //clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmHourRad!))
            setClockArms(hourArmRad: clockArmHourRad!, minuteArmRad: clockArmMinuteRad)
            
            setAMPM(isAM: isAM!)
            setBackgroundImage()
            
            previousHourAngle = clockArmHourRad!
            previousMinuteAngle = clockArmMinuteRad!
        }
        /*
        let velocity = sender.velocity(in: clockDial)
        print("x: \(velocity.x), y: \(velocity.y)")
        let delta = atan2(Float(velocity.y), Float(velocity.x))
        print("previous minute: \(previousMinuteAngle * (180 / Float(M_PI)))")
        print("current minute: \(clockArmMinuteRad! * (180 / Float(M_PI)))")

        print("delta: \(delta * (180 / Float(M_PI)))")

        clockArmMinuteRad = previousMinuteAngle + delta /*+ Float(M_PI) / 2*/
        // Convert negative rads to positive.
        if clockArmMinuteRad! < 0 {
            clockArmMinuteRad! += 2 * Float(M_PI)
        }
        
        // Round to decimal 2 to make inaccurate Float work, otherwise 6:00 could give 6:59.
        clockArmMinuteRad = (clockArmMinuteRad! * pow(10.0, 2.0)).rounded() / pow(10.0, 2.0)
        print("min Rad: \(clockArmMinuteRad! * (180 / Float(M_PI)))")
        clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmMinuteRad! ))
        
        previousMinuteAngle = clockArmMinuteRad!
        */
        /*
        let touchPosition = sender.location(in: clockDial)

        // Move coordinate system from upperleft corner to center.
        let touchPositionToCenterX = Float(touchPosition.x - clockDial.frame.width / 2)
        let touchPositionToCenterY = Float(touchPosition.y - clockDial.frame.height / 2)
        
        // Get the angles the arms should rotate.
        // Because arms' origin direction is upright(0 rad), while 0 rad of coordinate system is to the right,
        // so that 0 rad of coordinate system is actually PI/2 rad of arms; -10 degree of coordinate sys is
        // actually 80 degree of arms.
        clockArmMinuteRad = atan2(touchPositionToCenterY, touchPositionToCenterX) + Float(M_PI) / 2
        // Convert negative rads to positive.
        if clockArmMinuteRad! < 0 {
            clockArmMinuteRad! += 2 * Float(M_PI)
        }
        
        let delta = clockArmMinuteRad! - previousMinuteAngle
        //print("delta: \(delta * (180 / Float(M_PI)))")
        
        if abs(delta) >= Float(M_PI) / 30.0 {
            // Rotate clock arms.
            let quotient = Int(delta.divided(by: Float(M_PI) / 30.0))
            //print("quotient in Float: \(Float(quotient))")
            clockArmMinuteRad = previousMinuteAngle + Float(quotient) * Float(M_PI) / 30.0
            
            // Round to decimal 2 to make inaccurate Float work, otherwise 6:00 could give 6:59.
            clockArmMinuteRad = (clockArmMinuteRad! * pow(10.0, 2.0)).rounded() / pow(10.0, 2.0)
            clockArmHourRad = getClockHourArmAngle(by: clockArmMinuteRad!)

            //clockArmMinuteRad = getClockMinuteArmAngle(by: clockArmHourRad!)
            
            //print("===after hr: \(clockArmHourRad! * (180 / Float(M_PI)))")
            
            clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmMinuteRad!))
            clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmHourRad!))

            //setAMPM(isAM: )
            setBackgroundImage()
            
            previousMinuteAngle = clockArmMinuteRad!
            
            //print("hr Rad: \(clockArmHourRad! * (180 / Float(M_PI)))")
            //print("min Rad: \(clockArmMinuteRad! * (180 / Float(M_PI)))")
        }

        // Round to decimal 2 to make inaccurate Float work, otherwise 6:00 could give 6:59.
        //clockArmMinuteRad = (clockArmMinuteRad! * pow(10.0, 2.0)).rounded() / pow(10.0, 2.0)
        //clockArmHourRad = getClockHourArmAngle(by: clockArmMinuteRad!)
        
        //print("hr Rad: \(clockArmHourRad! * (180 / Float(M_PI)))")
        //print("min Rad: \(clockArmMinuteRad! * (180 / Float(M_PI)))")
        
        // Rotate clock arms.
        //clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmHourRad!))
        //clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmMinuteRad!))
        
        //setAMPM()
        //setBackgroundImage()
        */
    }
    
    private func setAMPM(isAM: Bool) {
        amPM.image = isAM ? UIImage(named: "am") : UIImage(named: "pm")
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
    
    private func getHourRad(by minuteRad: Float) -> Float {
        let hourToMinuteRadVelocity: Float = 1.0 / 12.0
        //let PI2Digits = ((Float)(M_PI) * pow(10.0, 2.0)).rounded() / pow(10.0, 2.0)
        
        // Angle in 2 * PI.
        //let hourRad = (minuteRad * hourToMinuteRadVelocity).truncatingRemainder(dividingBy: 2.0 * PI2Digits)
        let hourRad = minuteRad * hourToMinuteRadVelocity
        //print("min rad: \(clockHourArmAngle * minuteToHourAngularVelocity)")
        //print("2PI: \(2.0 * (Float)(M_PI))")
        //print("min rad truncated: \(minRad)")
        //print("hour rad: \(clockHourArmAngle)")
        //print("hour rad 2 digits: \(hourRad2Digits)")
        
        return hourRad
    }
    
    private func getClockHourArmAngle(by clockMinuteArmAngle: Float) -> Float {
        let hourToMinuteAngularVelocity: Float = 1.0 / 12.0
        let PI2Digits = ((Float)(M_PI) * pow(10.0, 2.0)).rounded() / pow(10.0, 2.0)
        
        // Angle in 2 * PI.
        let hourRad = (clockMinuteArmAngle * hourToMinuteAngularVelocity).truncatingRemainder(dividingBy: 2.0 * PI2Digits)
        
        //print("min rad: \(clockHourArmAngle * minuteToHourAngularVelocity)")
        //print("2PI: \(2.0 * (Float)(M_PI))")
        //print("min rad truncated: \(minRad)")
        //print("hour rad: \(clockHourArmAngle)")
        //print("hour rad 2 digits: \(hourRad2Digits)")
        
        return hourRad
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("Date category: \(YelpUrlQueryParameters.category), coordinates: \(YelpUrlQueryParameters.coordinates), radius: \(YelpUrlQueryParameters.radius), limit: \(YelpUrlQueryParameters.limit), time: \(YelpUrlQueryParameters.openAt)")
        
        clock.clockTime.hour = calendar.component(.hour, from: date)
        clock.clockTime.minute = calendar.component(.minute, from: date)
        
        let clockArmRads = clock.getHourMinuteAnglesAMPM(from: clock.clockTime.hour!, clock.clockTime.minute!)
        
        //currentHour = clock.trueTime.hour
        //currentMinute = clock.trueTime.minute
        clockArmHourRad = clockArmRads.hour
        clockArmMinuteRad = clockArmRads.minute
        isAM = clockArmRads.isAM
        
        /*
        if isAM! {
            amPM.image = UIImage(named: "am")
        } else {
            amPM.image = UIImage(named: "pm")
        }
        */
        
        setAMPM(isAM: isAM!)
        
        // Save for setAMPM() use.
        previousHourAngle = clockArmHourRad!
        previousMinuteAngle = clockArmMinuteRad!
        
        setBackgroundImage()
        
        //print("view did load hour arm frame, bounds: \(clockArmHour.frame, clockArmHour.bounds)")
        //print("view did load dial frame, bounds: \(clockDial.frame, clockDial.bounds)")
        
        // Set rotation anchor point to the arm head.
        clockArmHour.layer.anchorPoint.y = 1
        hourArmBottomConstraint.constant += 0.5 * clockArmHour.frame.height
        // Rotate.
        //clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmHourRad!))

        clockArmMinute.layer.anchorPoint.y = 1
        minuteArmBottomConstraint.constant += 0.5 * clockArmMinute.frame.height
        //clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(clockArmMinuteRad!))
        
        setClockArms(hourArmRad: clockArmHourRad!, minuteArmRad: clockArmMinuteRad!)
        
        // Round button.
        saveButtonHeight.constant = 0.1 * view.bounds.height
        saveButton.layer.cornerRadius = 0.5 * saveButtonHeight.constant
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.clipsToBounds = true
    }
    
    fileprivate func setClockArms(hourArmRad: Float?, minuteArmRad: Float?) {
        if hourArmRad != nil {
            clockArmHour.transform = CGAffineTransform(rotationAngle: CGFloat(hourArmRad!))
        }
        if minuteArmRad != nil {
            clockArmMinute.transform = CGAffineTransform(rotationAngle: CGFloat(minuteArmRad!))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDate() -> Int {
        // Minutes precision, in order to use cached data when re-query is made in 1 min.
        let proposedDate = calendar.date(bySettingHour: clock.clockTime.hour!, minute: clock.clockTime.minute!, second: 0, of: date)
        print("proposed hour, min: \(clock.clockTime.hour, clock.clockTime.minute)")
        return Int(proposedDate!.timeIntervalSince1970)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //clock.getHourMinute(from: clockArmHourRad!, clockArmMinuteRad!, isAM!)
        /*
        let calendar = clock.calendar
        let date = clock.date
        let hour = clock.clockTime.hour!
        let minute = clock.clockTime.minute!
        print("proposed hourrad, minrad: \(clockArmHourRad!, clockArmMinuteRad!)")
        */
        
        // Minutes precision, in order to use cached data when re-query is made in 1 min.
        if let proposedDate = calendar.date(bySettingHour: clock.clockTime.hour!, minute: clock.clockTime.minute!, second: 0, of: date) {
            print("proposed hour, min: \(clock.clockTime.hour, clock.clockTime.minute)")
            //YelpUrlQueryParameters.openAt = Int(proposedDate.timeIntervalSince1970)
        }
    }
    */
}
