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
    @IBOutlet weak var clockArmHourXPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockArmHourYPositionConstraint: NSLayoutConstraint!

    @IBOutlet weak var clockArmMinute: UIImageView!
    @IBOutlet weak var clockArmMinuteWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockArmMinuteHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockArmMinuteXPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockArmMinuteYPositionConstraint: NSLayoutConstraint!

    @IBOutlet weak var clockDial: UIImageView!
    
    // Angle by radian.
    private var clockArmHourAngle: CGFloat = 0
    private var clockArmMinuteAngle: CGFloat = 0
    
    private var clockArmHourAffineTransform: CGAffineTransform?
    private var clockArmMinuteAffineTransform: CGAffineTransform?
    
    private var hourArmToXAxisAngle: CGFloat = CGFloat(M_PI / 2)

    @IBAction func handleHourArmRotation(_ sender: UIPanGestureRecognizer) {
        let touchPosition = sender.location(in: clockDial)
        // Move coordinate system from upperleft corner to center.
        let touchPositionToCenterX = touchPosition.x - clockDial.bounds.size.width / 2
        let touchPositionToCenterY = touchPosition.y - clockDial.bounds.size.height / 2
        // Get touch position angle.
        let touchPositionAngle = atan2(touchPositionToCenterY, touchPositionToCenterX) + hourArmToXAxisAngle
        
        /*
        // Make rotation clockwise.
        if touchPositionAngle < 0 {
            touchPositionAngle += CGFloat(2 * M_PI)
        }
        */
        
        print("touch position: \(touchPositionAngle * CGFloat(180.0 / M_PI))")
        
        /*
        var clockMinuteArmAngle = getClockMinuteArmAngle(by: touchPositionAngle)
        
        var HourArmRotationLegs = [CGFloat]()
        var MinuteArmRotationLegs = [CGFloat]()
        
        let temp = touchPositionAngle
        
        while touchPositionAngle > CGFloat(M_PI) {
            let rotationAngle: CGFloat = 179.0 * CGFloat(M_PI / 180.0)
            touchPositionAngle -= rotationAngle
            HourArmRotationLegs.append(rotationAngle)
            print("hour rotation leg: \(rotationAngle * CGFloat(180.0 / M_PI))")
        }
        HourArmRotationLegs.append(temp)
        
        while clockMinuteArmAngle > CGFloat(M_PI) {
            let rotationAngle: CGFloat = 179.0 * CGFloat(M_PI / 180.0)
            clockMinuteArmAngle -= rotationAngle
            MinuteArmRotationLegs.append(rotationAngle)
        }
        MinuteArmRotationLegs.append(touchPositionAngle)
        */
        
        // Rotate clock arm.
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: [],
            animations: {
                self.clockArmHour.transform = (self.clockArmHourAffineTransform?.rotated(by: touchPositionAngle))!
                /*
                 for rotation in MinuteArmRotationLegs {
                 self.clockArmMinute.transform = (self.clockArmMinuteAffineTransform?.rotated(by: rotation))!
                 }
                 */
        },
            completion: { finished in
                if finished {
                    print("animation done")
                }
        })

    }
    
    @IBAction func handleClockArmRotation(_ sender: UITapGestureRecognizer) {
        let touchPosition = sender.location(in: sender.view)
        // Move coordinate system from upperleft corner to center.
        let touchPositionToCenterX = touchPosition.x - sender.view!.bounds.size.width / 2
        let touchPositionToCenterY = touchPosition.y - sender.view!.bounds.size.height / 2
        // Get touch position angle.
        var touchPositionAngle = atan2(touchPositionToCenterY, touchPositionToCenterX) + hourArmToXAxisAngle
        
        // Make rotation clockwise.
        if touchPositionAngle < 0 {
            touchPositionAngle += CGFloat(2 * M_PI)
        }
        
        print("touch position: \(touchPositionAngle * CGFloat(180.0 / M_PI))")
        
        var clockMinuteArmAngle = getClockMinuteArmAngle(by: touchPositionAngle)

        var HourArmRotationLegs = [CGFloat]()
        var MinuteArmRotationLegs = [CGFloat]()
        
        let temp = touchPositionAngle
        
        while touchPositionAngle > CGFloat(M_PI) {
            let rotationAngle: CGFloat = 179.0 * CGFloat(M_PI / 180.0)
            touchPositionAngle -= rotationAngle
            HourArmRotationLegs.append(rotationAngle)
            print("hour rotation leg: \(rotationAngle * CGFloat(180.0 / M_PI))")
        }
        HourArmRotationLegs.append(temp)
        
        while clockMinuteArmAngle > CGFloat(M_PI) {
            let rotationAngle: CGFloat = 179.0 * CGFloat(M_PI / 180.0)
            clockMinuteArmAngle -= rotationAngle
            MinuteArmRotationLegs.append(rotationAngle)
        }
        MinuteArmRotationLegs.append(touchPositionAngle)
        
        // Rotate clock arm.
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: [],
            animations: {
                for rotation in HourArmRotationLegs {
                    print("rotation: \(rotation * CGFloat(180.0 / M_PI))")
                    self.clockArmHour.transform = (self.clockArmHourAffineTransform?.rotated(by: rotation))!
                }
                /*
                for rotation in MinuteArmRotationLegs {
                    self.clockArmMinute.transform = (self.clockArmMinuteAffineTransform?.rotated(by: rotation))!
                }
                */
            },
            completion: { finished in
                if finished {
                    print("animation done")
                }
            })
        
    }

    private func getClockMinuteArmAngle(by clockHourArmAngle: CGFloat) -> CGFloat {
        //let minutesAngleByHourArm = clockHourArmAngle.truncatingRemainder(dividingBy: CGFloat(M_PI / 6))
        let minuteToHourAngularVelocity: CGFloat = 12.0
        print("hour: \(clockHourArmAngle * CGFloat(180.0 / M_PI))")
        //print("minute: \(minutesAngleByHourArm * minuteToHourAngularVelocity * CGFloat(180.0 / M_PI))")
        //return minutesAngleByHourArm * minuteToHourAngularVelocity
        return clockHourArmAngle * minuteToHourAngularVelocity
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dynamically update width & height according to superview size.
        let clockArmHourHeight: CGFloat = clockDial.bounds.size.height / 4
        let clockArmHourWidth: CGFloat = clockArmHourHeight / 10
        clockArmHourHeightConstraint.constant = clockArmHourHeight
        clockArmHourWidthConstraint.constant = clockArmHourWidth
        
        // Set rotation anchor point to the arm head.
        clockArmHour.layer.anchorPoint.y = 1
        clockArmHourAffineTransform = CGAffineTransform(rotationAngle: clockArmHourAngle)
        clockArmHour.transform = clockArmHourAffineTransform!
        
        let clockArmMinuteHeight: CGFloat = clockDial.bounds.size.height / 3
        let clockArmMinuteWidth: CGFloat = clockArmMinuteHeight / 15
        clockArmMinuteHeightConstraint.constant = clockArmMinuteHeight
        clockArmMinuteWidthConstraint.constant = clockArmMinuteWidth
        
        clockArmMinute.layer.anchorPoint.y = 1
        clockArmMinuteAffineTransform = CGAffineTransform(rotationAngle: clockArmMinuteAngle)
        clockArmMinute.transform = clockArmMinuteAffineTransform!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
