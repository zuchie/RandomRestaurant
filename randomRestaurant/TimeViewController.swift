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

        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        time = Int(datePicker.date.timeIntervalSince1970)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {

        time = Int(datePicker.date.timeIntervalSince1970)
        print("date in unix: \(time)")
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
