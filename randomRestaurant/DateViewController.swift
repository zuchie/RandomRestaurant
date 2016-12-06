//
//  DateViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 12/2/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class DateViewController: UIViewController {
    //private let clockArmHour = UIImageView(image: UIImage(named: "clockArmRed"))
    @IBOutlet weak var clockArmHour: UIImageView!
    @IBOutlet weak var clockArmHourWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockArmHourHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockArmHourXPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockArmHourYPositionConstraint: NSLayoutConstraint!

    @IBOutlet weak var clockDial: UIImageView!
    
    private var clockArmHourAngle: CGFloat = 0
    private var affineTransform: CGAffineTransform?

    @IBAction func handleClockHourArmRotation(_ sender: UIPanGestureRecognizer) {
        //let translation = sender.translation(in: sender.view)
        let touchPosition = sender.location(in: sender.view)
        if let view = sender.view {
            /*
            print("center: \(translation.x, translation.y)")
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            */
            
            //let center = clockDial.layer.position
            //let centerToTouch = CGVector(dx: translation.x - center.x, dy: translation.y - center.y)
            
            /*
            let panEndPositionAngle = atan2(-translation.y, translation.x)
            let rotationAngle = panEndPositionAngle - clockArmHourAngle
            view.transform = (affineTransform?.rotated(by: rotationAngle))!
            
            print("translation: \(translation.x, translation.y)")
            print("pan end point angle: \(panEndPositionAngle * CGFloat(180.0 / M_PI))")
            print("rotation angle: \(rotationAngle * CGFloat(180.0 / M_PI))")
            
            clockArmHourAngle += rotationAngle
            */
            
            let touchPositionAngle = atan2(-touchPosition.y, touchPosition.x)
            let rotationAngle = touchPositionAngle - clockArmHourAngle
            view.transform = (affineTransform?.rotated(by: rotationAngle))!
            //view.transform = (affineTransform?.rotated(by: touchPositionAngle))!
            
            print("touch position y, x: \(-touchPosition.y, touchPosition.x)")
            print("touch position angle: \(touchPositionAngle * CGFloat(180.0 / M_PI))")
            print("rotation angle: \(rotationAngle * CGFloat(180.0 / M_PI))")
            
            clockArmHourAngle += rotationAngle
            clockArmHourAngle = clockArmHourAngle.truncatingRemainder(dividingBy: CGFloat(2 * M_PI))
            print("clock arm angle: \(clockArmHourAngle * CGFloat(180.0 / M_PI))")

        }
        //sender.setTranslation(CGPoint.zero, in: sender.view)
    }
    
    /*
    private func handleClockMinuteArmRotation(_ sender: UIPanGestureRecognizer) {
        
        //sender.location(in: self.view.subviews.)
        
        let translation = sender.translation(in: sender.view)
        if let view = sender.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            //view.transform.rotated(by: <#T##CGFloat#>)
        }
        sender.setTranslation(CGPoint.zero, in: sender.view)
    }
    */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dynamically update width & height according to superview size.
        let clockArmHourWidth: CGFloat = clockDial.bounds.size.width / 4
        let clockArmHourHeight: CGFloat = clockArmHourWidth / 10
        clockArmHourWidthConstraint.constant = clockArmHourWidth
        clockArmHourHeightConstraint.constant = clockArmHourHeight
        
        // Set rotation anchor point to the arm head.
        clockArmHour.layer.anchorPoint.x = 0
        affineTransform = CGAffineTransform(rotationAngle: clockArmHourAngle)
        clockArmHour.transform = affineTransform!
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
