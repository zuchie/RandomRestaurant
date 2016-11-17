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

class LocationsTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {

    // MARK: Properties
    @IBOutlet weak var locationsTable: UITableView!
    @IBOutlet weak var inputLocation: UISearchBar!
    
    fileprivate var searchController: UISearchController!
    
    // Used for getting current location coordinates.
    let locationManager = CLLocationManager()
    
    // Search radius: 40000 meters(25 mi), return 50 businesses.
    var urlQueryParameters = YelpUrlQueryParameters(location: "", category: "", radius: 40000, limit: 50, openAt: 0)
    
    // Locations for locationsTable.
    var filteredLocations = [[String](), [String]()]
    
    // Used for Google Places Autocomplete feature.
    fileprivate var fetcher: GMSAutocompleteFetcher!
    
    fileprivate enum Locations: Int {
        case current, other
    }
    
    fileprivate struct Location {
        var name: String?
        var address: String?
    }
    
    fileprivate var currentLocation = Location()
    fileprivate var otherLocation = Location()

    /*
    func getFilteredLocations() ->[[String]] {
            return filteredLocations
    }
    */
 
    override func viewDidLoad() {
        super.viewDidLoad()

        locationsTable.isHidden = false
        locationsTable.isScrollEnabled = true
        
        inputLocation.delegate = self
        filteredLocations[Locations.current.rawValue].append("Current Location")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Allocate cache here for URL responses so that cache data won't get lost when view is backed.
        let cacheSizeMemory = 5 * 1024 * 1024
        let cacheSizeDisk = 10 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "urlCache")
        URLCache.shared = urlCache
        
        // Create the Google Places Autocomplete Fetcher.
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 50.090308, longitude: -66.966982)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 22.567078, longitude: -125.75968)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner, coordinate: swBoundsCorner)
        
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: filter)
        fetcher.delegate = self

    }

    // Asking for access of user's location.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            // Asking users to enable location access from Settings.
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to get your current location, please open Settings and set location access of this App to 'While Using the App'.",
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { action in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true, completion: nil)
        default:
            print("Access request error")
        }
    }
    
    //
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        print("********location view will appear")
        currentPlace?.name = ""
        currentPlace?.address = ""
        getCurrentPlace()
    }
    */
    
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            // Clear all other places appended.
            filteredLocations[Locations.other.rawValue].removeAll(keepingCapacity: false)
            fetcher.sourceTextHasChanged(inputText)
            
            tableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // Clear all other places appended.
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        filteredLocations[Locations.other.rawValue].removeAll(keepingCapacity: false)
        fetcher?.sourceTextHasChanged(inputText)
    }
    
    /*
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
    */
    
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
    private func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
                            foodCategoriesVC.setYelpUrlQueryParameters(self.urlQueryParameters!)
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
                        foodCategoriesVC.setYelpUrlQueryParameters(urlQueryParameters!)
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
            filteredLocations[Locations.other.rawValue].append(resultsStr)
            locationsTable.reloadData()
        }
    }

}

