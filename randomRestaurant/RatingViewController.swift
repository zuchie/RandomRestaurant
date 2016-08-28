//
//  RatingViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/27/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class RatingViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var rating: RatingControl!
    
    var urlQueryParameters: UrlQueryParameters?
    func setUrlQueryParameters(urlParam: UrlQueryParameters) {
        urlQueryParameters = urlParam
        print("category: \(urlQueryParameters?.category), location: \(urlQueryParameters?.location), radius: \(urlQueryParameters?.radius), limit: \(urlQueryParameters?.limit), time: \(urlQueryParameters?.openAt)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rating.bizRating = 3.5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
