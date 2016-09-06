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
    var urlQueryParameters = UrlQueryParameters(location: "", category: "", radius: 40000, limit: 50, openAt: 0)

    private var currentPlace: CurrentPlace? = nil

    private struct location {
        var name: String
        var coordinate: CLLocationCoordinate2D?
    }

    private var filteredLocations = [[location](), [location]()]
    
    private var fetcher: GMSAutocompleteFetcher?
    private var coordinate: CLLocationCoordinate2D?
    
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
        
        // Allocate cache here for URL responses so that cache data won't get lost when view is backed. 
        let cacheSizeMemory = 5 * 1024 * 1024
        let cacheSizeDisk = 10 * 1024 * 1024
        let urlCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "urlCache")
        NSURLCache.setSharedURLCache(urlCache)
        
        inputLocation.delegate = self
        locationsTable.hidden = false
        locationsTable.scrollEnabled = true
        
        // Coordinate of Current place will be got later.  
        filteredLocations[places.current.rawValue].append(location(name: "Current place", coordinate: nil))
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
    
    override func viewWillAppear(animated: Bool) {
        
        currentPlace!.getCurrentPlace() {
            
            let currentPlaceName = self.currentPlace!.currentPlaceName
            let currentPlaceAddress = self.currentPlace!.currentPlaceAddress
            let currentPlaceCoordinate = self.currentPlace?.currentPlaceCoordinate
            //print("view will appear")
            print("current place name: \(currentPlaceName!), address: \(currentPlaceAddress!), coordinate: \(currentPlaceCoordinate)")
            
        }
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
        
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
    
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)

        cell.textLabel!.text = filteredLocations[indexPath.section][indexPath.row].name

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        inputLocation.text = selectedCell.textLabel!.text
        coordinate = filteredLocations[indexPath.section][indexPath.row].coordinate
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
            place = currentPlace!.currentPlaceAddress
            coordinate = currentPlace!.currentPlaceCoordinate
        } else {
            place = inputLocation.text
        }
        
        if place == nil {
            
            alert()
            
        } else {
            if let foodCategoriesVC = destinationVC as? FoodCategoriesViewController {
                if let id = segue.identifier {
                    if id == "foodCategories" {
                        urlQueryParameters?.location = place!
                        foodCategoriesVC.setUrlQueryParameters(urlQueryParameters!)
                        foodCategoriesVC.setSearchCenterCoordinate(coordinate)
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
        
            // TODO: Get coordinate from placeID and pass it to TimeViewController for Google Time Zone API use.
            if let id = prediction.placeID {
                let placesClient = GMSPlacesClient()
                placesClient.lookUpPlaceID(id, callback: { (place: GMSPlace?, error: NSError?) -> Void in
                    if let error = error {
                        print("lookup place id query error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let place = place {
                        print("Place name \(place.name)")
                        print("Place address \(place.formattedAddress)")
                        print("Place placeID \(place.placeID)")
                        print("Place attributions \(place.attributions)")
                        print("Place coordinate \(place.coordinate)")
                        //self.coordinate = place.coordinate
                    } else {
                        print("No place details for \(id)")
                    }
                    
                    let result = prediction.attributedFullText.string
                    self.filteredLocations[places.other.rawValue].append(location(name: result, coordinate: place?.coordinate))
                    self.locationsTable.reloadData()
                })
            } else {
                print("no placeID got")
            }
        }
        
    }
    
    func didFailAutocompleteWithError(error: NSError) {
        print("autocomplete error: \(error.localizedDescription)")
    }
}

