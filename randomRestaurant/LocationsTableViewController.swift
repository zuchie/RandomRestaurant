//
//  LocationsTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/21/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationsTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var inputLocation: UISearchBar!
    @IBOutlet weak var locationsTable: UITableView!
    
    let locationManager = CLLocationManager()
    
    // Search radius: 40000 meters(25 mi), return 50 businesses.
    var urlQueryParameters = UrlQueryParameters(location: "", category: "", radius: 40000, limit: 50, openAt: 0)

    private var currentPlace: CurrentPlace? = nil

    private var filteredLocations = [[String](), [String]()]
    
    private var fetcher: GMSAutocompleteFetcher?
    
    private enum places: Int {
        case current, other
    }
    
    private var place: String? // Pass to Yelp API parameter "location".
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let inputText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        // Clear all other places appended.
        filteredLocations[places.other.rawValue].removeAll(keepCapacity: false)
        fetcher?.sourceTextHasChanged(inputText)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Asking for access of users location.
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        // Allocate cache here for URL responses so that cache data won't get lost when view is backed.
        let cacheSizeMemory = 5 * 1024 * 1024
        let cacheSizeDisk = 10 * 1024 * 1024
        let urlCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "urlCache")
        NSURLCache.setSharedURLCache(urlCache)
        
        inputLocation.delegate = self
        locationsTable.hidden = false
        locationsTable.scrollEnabled = true
        
        filteredLocations[places.current.rawValue].append("Current place")
        
        currentPlace = CurrentPlace() // Have to do initialization first.
        
        // Fetcher
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 50.090308, longitude: -66.966982)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 22.567078, longitude: -125.75968)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner, coordinate: swBoundsCorner)
        
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .City
        
        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: filter)
        fetcher?.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return filteredLocations.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredLocations[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellID = "LocationTableViewCell"
    
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
        cell.textLabel!.text = filteredLocations[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        inputLocation.text = selectedCell.textLabel!.text
        view.endEditing(true) // Hide keyboard.

    }
    
    private func alert() {
        
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "Waiting for loading current location...", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in

        }))
        
        // Show the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destinationVC = segue.destinationViewController
        if let navCtrl = destinationVC as? UINavigationController {
            destinationVC = navCtrl.visibleViewController ?? destinationVC
        }
        
        // If no input in place search bar, use current place.
        if inputLocation.text == "" || inputLocation.text == "Current place" {
            currentPlace!.getCurrentPlace() {
                self.place = self.currentPlace!.currentPlaceAddress
                
                if self.place == nil {
                    self.alert()
                } else {
                    if let foodCategoriesVC = destinationVC as? FoodCategoriesViewController {
                        if let id = segue.identifier {
                            if id == "foodCategories" {
                                print("current place address: \(self.place!)")
                                self.urlQueryParameters?.location = self.place!
                                foodCategoriesVC.setUrlQueryParameters(self.urlQueryParameters!)
                            }
                        }
                    }
                }
            }
        } else {
            place = self.inputLocation.text
            
            if place == nil {
                alert()
            } else {
                if let foodCategoriesVC = destinationVC as? FoodCategoriesViewController {
                    if let id = segue.identifier {
                        if id == "foodCategories" {
                            print("chosen place address: \(place!)")
                            urlQueryParameters?.location = place!
                            foodCategoriesVC.setUrlQueryParameters(urlQueryParameters!)
                        }
                    }
                }
            }
        }
    }
}

extension LocationsTableViewController: GMSAutocompleteFetcherDelegate {
    // Google Places autocomplete.
    func didAutocompleteWithPredictions(predictions: [GMSAutocompletePrediction]) {
        
        for prediction in predictions {
            let resultsStr = prediction.attributedFullText.string
            filteredLocations[places.other.rawValue].append(resultsStr)
            locationsTable.reloadData()
        }
        
    }
    
    func didFailAutocompleteWithError(error: NSError) {
        print("autocomplete error: \(error.localizedDescription)")
    }
}

