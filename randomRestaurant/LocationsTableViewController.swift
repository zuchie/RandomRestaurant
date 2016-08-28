//
//  LocationsTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/21/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationsTableViewController: UITableViewController, UISearchBarDelegate {

    // MARK: Properties
    
    @IBOutlet weak var inputLocation: UISearchBar!
    @IBOutlet weak var locationsTable: UITableView!
    
    // Search radius: 40000 meters(25 mi), return 20 businesses.
    var urlQueryParameters = UrlQueryParameters(location: "", category: "", radius: 40000, limit: 20, openAt: 0)

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
        
        inputLocation.delegate = self
        locationsTable.hidden = false
        locationsTable.scrollEnabled = true
        
        filteredLocations[places.current.rawValue].append("Current place")
        
        currentPlace = CurrentPlace() // Have to do initialization first.
        currentPlace!.getCurrentPlace() {
            let currentPlaceName = self.currentPlace!.currentPlaceName
            let currentPlaceAddress = self.currentPlace!.currentPlaceAddress
            print("current place name: \(currentPlaceName!), address: \(currentPlaceAddress!)")
        }
        
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
    
        /*
        // Create cache to save URL query data.
        let cacheSizeMemory = 1 * 1024 * 1024
        let cacheSizeDisk = 2 * 1024 * 1024
        let urlCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "urlCache")
        NSURLCache.setSharedURLCache(urlCache)
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        //NSURLCache.sharedURLCache().removeAllCachedResponses()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return filteredLocations.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredLocations[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        cell.textLabel!.text = filteredLocations[indexPath.section][indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        inputLocation.text = selectedCell.textLabel!.text
        
        /*
        // Get businesses from Yelp API v3.
        nearbyBusinesses.getUrlParameters(nearbyBusinesses.place, categories: "mexican", radius: 40000, limit: 20, open_at: Int(NSDate().dateByAddingTimeInterval(12 * 3600).timeIntervalSince1970))
        
        nearbyBusinesses.makeBusinessesSearchUrl("https://api.yelp.com/v3/businesses/search?")
        
        let access_token = "XxrwsnAP8YyUtmYdSrC0RCHA6sgn8ggZILNUhNZQqkP8zBTNjondbANeyBLWw7V8LGX-cAb_H4jM2OMu_mnJpwVik5IU0g_S6ZOEJZTaU"
        
        nearbyBusinesses.makeUrlRequest(access_token) {
            self.avgRating = self.nearbyBusinesses.rating
            self.category = self.nearbyBusinesses.category
            print("rating: \(self.avgRating)")
            print("category: \(self.category)")
        }
        */
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        var destinationVC = segue.destinationViewController
        if let navCtrl = destinationVC as? UINavigationController {
            destinationVC = navCtrl.visibleViewController ?? destinationVC
        }
        if let foodCategoriesVC = destinationVC as? FoodCategoriesViewController {
            if let id = segue.identifier {
                if id == "foodCategories" {
                    // If no input in place search bar, use current place.
                    place = (inputLocation.text == "" || inputLocation.text == "Current place") ? currentPlace!.currentPlaceAddress : inputLocation.text
                    
                    urlQueryParameters?.location = place!
                    foodCategoriesVC.setUrlQueryParameters(urlQueryParameters!)
                }
            }
        }
    }
}

extension LocationsTableViewController: GMSAutocompleteFetcherDelegate {
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

