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

    @IBAction func handleClockHourArmRotation(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
        if let view = sender.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            //view.transform.rotated(by: <#T##CGFloat#>)
        }
        sender.setTranslation(CGPoint.zero, in: sender.view)
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
        
        // TODO: How to use translatesAutoresizingMaskIntoConstraints?
        //clockArmHour.translatesAutoresizingMaskIntoConstraints = true
        
        let clockArmHourWidth: CGFloat = clockDial.frame.size.width / 4
        let clockArmHourHeight: CGFloat = clockArmHourWidth / 10
        clockArmHourWidthConstraint.constant = clockArmHourWidth
        clockArmHourHeightConstraint.constant = clockArmHourHeight
        clockArmHourXPositionConstraint.constant += clockArmHourWidth / 2
        
        // Do any additional setup after loading the view.
        // Add clock arms.
        //let clockArmMinute = UIImageView(image: UIImage(named: "clockArmBlack"))
        
        //clockArmHour.frame = CGRect(origin: origin, size: size)

        //clockArmHour.layoutIfNeeded()
        
        /*
        // Add gesture recognizer.
        let panGesture = UIGestureRecognizer(target: self, action: #selector(self.handleClockHourArmRotation(_:)))
        clockArmHour.addGestureRecognizer(panGesture)
        clockArmHour.isUserInteractionEnabled = true
        */
        
        //self.view.addSubview(clockArmHour)
        //self.view.addSubview(clockArmMinute)
        
        // Set to default position.
        //clockArmHour.leadingAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //clockArmMinute.leadingAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        // Set rotation anchor point.
        //clockArmHour.layer.anchorPoint = CGPoint(x: clockArmHour.frame.origin.x, y: clockArmHour.frame.origin.y + clockArmHour.frame.height / 2)
        //clockArmMinute.layer.anchorPoint = CGPoint(x: clockArmMinute.frame.minX, y: clockArmMinute.frame.height / 2)
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        // Add clock arms.
        //let clockArmMinute = UIImageView(image: UIImage(named: "clockArmBlack"))
        let clockArmHourWidth: CGFloat = clockDial.frame.size.width / 4
        let clockArmHourHeight: CGFloat = clockArmHourWidth / 10
        let size = CGSize(width: clockArmHourWidth, height: clockArmHourHeight)
        let origin = CGPoint(x: self.view.center.x, y: self.view.frame.height / 2 - clockArmHourHeight / 2)
        
        clockArmHour.frame = CGRect(origin: origin, size: size)
        
        /*
         // Add gesture recognizer.
         let panGesture = UIGestureRecognizer(target: self, action: #selector(self.handleClockHourArmRotation(_:)))
         clockArmHour.addGestureRecognizer(panGesture)
         clockArmHour.isUserInteractionEnabled = true
         */
        
        //self.view.addSubview(clockArmHour)
    }
    */
    
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
