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

    fileprivate var currentPlace: CurrentPlace? = nil

    fileprivate var filteredLocations = [[String](), [String]()]
    
    fileprivate var fetcher: GMSAutocompleteFetcher?
    
    fileprivate enum places: Int {
        case current, other
    }
    
    fileprivate var place: String? // Pass to Yelp API parameter "location".
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        // Clear all other places appended.
        filteredLocations[places.other.rawValue].removeAll(keepingCapacity: false)
        fetcher?.sourceTextHasChanged(inputText)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Asking for access of users location.
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        // Allocate cache here for URL responses so that cache data won't get lost when view is backed.
        let cacheSizeMemory = 5 * 1024 * 1024
        let cacheSizeDisk = 10 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "urlCache")
        //URLCache.setSharedURLCache(urlCache)
        URLCache.shared = urlCache
        
        inputLocation.delegate = self
        locationsTable.isHidden = false
        locationsTable.isScrollEnabled = true
        
        filteredLocations[places.current.rawValue].append("Current place")
        
        currentPlace = CurrentPlace() // Have to do initialization first.
        
        // Fetcher
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 50.090308, longitude: -66.966982)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 22.567078, longitude: -125.75968)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner, coordinate: swBoundsCorner)
        
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: filter)
        fetcher?.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        URLCache.shared.removeAllCachedResponses()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return filteredLocations.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredLocations[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "LocationTableViewCell"
    
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel!.text = filteredLocations[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath)!
        inputLocation.text = selectedCell.textLabel!.text
        view.endEditing(true) // Hide keyboard.

    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var destinationVC = segue.destination
        if let navCtrl = destinationVC as? UINavigationController {
            destinationVC = navCtrl.visibleViewController ?? destinationVC
        }
        
        // If no input in place search bar, use current place.
        if inputLocation.text == "" || inputLocation.text == "Current place" {
            currentPlace!.getCurrentPlace() {
                self.place = self.currentPlace!.currentPlaceAddress
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
        } else {
            place = self.inputLocation.text            
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

extension LocationsTableViewController: GMSAutocompleteFetcherDelegate {
    /**
     * Called when an autocomplete request returns an error.
     * @param error the error that was received.
     */
    public func didFailAutocompleteWithError(_ error: Error) {
        print("autocomplete error: \(error.localizedDescription)")
    }

    // Google Places autocomplete.
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        
        for prediction in predictions {
            let resultsStr = prediction.attributedFullText.string
            filteredLocations[places.other.rawValue].append(resultsStr)
            locationsTable.reloadData()
        }
        
    }

}

