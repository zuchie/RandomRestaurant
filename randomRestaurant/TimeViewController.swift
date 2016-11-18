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
    
    //var urlQueryParameters: YelpUrlQueryParameters?
    
    fileprivate var currentDate = 0
    fileprivate var pickerDate = 0
    /*
    func setYelpUrlQueryParameters(_ urlParam: YelpUrlQueryParameters) {
        urlQueryParameters = urlParam
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("time category: \(YelpUrlQueryParameters.category), coordinates: \(YelpUrlQueryParameters.coordinates), radius: \(YelpUrlQueryParameters.radius), limit: \(YelpUrlQueryParameters.limit), time: \(YelpUrlQueryParameters.openAt)")
        

        // Refresh view with current date.
        datePicker.setDate(Date(), animated: true)
        
        //datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        // Default value set to current time.
        //time = Int(datePicker.date.timeIntervalSince1970)
    
    }
    // Minutes precision, in order to use cached data when re-query is made in 1 min.
    fileprivate func updateDatesWithMinPrecision() {
        let calendar = Calendar.current
        let dateForPicker = datePicker.date
        let secondsForPicker = (calendar as NSCalendar).component(NSCalendar.Unit.second, from: dateForPicker)
        
        let dateForCurrent = Date()
        let secondsForCurrent = (calendar as NSCalendar).component(NSCalendar.Unit.second, from: dateForCurrent)

        /*
         * Yelp API v3 is using unixTime(business.literalHours) to compare with open_at.
         * So users have to offset unixTime(date) with secondsFromUTC(userTimeZone) to make it work.
         * e.g. User is querying date=4pm PDT, unixTime(date) is actually 11pm UTC, comparing with literal business hours 3pm - 9pm which would give false. So user has to offset with seconds from PDT to UTC, which is (-7 * 3600) to get 4pm comparing with 3pm - 9pm which would give true then.
         * Update 09/06/2016: Yelp has updated API that no conversion from UTC to local time is needed from users.
        */
        pickerDate = Int(dateForPicker.timeIntervalSince1970) - secondsForPicker
        currentDate = Int(dateForCurrent.timeIntervalSince1970) - secondsForCurrent
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.long
        
        let picDate = dateFormatter.string(from: dateForPicker)
        let curDate = dateFormatter.string(from: dateForCurrent)
        
        YelpUrlQueryParameters.openAt = pickerDate
        print("picked date: \(picDate), current date: \(curDate)")
        //print("offset picked date unix: \(pickerDate), offset current date unix: \(currentDate)")
        
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
    fileprivate func alert() {
        
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "Cannot be a past date.", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            // Set picker to current date.
            self.datePicker.setDate(Date(), animated: true)
            self.updateDatesWithMinPrecision()
        }))
        
        // Show the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //let destinationVC = segue.destination
        
        updateDatesWithMinPrecision()
        if pickerDate < currentDate {
            alert()
        }
        /*
        else {
            if let ratingVC = destinationVC as? RatingViewController {
                if let id = segue.identifier , id == "rating" {
                    urlQueryParameters?.openAt = pickerDate
                    ratingVC.setYelpUrlQueryParameters(urlQueryParameters!)
                }
            }
        }
        */
    }

}
