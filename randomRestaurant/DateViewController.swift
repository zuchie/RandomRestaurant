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
        let clockMinuteArmAngle = getClockMinuteArmAngle(by: touchPositionAngle)
        
        // Rotate clock arms.
        self.clockArmHour.transform = (self.clockArmHourAffineTransform?.rotated(by: touchPositionAngle))!
        self.clockArmMinute.transform = (self.clockArmMinuteAffineTransform?.rotated(by: clockMinuteArmAngle))!
        
        /*
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
        */
    }

    private func getClockMinuteArmAngle(by clockHourArmAngle: CGFloat) -> CGFloat {
        let minuteToHourAngularVelocity: CGFloat = 12.0
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
