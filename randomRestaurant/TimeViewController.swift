//
//  TimeViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/27/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class TimeViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var urlQueryParameters: UrlQueryParameters?
    func setUrlQueryParameters(urlParam: UrlQueryParameters) {
        urlQueryParameters = urlParam
    }
    
    private var time = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh view with current date.
        //datePicker.setDate(NSDate(), animated: true)
        
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        // Default value set to current time.
        time = Int(datePicker.date.timeIntervalSince1970)
    
    }
    
    // Set picker when backing to this view. 
    override func viewWillAppear(animated: Bool) {
        //print("time view will appear")
        //self.datePicker.setNeedsDisplay()
        //self.datePicker.setNeedsLayout()
        
        datePicker.setDate(NSDate(), animated: true)
        
        let calendar = NSCalendar.currentCalendar()
        let date = datePicker.date
        let seconds = calendar.component(NSCalendarUnit.Second, fromDate: date)
        time = Int(date.timeIntervalSince1970) - seconds
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
        
        let strDate = dateFormatter.stringFromDate(date)
        
        print("view will appear, date in unix, min precision: \(time), formatted: \(strDate)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {

        // Minutes precision, in order to use cached data when re-query is made in 1 min.
        let calendar = NSCalendar.currentCalendar()
        
        let date = datePicker.date

        let seconds = calendar.component(NSCalendarUnit.Second, fromDate: date)
        
        time = Int(date.timeIntervalSince1970) - seconds
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationVC = segue.destinationViewController
        
        if let ratingVC = destinationVC as? RatingViewController {
            if let id = segue.identifier {
                if id == "rating" {
                    urlQueryParameters?.openAt = time
                    ratingVC.setUrlQueryParameters(urlQueryParameters!)
                }
            }
        }
    }

}
