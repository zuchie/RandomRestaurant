//
//  TimeViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/27/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation

class TimeViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var urlQueryParameters: UrlQueryParameters?
    
    private var currentDate = 0
    private var pickerDate = 0
    private var secondsFromUTC = 0
    
    private var searchCenterCoordinate: CLLocationCoordinate2D?
    
    private var dstOffset = 0
    private var rawOffset = 0
    
    func setSearchCenterCoordinate(coordinate: CLLocationCoordinate2D?) {
        if coordinate != nil {
            searchCenterCoordinate = coordinate
        } else {
            print("Didn't get business search center coordinate")
        }
    }

    
    func setUrlQueryParameters(urlParam: UrlQueryParameters) {
        urlQueryParameters = urlParam
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set to local date from Unix timestamp.
        datePicker.setDate(NSDate(), animated: true)
        
        //datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        // Default value set to current time.
        //time = Int(datePicker.date.timeIntervalSince1970)
    
    }
    
    private func getSecondsFromUTC(location: CLLocationCoordinate2D, timestamp: Double, key: String, completion: () -> Void) {
        let googleTimezoneUrlBase = "https://maps.googleapis.com/maps/api/timezone/json?"
        let googleTimezoneUrl = googleTimezoneUrlBase + "location=\(location.latitude),\(location.longitude)" + "&timestamp=\(timestamp)" + "&key=\(key)"
        
        let urlObj = NSURL(string: googleTimezoneUrl)
        let request = NSMutableURLRequest(URL: urlObj!)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 120
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error while getting Google Directions URL response: \(error)")
                return
            }
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    let status = convertedJsonIntoDict["status"] as? String
                    self.dstOffset = convertedJsonIntoDict["dstOffset"] as! Int
                    self.rawOffset = convertedJsonIntoDict["rawOffset"] as! Int
                    let timeZoneName = convertedJsonIntoDict["timeZoneName"] as? String
                    
                    if status == "OK" {
                        print("Business search area Timezone: \(timeZoneName), dstOffset: \(self.dstOffset), rawOffset: \(self.rawOffset)")
                        self.secondsFromUTC = self.dstOffset + self.rawOffset
                        
                        completion()
                    } else {
                        print("Google Directions returned status: \(status)")
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
    }
    
    // Minutes precision, in order to use cached data when re-query is made in 1 min.
    private func updateDatesWithMinPrecision(completion: () -> Void) {
        let calendar = NSCalendar.currentCalendar()
        let dateForPicker = datePicker.date
        let secondsForPicker = calendar.component(NSCalendarUnit.Second, fromDate: dateForPicker)
        
        let dateForCurrent = NSDate()
        let secondsForCurrent = calendar.component(NSCalendarUnit.Second, fromDate: dateForCurrent)
        
        //let secondsFromUTC = NSTimeZone.localTimeZone().secondsFromGMT
        
        // TODO: Implement func secondsFromUTC() to get local seconds from UTC by using Google Time Zone API.
        self.getSecondsFromUTC(searchCenterCoordinate!, timestamp: dateForPicker.timeIntervalSince1970, key: "AIzaSyBL3-W6isPqTo6w8LAtLDLGGH2Ne-Zba-o") {
            
            /*
             * Yelp API v3 is using unixTime(business.literalHours) to compare with open_at.
             * So users have to offset unixTime(date) with secondsFromUTC(userTimeZone) to make it work.
             * e.g. User is querying date=4pm PDT, unixTime(date) is actually 11pm UTC, comparing with literal business hours 3pm - 9pm which would give false. So user has to offset with seconds from PDT to UTC, which is (-7 * 3600) to get 4pm comparing with 3pm - 9pm which would give true then.
             */
            self.pickerDate = Int(dateForPicker.timeIntervalSince1970) + self.secondsFromUTC - secondsForPicker
            self.currentDate = Int(dateForCurrent.timeIntervalSince1970) + self.secondsFromUTC - secondsForCurrent
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
            
            let picDate = dateFormatter.stringFromDate(dateForPicker)
            let curDate = dateFormatter.stringFromDate(dateForCurrent)
            
            print("picked date: \(picDate), current date: \(curDate)")
            print("offset picked date unix: \(self.pickerDate), offset current date unix: \(self.currentDate)")
            
            completion()
        }
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
            self.updateDatesWithMinPrecision() {}
        }))
        
        // Show the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationVC = segue.destinationViewController
        
        updateDatesWithMinPrecision() {
            if self.pickerDate < self.currentDate {
                
                self.alert()
                
            } else {
                if let ratingVC = destinationVC as? RatingViewController {
                    if let id = segue.identifier where id == "rating" {
                        self.urlQueryParameters?.openAt = self.pickerDate
                        ratingVC.setUrlQueryParameters(self.urlQueryParameters!)
                    }
                }
            }
        }
    }

}
