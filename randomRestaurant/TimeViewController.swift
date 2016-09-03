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
    
    private var currentDate = 0
    private var pickerDate = 0
    
    func setUrlQueryParameters(urlParam: UrlQueryParameters) {
        urlQueryParameters = urlParam
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh view with current date.
        datePicker.setDate(NSDate(), animated: true)
        
        //datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        // Default value set to current time.
        //time = Int(datePicker.date.timeIntervalSince1970)
    
    }
    // Minutes precision, in order to use cached data when re-query is made in 1 min.
    private func updateDatesWithMinPrecision() {
        let calendar = NSCalendar.currentCalendar()
        let dateForPicker = datePicker.date
        let secondsForPicker = calendar.component(NSCalendarUnit.Second, fromDate: dateForPicker)
        
        let dateForCurrent = NSDate()
        let secondsForCurrent = calendar.component(NSCalendarUnit.Second, fromDate: dateForCurrent)
        
        let secondsFromUTC = NSTimeZone.localTimeZone().secondsFromGMT

        // Convert to local time.
        pickerDate = Int(dateForPicker.timeIntervalSince1970) + secondsFromUTC - secondsForPicker
        currentDate = Int(dateForCurrent.timeIntervalSince1970) + secondsFromUTC - secondsForCurrent
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
        
        let picDate = dateFormatter.stringFromDate(dateForPicker)
        let curDate = dateFormatter.stringFromDate(dateForCurrent)
        
        print("picked date: \(picDate), current date: \(curDate)")
        print("picked unix: \(pickerDate), current unix: \(currentDate)")
        
    }
    /*
    // Set picker when backing to this view. 
    override func viewWillAppear(animated: Bool) {
        
        updateDatesWithMinPrecision()
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func datePickerChanged(datePicker: UIDatePicker) {

        updateDatesWithMinPrecision()
    }
    */
    private func alert() {
        
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "Cannot be a past date.", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            // Set picker to current date.
            self.datePicker.setDate(NSDate(), animated: true)
            self.updateDatesWithMinPrecision()
        }))
        
        // Show the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationVC = segue.destinationViewController
        
        updateDatesWithMinPrecision()
        if pickerDate < currentDate {
            
            alert()
            
        } else {
            if let ratingVC = destinationVC as? RatingViewController {
                if let id = segue.identifier where id == "rating" {
                    urlQueryParameters?.openAt = pickerDate
                    ratingVC.setUrlQueryParameters(urlQueryParameters!)
                }
            }
        }
    }

}
