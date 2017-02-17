//
//  LocationTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/9/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

class LocationTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    fileprivate var searchController: UISearchController?
    let locationManager = CLLocationManager()
    private var currentLocationCoordinations: CLLocationCoordinate2D?

    let googlePlaceDetails = GooglePlaceDetails()
    
    var filteredLocations = [[(name: String, placeID: String)](), [(name: String, placeID: String)]()]
    
    // Used for Google Places Autocomplete feature.
    fileprivate var fetcher: GMSAutocompleteFetcher!
    
    fileprivate enum Locations: Int {
        case current, other
    }
    
    private var visualEffectView: UIVisualEffectView?
    fileprivate enum VisualEffect {
        case blur
    }
    
    fileprivate var videoBG: VideoViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Search controller setup.
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        tableView.tableHeaderView = searchController?.searchBar
        definesPresentationContext = true
        
        searchController?.delegate = self
        
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.searchBarStyle = .default
        searchController?.searchBar.sizeToFit()
        
        // Table view setup.
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Set BG image.
        //imageView = UIImageView(image: UIImage(named: "globe"))
        //imageView?.contentMode = .scaleAspectFit
        //tableView.backgroundView = imageView
        
        // Location manager setup.
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
        
        filteredLocations[Locations.current.rawValue].append((name: "Current Location", placeID: ""))
        
        makeVisualEffectView(effect: .blur)
        
        // Add video to background and play.
        videoBG = VideoViewController(fileName: "city", fileExt: "mp4", directory: "Videos")
        addChildViewController(videoBG!)
        videoBG?.didMove(toParentViewController: self)

        tableView.backgroundView = videoBG?.view
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        print("**location view will appear**")
        // Start to play, because videoBG's viewWillAppear won't be called so it won't be able to start by itself.
        videoBG?.player?.play()
    }
    */
    /*
    override func viewWillDisappear(_ animated: Bool) {
        //videoBG?.playerVC.player?.pause()
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        URLCache.shared.removeAllCachedResponses()
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
    
    // Update location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations.first! as CLLocation
        
        manager.stopUpdatingLocation()
        
        currentLocationCoordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
    }

    // Method to conform to UISearchResultsUpdating protocol.
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let inputText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            fetcher?.sourceTextHasChanged(inputText)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return filteredLocations.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredLocations[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "locationCell"
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        // Configure the cell...
        cell.textLabel!.text = filteredLocations[indexPath.section][indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get coordinates of chosen location.
        if indexPath.section == Locations.current.rawValue {
            YelpUrlQueryParameters.coordinates = currentLocationCoordinations
        } else {
            let placeID = filteredLocations[indexPath.section][indexPath.row].placeID
            
            googlePlaceDetails.getCoordinates(from: placeID) { coordinates in
                YelpUrlQueryParameters.coordinates = coordinates
                print("***coordinates updated")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        //cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
        cell.contentView.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    
    // Notifications to blur/clear BG image.
    func willPresentSearchController(_ searchController: UISearchController) {
        // Blur background video.
        addVisualEffectView(effect: .blur, to: (videoBG?.view)!)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        // Remove blur effect.
        removeVisualEffectView(visualEffectView!)
    }
    // MARK: Visual Effect View.
    private func makeVisualEffectView(effect: VisualEffect) {
        switch effect {
        case .blur:
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            visualEffectView = UIVisualEffectView(effect: blurEffect)
        }
    }
    
    fileprivate func addVisualEffectView(effect: VisualEffect, to view: UIView) {
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
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// Google Places autocomplete.
extension LocationTableViewController: GMSAutocompleteFetcherDelegate {
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
        tableView.reloadData()
    }
}
