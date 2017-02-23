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
    fileprivate let headers: [(img: String, txt: String)] = [("What", "What (Chinese)"), ("Where", "Where (Here)"), ("When", "When (Now)"), ("Rating", "Rating (4.0)")]

    //fileprivate let list = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    fileprivate var headerHeight: CGFloat!

    fileprivate var yelpQueryParams = YelpUrlQueryParameters()
    fileprivate var yelpQuery = YelpQuery()
    fileprivate var restaurants = [[String: Any]]()
    fileprivate var hereAndNow = HereAndNow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MainTableViewSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        headerHeight = tableView.frame.height / 12

        yelpQuery.addObserver(self, forKeyPath: "queryDone", options: .new, context: &myContext)
        hereAndNow.addObserver(self, forKeyPath: "coordinate", options: .new, context: &myContext)
        
        hereAndNow.loadViewIfNeeded()
        
        if headers[0].txt == "What (Chinese)" {
            yelpQueryParams.category.value = "Chinese"
        }
        if headers[2].txt == "When (Now)" {
            yelpQueryParams.openAt.value = Int(hereAndNow.date)
        }
        if headers[3].txt == "Rating (4.0)" {
            yelpQueryParams.rating = 4.0
        }
    
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("KVO triggered")
        if context == &myContext {
            print("keyPath: \(keyPath), object: \(object)")
            if keyPath == "queryDone" && object is YelpQuery {
                if let newValue = change?[.newKey] {
                    print("query busy changed to: \(newValue)")
                    if (newValue as! Bool) {
                        print("query done")
                        // Process results.
                        restaurants = yelpQuery.results!
                        DispatchQueue.main.async {
                            self.tableView.reloadSections(IndexSet(integer: 4), with: .automatic)
                        }
                        
                    }
                }
            }
            if keyPath == "coordinate" && object is HereAndNow {
                if let newValue = change?[.newKey] {
                    print("coordinate updated")
                    if headers[1].txt == "Where (Here)" {
                        yelpQueryParams.latitude.value = (newValue as! CLLocationCoordinate2D).latitude
                        yelpQueryParams.longitude.value = (newValue as! CLLocationCoordinate2D).longitude
                    }
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
            //tableView.rowHeight = 10.0
            cell.textLabel?.text = ""
        } else {
            //tableView.rowHeight = 80.0
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
    
    @IBAction func unwindToMain(sender: UIStoryboardSegue) {
        let sourceVC = sender.source
        switch (sender.identifier)! {
        case "backFromWhat":
            let vc = sourceVC as! FoodCategoriesCollectionViewController
            yelpQueryParams.category.value = vc.getCategory()
            print("**category: \(yelpQueryParams.category.value)")
        case "backFromWhere":
            let vc = sourceVC as! LocationTableViewController
            // Keep current location if no updates.
            if vc.getLocationCoordinates() != nil {
                yelpQueryParams.latitude.value = vc.getLocationCoordinates()?.latitude
                yelpQueryParams.longitude.value = vc.getLocationCoordinates()?.longitude
                print("**latitude: \(yelpQueryParams.latitude.value), longitude: \(yelpQueryParams.longitude.value)")
            }
        case "backFromWhen":
            let vc = sourceVC as! DateViewController
            yelpQueryParams.openAt.value = vc.getDate()
            print("**open at: \(yelpQueryParams.openAt.value)")
        case "backFromRating":
            let vc = sourceVC as! RatingViewController
            yelpQueryParams.rating = vc.getRating()
            print("**rating: \(yelpQueryParams.rating)")
        default:
            fatalError("Unexpected returning segue: \((sender.identifier)!)")
        }
        
        // TODO: Start Yelp search.
        yelpQuery.parameters = yelpQueryParams
        yelpQuery.startQuery()
    }

}
