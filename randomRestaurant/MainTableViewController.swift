//
//  MainTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/19/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private var myContext = 0

class MainTableViewController: UITableViewController, MainAndSavedTableViewCellDelegate {
    
    static let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext

    fileprivate var sectionHeaders = [UIView]()
    //fileprivate var results = [Restaurant]()
    fileprivate var headers: [(img: String, txt: String)] = [("What", "What"), ("Where", "Where"), ("When", "When"), ("Rating", "Rating")]

    //fileprivate let list = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    fileprivate var headerHeight: CGFloat!

    fileprivate var yelpQueryParams = YelpUrlQueryParameters()
    fileprivate var yelpQuery = YelpQuery()
    fileprivate var restaurants = [[String: Any]]()
    fileprivate var imageCache = [String: UIImage]()
    fileprivate var myCoordinate = MyCoordinate()
    fileprivate var coordinate: CLLocationCoordinate2D?
    
    //fileprivate var calendar = Calendar.current
    //fileprivate var date = Date()
    fileprivate var category: String?
    fileprivate var location: (description: String, coordinate: CLLocationCoordinate2D)?
    fileprivate var date: Date?
    fileprivate var rating: Float?
    fileprivate var shouldSegue: Bool!
    
    fileprivate let yelpStars: [Float: String] = [0.0: "regular_0", 1.0: "regular_1", 1.5: "regular_1_half", 2.0: "regular_2", 2.5: "regular_2_half", 3.0: "regular_3", 3.5: "regular_3_half", 4.0: "regular_4", 4.5: "regular_4_half", 5.0: "regular_5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MainTableViewSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        let cellNib = UINib(nibName: "MainAndSavedTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "mainAndSavedCell")
        
        headerHeight = tableView.frame.height / 12

        yelpQuery.addObserver(self, forKeyPath: "queryDone", options: .new, context: &myContext)
        myCoordinate.addObserver(self, forKeyPath: "coordinate", options: .new, context: &myContext)
        
        myCoordinate.loadViewIfNeeded()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "headerCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shouldSegue = false
        // Reload visible cells to sync like button status with Saved.
        tableView.reloadData()
    }
    
    fileprivate func loadImagesToCache(from url: String, index: Int) {
        guard let urlString = URL(string: url) else {
            fatalError("Unexpected url string: \(url)")
        }
        URLSession.shared.dataTask(with: urlString) { data, response, error in
            guard error == nil, let imageData = data else {
                fatalError("error while getting url response: \(error?.localizedDescription)")
            }
            if let image = UIImage(data: imageData) {
                self.imageCache[url] = image
            }
            // Reload tableView when first image is ready.
            // Don't need to reload every time.
            if index == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }.resume()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if keyPath == "queryDone" && object is YelpQuery {
                if let newValue = change?[.newKey] {
                    if (newValue as! Bool) {
                        print("url query done")
                        // Process results.
                        restaurants = yelpQuery.results!

                        imageCache.removeAll(keepingCapacity: false)
                        for (index, member) in restaurants.enumerated() {
                            loadImagesToCache(from: member["image_url"] as! String, index: index)
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
        myCoordinate.removeObserver(self, forKeyPath: "coordinate", context: &myContext)

    }
    
    func showMap(cell: MainAndSavedTableViewCell) {
        print("show map from main")
        shouldSegue = true
        performSegue(withIdentifier: "showMap", sender: cell)
    }
    
    func linkToYelp(cell: MainAndSavedTableViewCell) {
        print("show yelp from main")
        if cell.yelpUrl != "" {
            UIApplication.shared.openURL(URL(string: cell.yelpUrl)!)
        } else {
            alert()
        }
    }
    
    func updateSaved(cell: MainAndSavedTableViewCell, button: UIButton) {
        if button.isSelected {
            print("Save object")
            let saved = NSEntityDescription.insertNewObject(forEntityName: "Saved", into: MainTableViewController.moc!) as! SavedMO
            
            saved.name = cell.name.text
            saved.address = cell.address
            saved.category = cell.category.text
            saved.imageUrl = cell.imageUrl
            saved.price = cell.price.text
            saved.rating = cell.rating
            saved.reviewCount = Int16(cell.reviewsTotal)
            saved.latitude = cell.latitude
            saved.longitude = cell.longitude
            saved.yelpUrl = cell.yelpUrl
        } else {
            let request: NSFetchRequest<SavedMO> = NSFetchRequest(entityName: "Saved")
            request.predicate = NSPredicate(format: "name == %@", cell.name.text!)
            
            guard let object = try? MainTableViewController.moc?.fetch(request).first else {
                fatalError("Error fetching object in context")
            }
            
            guard let obj = object else {
                print("Didn't find object in context")
                return
            }
            
            MainTableViewController.moc?.delete(obj)
            print("Deleted from Saved entity")
        }
        
        if (MainTableViewController.moc?.hasChanges)! {
            do {
                try MainTableViewController.moc?.save()
                print("context saved")
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    fileprivate func alert() {
        // Create the alert.
        let alert = UIAlertController(title: "Alert", message: "No restaurant has been found.", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add an action(button).
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
        }))
        
        // Show the alert.
        self.present(alert, animated: false, completion: nil)
    }
    
    // Is the object with name in Saved?
    fileprivate func objectSaved(name: String) -> Bool {
        let request = NSFetchRequest<SavedMO>(entityName: "Saved")
        request.predicate = NSPredicate(format: "name == %@", name)
        guard let object = try? MainTableViewController.moc?.fetch(request).first else {
            fatalError("Error fetching from context")
        }
        
        guard (object != nil) else {
            return false
        }
        
        return true
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

        // Configure the cell...
        if indexPath.section < 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            cell.textLabel?.text = ""
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainAndSavedCell", for: indexPath) as! MainAndSavedTableViewCell
            let content = restaurants[indexPath.row]
            cell.imageUrl = content["image_url"] as? String
            //cell.mainImage.loadImage(from: (content["image_url"] as? String)!)
            var image: UIImage?
            /*
            if indexPath.row >= imageCache.count {
                //print("nil image indexPath: \(indexPath.row)")
                image = UIImage(named: "globe")
            } else {
                //print("indexPath: \(indexPath.row)")
                image = imageCache[cell.imageUrl]
            }
            */
            if let img = imageCache[cell.imageUrl] {
               image = img
            } else {
                image = UIImage(named: "globe")
            }
            DispatchQueue.main.async {
                cell.mainImage.image = image
            }
            cell.name.text = content["name"] as? String
            var categories = String()
            for category in (content["categories"] as? [[String: Any]])! {
                categories += (category["title"] as! String) + ", "
            }
            let categoriesString = categories.characters.dropLast(2)
            cell.category.text = String(categoriesString)
            cell.rating = content["rating"] as? Float
            cell.ratingImage.image = UIImage(named: yelpStars[content["rating"] as! Float]!)
            cell.reviewsTotal = content["review_count"] as? Int
            cell.reviewCount.text = String(content["review_count"] as! Int) + " Reviews"
            cell.price.text = content["price"] as? String
            cell.yelpUrl = content["url"] as? String
            cell.latitude = (content["coordinates"] as? [String: Double])?["latitude"]
            cell.longitude = (content["coordinates"] as? [String: Double])?["longitude"]
                        
            let location: PickedBusinessLocation = PickedBusinessLocation(businessObj: (content["location"] as? [String: Any])!)!
            cell.address = location.getBizAddressString()
            cell.likeButton.isSelected = objectSaved(name: cell.name.text!)
            cell.delegate = self
            
            return cell
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section < 4 ? 10.0 : 380.0
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

    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldSegue = false
    }
    */
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //print("==sender: \(sender)")
        //print("==id: \(segue.identifier)")
        if segue.identifier == "showMap" && sender is MainAndSavedTableViewCell {
            //print("hello")
            guard let cell = sender as? MainAndSavedTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            let destinationVC = segue.destination
            if cell.address == "" {
                alert()
            } else {
                if let mapVC = destinationVC as? GoogleMapViewController {
                    
                    mapVC.setBizLocation(cell.address)
                    mapVC.setBizCoordinate2D(CLLocationCoordinate2DMake(cell.latitude
                        , cell.longitude))
                    mapVC.setBizName(cell.name.text!)
                    mapVC.setDepartureTime(yelpQueryParams.openAt.value as! Int)
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return shouldSegue
    }
    
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
        if var value = category {
            updateHeaderLabelText(ofSection: 0, toText: value)
            if value == "American" {
                value = "newamerican,tradamerican"
            }
            if value == "Indian" {
                value = "indpak"
            }
            yelpQueryParams.category.value = value
            print("**category: \(value)")
        } else {
            yelpQueryParams.category.value = "restaurants"
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
            yelpQueryParams.rating = 0
            updateHeaderLabelText(ofSection: 3, toText: "Rating: all")
        }
    }

}

extension UIImageView {
    public func loadImage(from urlString: String) {
        //print("load image from url")
        guard let url = URL(string: urlString) else {
            fatalError("Unexpected url string: \(urlString)")
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let imageData = data else {
                fatalError("error while getting url response: \(error?.localizedDescription)")
            }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
