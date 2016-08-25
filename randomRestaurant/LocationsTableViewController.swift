//
//  LocationsTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/21/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var inputLocation: UISearchBar!
    @IBOutlet weak var locationsTable: UITableView!
    
    private var locationsBrain = LocationsBrain()
    private var currentPlace: CurrentPlace? = nil
    
    private var allLocations = [String]()
    private var filteredLocations = [String]()
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let inputText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        print("user typed string: \(inputText)")
        filteredLocations.removeAll(keepCapacity: false)
        for location in allLocations {
            let myString = location as NSString
            let subStringRange: NSRange = myString.rangeOfString(inputText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if subStringRange.location == 0 {
                print("found \(location) from substring \(inputText), append \(location) to table view")
                filteredLocations.append(location)
            }
        }
        locationsTable.reloadData()
    }
    /*
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {

    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputLocation.delegate = self
        locationsTable.hidden = false
        locationsTable.scrollEnabled = true
        
        locationsBrain.loadLocations()
        if let locations = locationsBrain.allLoadedLocations {
            print("all locations loaded")
            allLocations = locations
        } else {
            print("locations not loaded")
        }
        
        currentPlace = CurrentPlace() // Have to do initialization first.
        currentPlace!.getCurrentPlace() {
            let currentPlaceName = self.currentPlace!.currentPlaceName
            let currentPlaceAddress = self.currentPlace!.currentPlaceAddress
            print("current place name: \(currentPlaceName!), address: \(currentPlaceAddress!)")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            print("section 0")
            return 1
        } else {
            print("section 1, table row count: \(filteredLocations.count)")
            return filteredLocations.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("asking for a cell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        if indexPath.section == 0 {
            cell.textLabel!.text = "Current place"
        } else {
            cell.textLabel!.text = filteredLocations[indexPath.row]
        }
        print("cell got")
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("touch to select cell")
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        inputLocation.text = selectedCell.textLabel!.text
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
        // TODO: Pass inputLocation.text to FoodCategoriesViewController then to BizPickerViewController
    }
    

}
