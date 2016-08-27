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

    private var currentPlace: CurrentPlace? = nil

    private var filteredLocations = [[String](), [String]()]
    
    private var fetcher: GMSAutocompleteFetcher?
    
    private enum places: Int {
        case current, other
    }
    
    private var nearbyBusinesses = GetNearbyBusinesses()
    private var avgRating = 0.0
    private var category = ""
    
    var rating: Double {
        get {
            return avgRating
        }
    }
    
    var foodCategory: String {
        get {
            return category
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let inputText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        //print("user typed string: \(inputText)")
        // Clear all other places appended.
        filteredLocations[places.other.rawValue].removeAll(keepCapacity: false)
        fetcher?.sourceTextHasChanged(inputText)
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        

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
        
        let cacheSizeMemory = 1 * 1024 * 1024
        let cacheSizeDisk = 2 * 1024 * 1024
        let urlCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "urlCache")
        NSURLCache.setSharedURLCache(urlCache)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //print("sections count: \(filteredLocations.count)")
        return filteredLocations.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredLocations[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //print("asking for a cell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        //print("section: \(indexPath.section), row: \(indexPath.row)")
        cell.textLabel!.text = filteredLocations[indexPath.section][indexPath.row]

        //print("cell got")
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("touch to select cell")
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        inputLocation.text = selectedCell.textLabel!.text
        
        if inputLocation.text! == "Current place" {
            nearbyBusinesses.place = currentPlace!.currentPlaceAddress
        } else {
            nearbyBusinesses.place = inputLocation.text
        }
        
        // Get businesses from Yelp API v3.
        nearbyBusinesses.getUrlParameters(nearbyBusinesses.place, categories: "mexican", radius: 40000, limit: 20, open_at: Int(NSDate().dateByAddingTimeInterval(12 * 3600).timeIntervalSince1970))
        
        nearbyBusinesses.makeBusinessesSearchUrl("https://api.yelp.com/v3/businesses/search?")
        
        let access_token = "XxrwsnAP8YyUtmYdSrC0RCHA6sgn8ggZILNUhNZQqkP8zBTNjondbANeyBLWw7V8LGX-cAb_H4jM2OMu_mnJpwVik5IU0g"
        
        nearbyBusinesses.makeUrlRequest(access_token) {
            self.avgRating = self.nearbyBusinesses.rating
            self.category = self.nearbyBusinesses.category
            print("rating: \(self.avgRating)")
            print("category: \(self.category)")
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var destinationVC = segue.destinationViewController
        if let navCtrl = destinationVC as? UINavigationController {
            destinationVC = navCtrl.visibleViewController ?? destinationVC
        }
        if let foodCategoriesVC = destinationVC as? FoodCategoriesViewController {
            if let id = segue.identifier {
                if id == "foodCategories" {
                    print("avg rating: \(self.avgRating), category: \(self.category)")
                    foodCategoriesVC.setAvgRatingAndCategory(self.avgRating, category: self.category)
                }
            }
        }

    }
    

}

extension LocationsTableViewController: GMSAutocompleteFetcherDelegate {
    func didAutocompleteWithPredictions(predictions: [GMSAutocompletePrediction]) {
        //var resultsStr = NSMutableString()
        for prediction in predictions {
            //resultsStr.appendFormat("%@\n", prediction.attributedPrimaryText)
            let resultsStr = prediction.attributedFullText.string
            filteredLocations[places.other.rawValue].append(resultsStr)
            locationsTable.reloadData()
        }
        
    }
    
    func didFailAutocompleteWithError(error: NSError) {
        print("autocomplete error: \(error.localizedDescription)")
    }
}

