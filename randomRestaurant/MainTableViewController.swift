//
//  MainTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/19/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation

private var myContext = 0

class MainTableViewController: UITableViewController {
    
    fileprivate var sectionHeaders = [UIView]()
    //fileprivate var results = [Restaurant]()
    fileprivate var headers: [(img: String, txt: String)] = [("What", "What"), ("Where", "Where"), ("When", "When"), ("Rating", "Rating")]

    //fileprivate let list = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    fileprivate var headerHeight: CGFloat!

    fileprivate var yelpQueryParams = YelpUrlQueryParameters()
    fileprivate var yelpQuery = YelpQuery()
    fileprivate var restaurants = [[String: Any]]()
    fileprivate var myCoordinate = MyCoordinate()
    fileprivate var coordinate: CLLocationCoordinate2D?
    
    //fileprivate var calendar = Calendar.current
    //fileprivate var date = Date()
    fileprivate var category: String?
    fileprivate var location: (description: String, coordinate: CLLocationCoordinate2D)?
    fileprivate var date: Date?
    fileprivate var rating: Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MainTableViewSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        headerHeight = tableView.frame.height / 12

        yelpQuery.addObserver(self, forKeyPath: "queryDone", options: .new, context: &myContext)
        myCoordinate.addObserver(self, forKeyPath: "coordinate", options: .new, context: &myContext)
        
        myCoordinate.loadViewIfNeeded()
        
        /*
        // Placeholder in case no user inputs.
        if headers[0].txt == "What: all" {
            yelpQueryParams.category.value = "restaurants"
        }
        
        if headers[2].txt == "When: now" {
            yelpQueryParams.openAt.value = Int(myCoordinate.date)
        }
        */
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if keyPath == "queryDone" && object is YelpQuery {
                if let newValue = change?[.newKey] {
                    if (newValue as! Bool) {
                        print("url query done")
                        // Process results.
                        restaurants = yelpQuery.results!
                        DispatchQueue.main.async {
                            self.tableView.reloadSections(IndexSet(integer: 4), with: .automatic)
                        }
                        
                    }
                }
            }
            if keyPath == "coordinate" && object is MyCoordinate {
                if let newValue = change?[.newKey] {
                    print("coordinate updated")
                    /*
                    if headers[1].txt == "Where: here" {
                        yelpQueryParams.latitude.value = (newValue as! CLLocationCoordinate2D).latitude
                        yelpQueryParams.longitude.value = (newValue as! CLLocationCoordinate2D).longitude
                    }
                    */
                    coordinate = newValue as? CLLocationCoordinate2D
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        yelpQuery.removeObserver(self, forKeyPath: "queryDone", context: &myContext)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section < 4 ? 1 : restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath)

        // Configure the cell...
        if indexPath.section < 4 {
            cell.textLabel?.text = ""
        } else {
            cell.textLabel?.text = restaurants[indexPath.row]["name"] as! String?
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section < 4 ? 10.0 : 80.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section < 4 ? headerHeight: 20.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section < 4 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! MainTableViewSectionHeaderView

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
            header.addGestureRecognizer(tap)
            
            header.stackViewHeight.constant = headerHeight
            header.imageView.image = UIImage(named: headers[section].img)
            header.label.text = headers[section].txt
            header.headerName = headers[section].img
         
            return header
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < 4 ? nil : "Restaurants: \(restaurants.count)"
    }

    
    @objc fileprivate func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard let headerView = sender.view as? MainTableViewSectionHeaderView else {
            fatalError("Unexpected view: \(sender.view)")
        }
        
        performSegue(withIdentifier: headerView.headerName.lowercased(), sender: self)
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
        if sender is UITableViewHeaderFooterView {
            let headerView = sender as! MainTableViewSectionHeaderView
            if headerView.img == "Where" {
                segue.destination
            }
        }
    }
    */
    
    fileprivate func updateHeaderLabelText(ofSection section: Int, toText labelText: String) {
        (tableView.headerView(forSection: section) as! MainTableViewSectionHeaderView).label.text = labelText
        
        headers[section].txt = labelText
    }
    
    
    @IBAction func unwindToMain(sender: UIStoryboardSegue) {
        
        let sourceVC = sender.source
        switch (sender.identifier)! {
        case "backFromWhat":
            category = (sourceVC as! FoodCategoriesCollectionViewController).getCategory()
            //yelpQueryParams.category.value = category
            //updateHeaderLabelText(ofSection: 0, toText:  category)
            //print("**category: \(category)")
        case "backFromWhere":
            // Keep current location if no updates.
            location = (sourceVC as! LocationTableViewController).getLocation()
                //yelpQueryParams.latitude.value = location.coordinate.latitude
                //yelpQueryParams.longitude.value = location.coordinate.longitude
                //updateHeaderLabelText(ofSection: 1, toText: location.description)
                //print("**name: \(location.description), latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude)")
        case "backFromWhen":
            date = (sourceVC as! DateViewController).getDate()
            //yelpQueryParams.openAt.value = date.unix
            //updateHeaderLabelText(ofSection: 2, toText: date.formatted)
            //print("**open at: \(date.formatted)")
        case "backFromRating":
            rating = (sourceVC as! RatingViewController).getRating()
            //yelpQueryParams.rating = rating
            //updateHeaderLabelText(ofSection: 3, toText: "\(rating)")
            //print("**rating: \(rating)")
        default:
            fatalError("Unexpected returning segue: \((sender.identifier)!)")
        }
        
        updateHeader(category: category, location: location, date: date, rating: rating)
        
        // Start Yelp search.
        yelpQuery.parameters = yelpQueryParams
        yelpQuery.startQuery()
    }
    
    fileprivate func updateHeader(category: String?, location: (description: String, coordinate: CLLocationCoordinate2D)?, date: Date?, rating: Float?) {
        if let value = category {
            yelpQueryParams.category.value = value
            updateHeaderLabelText(ofSection: 0, toText: value)
            print("**category: \(value)")
        } else {
            updateHeaderLabelText(ofSection: 0, toText: "What: all")
        }
        if let value = location {
            yelpQueryParams.latitude.value = value.coordinate.latitude
            yelpQueryParams.longitude.value = value.coordinate.longitude
            updateHeaderLabelText(ofSection: 1, toText: value.description)
            print("**location: \(value.description), latitude: \(value.coordinate.latitude), longitude: \(value.coordinate.longitude)")
        } else {
            yelpQueryParams.latitude.value = coordinate?.latitude
            yelpQueryParams.longitude.value = coordinate?.longitude
            updateHeaderLabelText(ofSection: 1, toText: "Where: here")
        }
        if let value = date {
            if Calendar.current.compare(value, to: Date(), toGranularity: .minute) == .orderedSame  {
                yelpQueryParams.openAt.value = Int(value.timeIntervalSince1970)
                updateHeaderLabelText(ofSection: 2, toText: "When: now")
                print("**date is now")
            } else {
                yelpQueryParams.openAt.value = Int(value.timeIntervalSince1970)
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                let date = dateFormatter.string(from: value)
 
                updateHeaderLabelText(ofSection: 2, toText: date)
                print("**open at: \(value)")
            }
        } else {
            yelpQueryParams.openAt.value = Int(Date().timeIntervalSince1970)
            updateHeaderLabelText(ofSection: 2, toText: "When: now")
        }
        if let value = rating {
            yelpQueryParams.rating = value
            updateHeaderLabelText(ofSection: 3, toText: "\(value)")
            print("**rating: \(value)")
        } else {
            updateHeaderLabelText(ofSection: 3, toText: "Rating: all")
        }
    }

}
