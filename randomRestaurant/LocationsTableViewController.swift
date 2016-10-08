//
//  LocationsTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/21/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

class LocationsTableViewController: UITableViewController, UISearchResultsUpdating, CLLocationManagerDelegate {

    // MARK: Properties
    @IBOutlet weak var locationsTable: UITableView!
    
    fileprivate var searchController: UISearchController!
    fileprivate var resultsViewController: SearchResutlsTableViewController!
    
    fileprivate var placesClient: GMSPlacesClient!

    let locationManager = CLLocationManager()
    
    // Search radius: 40000 meters(25 mi), return 50 businesses.
    var urlQueryParameters = UrlQueryParameters(location: "", category: "", radius: 40000, limit: 50, openAt: 0)

    // 2D array.
    fileprivate var filteredLocations = [[String](), [String]()]
    
    fileprivate var fetcher: GMSAutocompleteFetcher!
    
    fileprivate enum places: Int {
        case current, other
    }
    
    fileprivate struct Place {
        var name: String?
        var address: String?
    }
    
    fileprivate var currentPlace: Place?
    fileprivate var otherPlace: Place?

    func getFilteredLocations() ->[[String]] {
            return filteredLocations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Asking for access of users location.
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        /*
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        */
        resultsViewController = SearchResutlsTableViewController()
        searchController = UISearchController(searchResultsController: resultsViewController)
        
        searchController?.searchResultsUpdater = self
        searchController?.hidesNavigationBarDuringPresentation = true
        //searchResultsController.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.searchBarStyle = .prominent
        searchController?.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        currentPlace = Place()
        otherPlace = Place()
        
        placesClient = GMSPlacesClient.shared()

        // Allocate cache here for URL responses so that cache data won't get lost when view is backed.
        let cacheSizeMemory = 5 * 1024 * 1024
        let cacheSizeDisk = 10 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "urlCache")
        URLCache.shared = urlCache
        
        //inputLocation.delegate = self
        locationsTable.isHidden = false
        locationsTable.isScrollEnabled = true
        
        filteredLocations[places.current.rawValue].append("Current place")
        
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

    override func viewWillAppear(_ animated: Bool) {
        print("location view will appear")
        currentPlace?.name = ""
        currentPlace?.address = ""
        getCurrentPlace()
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            // Clear all other places appended.
            filteredLocations[places.other.rawValue].removeAll(keepingCapacity: false)
            fetcher?.sourceTextHasChanged(inputText)
            
            //tableView.reloadData()
        }
    }

    /*
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // Clear all other places appended.
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        filteredLocations[places.other.rawValue].removeAll(keepingCapacity: false)
        fetcher?.sourceTextHasChanged(inputText)
    }
    */
    
    private func getCurrentPlace() {
        print("get current place")
        placesClient?.currentPlace(callback: {
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: Error?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                let firstPlace = placeLikelihoodList.likelihoods.first?.place
                if let place = firstPlace {
                    self.currentPlace?.name = place.name
                    self.currentPlace?.address = place.formattedAddress!.components(separatedBy: ", ")
                        .joined(separator: ", ")
                    print("current place name: \(self.currentPlace!.name!)")
                }
            }
        })
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
        //inputLocation.text = selectedCell.textLabel!.text
        self.searchController?.searchBar.text = selectedCell.textLabel!.text
        view.endEditing(true) // Hide keyboard.

    }
    
    fileprivate func alert() {
        
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "Loading current location...", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
        }))
        
        // Show the alert.
        self.present(alert, animated: true, completion: nil)
    }

    /*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        
        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        print("coordinate: \(coordinations.latitude), \(coordinations.longitude)")
        print("location: \(locations.first)")

    }
    */
    
    // MARK: - Navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var destinationVC = segue.destination
        if let navCtrl = destinationVC as? UINavigationController {
            destinationVC = navCtrl.visibleViewController ?? destinationVC
        }
        
        // If no input in place search bar, use current place.
        if inputLocation.text == "" || inputLocation.text == "Current place" {
            if currentPlace?.address == "" {
                alert()
            } else {
                if let foodCategoriesVC = destinationVC as? FoodCategoriesViewController {
                    if let id = segue.identifier {
                        if id == "foodCategories" {
                            print("current place address: \(self.currentPlace!.address!)")
                            self.urlQueryParameters?.location = self.currentPlace!.address!
                            foodCategoriesVC.setUrlQueryParameters(self.urlQueryParameters!)
                        }
                    }
                }
            }
        } else {
            otherPlace?.address = self.inputLocation.text
            if let foodCategoriesVC = destinationVC as? FoodCategoriesViewController {
                if let id = segue.identifier {
                    if id == "foodCategories" {
                        print("chosen place address: \(otherPlace!.address!)")
                        urlQueryParameters?.location = otherPlace!.address!
                        foodCategoriesVC.setUrlQueryParameters(urlQueryParameters!)
                    }
                }
            }
        }
    }
    */
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
        print("did autocomplete")
        for prediction in predictions {
            //let placeID = prediction.placeID
            let resultsStr = prediction.attributedFullText.string
            filteredLocations[places.other.rawValue].append(resultsStr)
            //locationsTable.reloadData()
            resultsViewController.setResults(locations: filteredLocations)
        }
    }

}

