//
//  SlotMachineViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 7/31/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class SlotMachineViewController: UIViewController {

    @IBOutlet weak var bizPicked: UILabel!
    @IBOutlet weak var pickedBizAddress: UILabel!
    @IBOutlet weak var viewsContainer: UIView!
    
    fileprivate var pickedRestaurant: Restaurant?
    
    fileprivate var nearbyBusinesses = GetNearbyBusinesses()
    
    fileprivate var ratingBar = 0.0
    
    fileprivate var bizName = ""
    fileprivate var bizPrice = ""
    fileprivate var bizRating = ""
    fileprivate var bizReviewCount = ""
    fileprivate var bizLocationObj: PickedBusinessLocation?
    fileprivate var bizAddress = ""
    fileprivate var bizCoordinate2D: CLLocationCoordinate2D?
    
    fileprivate weak var currentVC: UIViewController?
    
    static var scrollingImagesVC: MachineViewController?
    static var favoriteTableVC: FavoriteTableViewController?
    static var historyTableVC: HistoryTableViewController?
    
    //var urlQueryParameters: YelpUrlQueryParameters?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("slot machine view did load")
        
        print("category: \(YelpUrlQueryParameters.category), coordinates: \(YelpUrlQueryParameters.coordinates), radius: \(YelpUrlQueryParameters.radius), limit: \(YelpUrlQueryParameters.limit), time: \(YelpUrlQueryParameters.openAt)")
        
        // Instantiate View Controllers for all Segments. Their references will be kept when switching among Segments.
        SlotMachineViewController.scrollingImagesVC = self.storyboard?.instantiateViewController(withIdentifier: "Machine") as? MachineViewController
        SlotMachineViewController.favoriteTableVC = self.storyboard?.instantiateViewController(withIdentifier: "Favorite") as? FavoriteTableViewController
        SlotMachineViewController.historyTableVC = self.storyboard?.instantiateViewController(withIdentifier: "History") as? HistoryTableViewController
        
        // Set starting view.
        currentVC = SlotMachineViewController.scrollingImagesVC
        currentVC!.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChildViewController(currentVC!)
        currentVC?.view.frame = viewsContainer.frame
        self.addSubview(currentVC!.view, toView: viewsContainer)
        currentVC?.didMove(toParentViewController: self)
        
        view.sendSubview(toBack: viewsContainer)
        
        nearbyBusinesses.setRatingBar(ratingBar)
    }
    
    /*
    func setYelpUrlQueryParameters(_ urlParam: YelpUrlQueryParameters) {
        urlQueryParameters = urlParam
        print("category: \(urlQueryParameters!.category), coordinates: \(urlQueryParameters!.coordinates), radius: \(urlQueryParameters!.radius), limit: \(urlQueryParameters!.limit), time: \(urlQueryParameters!.openAt)")
    }
    */
    
    func getRatingBar(_ rating: Double) {
        ratingBar = rating
    }
 
    fileprivate func scrollImages(_ index: Int, imageView: UIImageView) {
        
        UIView.animate(withDuration: 4.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            
            var frame = imageView.frame
            
            frame.origin.y += frame.height * CGFloat(MachineViewController.imageViews.count - 1)
            
            imageView.frame = frame
            
        }, completion: { finished in
            
            if finished {
                
                self.view.sendSubview(toBack: self.viewsContainer)
                
            } else {
                
                print("animation is still running...")
                
            }
        })
    }

    func cycleFromViewController(_ oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView: viewsContainer)
        
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            },
                                   completion: { finished in
                                    oldViewController.view.removeFromSuperview()
                                    oldViewController.removeFromParentViewController()
                                    newViewController.didMove(toParentViewController: self)
        })
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            //let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Machine")
            let newViewController = SlotMachineViewController.scrollingImagesVC
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(currentVC!, toViewController: newViewController!)
            self.currentVC = newViewController
            view.sendSubview(toBack: viewsContainer)
        case 1:
            //let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Favorite")
            let newViewController = SlotMachineViewController.favoriteTableVC
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(currentVC!, toViewController: newViewController!)
            self.currentVC = newViewController
            view.bringSubview(toFront: viewsContainer)
        case 2:
            //let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("History")
            let newViewController = SlotMachineViewController.historyTableVC
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(currentVC!, toViewController: newViewController!)
            self.currentVC = newViewController
            view.bringSubview(toFront: viewsContainer)
        default:
            break;
        }
    }
    
    // Customized function to do view auto layout inside container view.
    func addSubview(_ subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
            options: [.alignAllCenterX], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
            options: [.alignAllCenterY], metrics: nil, views: viewBindingsDict))
        
        //print("parent frame height: \(parentView.frame.height), width: \(parentView.frame.width)")
 
    }
    
    @IBAction func start() {
        
        // Start animation.
        for (index, imageView) in MachineViewController.imageViews.enumerated() {
            // Reset Y.
            imageView.frame.origin.y = MachineViewController.imagesFrameY[index]
            
            view.bringSubview(toFront: viewsContainer)
            
            scrollImages(index, imageView: imageView)
        }
        
        let access_token = "XxrwsnAP8YyUtmYdSrC0RCHA6sgn8ggZILNUhNZQqkP8zBTNjondbANeyBLWw7V8LGX-cAb_H4jM2OMu_mnJpwVik5IU0g_S6ZOEJZTaU_GcNE4RnhBc2QkkmnGaV3Yx"
        
        // Get businesses from Yelp API v3.
        nearbyBusinesses.getUrlParameters(YelpUrlQueryParameters.coordinates, categories: YelpUrlQueryParameters.category, radius: YelpUrlQueryParameters.radius, limit: YelpUrlQueryParameters.limit, open_at: YelpUrlQueryParameters.openAt)
        
        nearbyBusinesses.makeBusinessesSearchUrl("https://api.yelp.com/v3/businesses/search?")
        
        nearbyBusinesses.makeUrlRequest(access_token) { totalBiz, randomNo in
            
            //print("total biz: \(totalBiz), random no.: \(randomNo)")
            if let returnedBusiness = self.nearbyBusinesses.result {
                //print("business picked: \(returnedBusiness)")
                
                self.bizName = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "name")
                self.bizPrice = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "price")
                self.bizRating = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "rating")
                self.bizReviewCount = self.nearbyBusinesses.getReturnedBusiness(returnedBusiness, key: "review_count")
                
                // Get picked business location object and convert to address string.
                if let pickedBizLocationObj = returnedBusiness["location"] as? NSDictionary {
                    self.bizLocationObj = PickedBusinessLocation(businessObj: pickedBizLocationObj)
                    
                    self.bizAddress = self.bizLocationObj!.getBizAddressString()
                    print("biz location: \(self.bizAddress)")
                } else {
                    print("No location information of picked business")
                }
                
                if let pickedBusinessCoordinatesObj = returnedBusiness["coordinates"] as? NSDictionary {
                    self.bizCoordinate2D = CLLocationCoordinate2DMake((pickedBusinessCoordinatesObj["latitude"] as? CLLocationDegrees)!, (pickedBusinessCoordinatesObj["longitude"] as? CLLocationDegrees)!)
                    print("biz latitude: \(self.bizCoordinate2D!.latitude), longitude: \(self.bizCoordinate2D!.longitude)")
                }
                
                // Params going to pass to Core Data of History Restaurant.
                self.pickedRestaurant = Restaurant(name: self.bizName, price: self.bizPrice, rating: self.bizRating, reviewCount: self.bizReviewCount, address: self.bizAddress, isFavorite: false, date: Int(Date().timeIntervalSince1970))
                
                // Update History database.
                HistoryDB.addEntry(self.pickedRestaurant!)
                // Update table view.
                SlotMachineViewController.historyTableVC?.updateUI()
                
                DispatchQueue.main.async(execute: {
                    
                    self.bizPicked.text = "\(self.bizName)\nprice: \(self.bizPrice), rating: \(self.bizRating), review count: \(self.bizReviewCount)\ntotal found: \(totalBiz), picked no.: \(randomNo)"
                    self.pickedBizAddress.text = "\(self.bizAddress)"
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.bizPicked.text = "No restaurant found"
                })
            }
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func alert() {
        
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "Please push \"Start\" button.", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
        }))
        
        // Show the alert.
        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination
        
        if bizAddress.isEmpty || bizCoordinate2D == nil {
            
            alert()
            
        } else {
            if let mapVC = destinationVC as? GoogleMapViewController {
                if let id = segue.identifier {
                    if id == "googleMap" {
                        mapVC.setBizLocation(bizAddress)
                        mapVC.setBizCoordinate2D(bizCoordinate2D!)
                        mapVC.setBizName(bizName)
                        mapVC.setDepartureTime(YelpUrlQueryParameters.openAt!)
                    }
                }
            }
        }
    }
    
}

