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
    
    // Used for getting current location coordinates.
    let locationManager = CLLocationManager()
    
    let googlePlaceDetails = GooglePlaceDetails()
    
    fileprivate var imageView: UIImageView?
    private var visualEffectView: UIVisualEffectView?
    
    fileprivate enum VisualEffect {
        case blur
    }
    
    // Search radius: 40000 meters(25 mi), return 50 businesses.
    //var urlQueryParameters = YelpUrlQueryParameters(coordinates: kCLLocationCoordinate2DInvalid, category: "", radius: 40000, limit: 50, openAt: 0)
    
    // Locations for locationsTable - 2D array of arrays of type (String, String) tuple.
    var filteredLocations = [[(name: String, placeID: String)](), [(name: String, placeID: String)]()]
    
    //private var coordinates: CLLocationCoordinate2D?
    private var currentLocationCoordinations: CLLocationCoordinate2D?
    
    // Used for Google Places Autocomplete feature.
    fileprivate var fetcher: GMSAutocompleteFetcher!
    
    fileprivate enum Locations: Int {
        case current, other
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide Nav bar.
        //self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        // Hide empty cells.
        locationsTable.tableFooterView = UIView(frame: CGRect.zero)
        // Keep image aspect and fit instead of streched image by default.
        imageView = UIImageView(image: UIImage(named: "globe"))
        imageView?.contentMode = .scaleAspectFit
        locationsTable.backgroundView = imageView

        locationsTable.isHidden = false
        locationsTable.isScrollEnabled = true
        
        inputLocation.delegate = self
        
        filteredLocations[Locations.current.rawValue].append((name: "Current Location", placeID: ""))
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Allocate cache here for URL responses so that cache data won't get lost.
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
        
        makeVisualEffectView(effect: .blur)
    }

    override func viewWillAppear(_ animated: Bool) {
        // Empty cells.
        filteredLocations[Locations.other.rawValue].removeAll(keepingCapacity: false)
        locationsTable.reloadData()
        
        // Remove blur effect when there is one.
        if imageView?.subviews.count != 0 {
            removeVisualEffectView(visualEffectView!)
        }
    }
    
    // MARK: Memory.
    
    // Purge cache when memory is full.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        URLCache.shared.removeAllCachedResponses()
    }
    
    // MARK: - Core Location.
    
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
    
    // Update location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations.first! as CLLocation
        
        manager.stopUpdatingLocation()
        
        currentLocationCoordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
    }
    
    // TODO: Add func here when location changes, start updating location again.
    
    
    // MARK: - Search bar.
    
    // Feed Searchbar input to Fetcher.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        fetcher?.sourceTextHasChanged(inputText)
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
        cell.textLabel!.text = filteredLocations[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)!
        
        // Get coordinates of chosen location.
        if (indexPath as NSIndexPath).section == Locations.current.rawValue {
             YelpUrlQueryParameters.coordinates = currentLocationCoordinations
        } else {
            let placeID = filteredLocations[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].placeID
            
            googlePlaceDetails.getCoordinates(from: placeID) { coordinates in
                YelpUrlQueryParameters.coordinates = coordinates
                print("***coordinates updated")
            }
        }
        
        inputLocation.text = selectedCell.textLabel!.text
        view.endEditing(true) // Hide keyboard.
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        //cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
        cell.contentView.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    
    
    // MARK: Visual Effect View.
    
    private func makeVisualEffectView(effect: VisualEffect) {
        switch effect {
        case .blur:
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            visualEffectView = UIVisualEffectView(effect: blurEffect)
        }
    }
    
    fileprivate func addVisualEffectView(effect: VisualEffect, to view: UIImageView) {
        switch effect {
        case .blur:
            visualEffectView?.frame = view.bounds
            view.addSubview(visualEffectView!)
        }
    }
    
    private func removeVisualEffectView(_ view: UIVisualEffectView) {
        view.removeFromSuperview()
    }
    
    
    /*
    // MARK: - Alert.
    
    fileprivate func alert() {
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "Loading current location...", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
        }))
        
        // Show the alert.
        self.present(alert, animated: true, completion: nil)
    }
    */
    
    /*
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navCtrl = destinationVC as? UINavigationController {
            destinationVC = navCtrl.visibleViewController ?? destinationVC
        }
        
        if let foodCategoriesVC = destinationVC as? FoodCategoriesViewController {
            if let id = segue.identifier {
                if id == "foodCategories" {
                    urlQueryParameters?.coordinates = coordinates
                    print("coordinates: \(urlQueryParameters?.coordinates)")
                    foodCategoriesVC.setYelpUrlQueryParameters(urlQueryParameters!)
                }
            }
        }
    }
    */
}

// Google Places autocomplete.
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
        // Clear previously appended places.
        filteredLocations[Locations.other.rawValue].removeAll(keepingCapacity: false)
        
        for prediction in predictions {
            let placeID = prediction.placeID
            let resultsStr = prediction.attributedFullText.string
            filteredLocations[Locations.other.rawValue].append((name: resultsStr, placeID: placeID!))
        }
        // Blur background image when it hasn't been done & Update table.
        if imageView?.subviews.count == 0 {
            addVisualEffectView(effect: .blur, to: imageView!)
        }
        locationsTable.reloadData()
    }
}

