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
    private var clockArmMinuteAngle: CGFloat = CGFloat(M_PI / 2)
    
    private var clockArmHourAffineTransform: CGAffineTransform?
    private var clockArmMinuteAffineTransform: CGAffineTransform?

    @IBAction func handleClockArmRotation(_ sender: UITapGestureRecognizer) {
        let touchPosition = sender.location(in: sender.view)
        // Move coordinate system from upperleft corner to center.
        let touchPositionToCenterX = touchPosition.x - sender.view!.bounds.size.width / 2
        let touchPositionToCenterY = touchPosition.y - sender.view!.bounds.size.height / 2
        // Get touch position angle.
        let touchPositionAngle = atan2(touchPositionToCenterY, touchPositionToCenterX)
        // Rotate clock arm.
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: [],
            animations: {
                self.clockArmHour.transform = (self.clockArmHourAffineTransform?.rotated(by: touchPositionAngle))!
            },
            completion: { finished in
                if finished {
                    print("animation done")
                }
            })
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dynamically update width & height according to superview size.
        let clockArmHourWidth: CGFloat = clockDial.bounds.size.width / 4
        let clockArmHourHeight: CGFloat = clockArmHourWidth / 10
        clockArmHourWidthConstraint.constant = clockArmHourWidth
        clockArmHourHeightConstraint.constant = clockArmHourHeight
        
        // Set rotation anchor point to the arm head.
        clockArmHour.layer.anchorPoint.x = 0
        clockArmHourAffineTransform = CGAffineTransform(rotationAngle: clockArmHourAngle)
        clockArmHour.transform = clockArmHourAffineTransform!
        
        let clockArmMinuteWidth: CGFloat = clockDial.bounds.size.width / 3
        let clockArmMinuteHeight: CGFloat = clockArmMinuteWidth / 15
        clockArmMinuteWidthConstraint.constant = clockArmMinuteWidth
        clockArmMinuteHeightConstraint.constant = clockArmMinuteHeight
        
        clockArmMinute.layer.anchorPoint.x = 0
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
