//
//  MainTableViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/19/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class MainTableViewController: UITableViewController, MainTableViewCellDelegate {
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var category: UILabel!
    static let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    
    //fileprivate var queryCategory = ""
    
    fileprivate var locationManager = LocationManager.shared
    //fileprivate var queryLocation = CLLocation()
    
    //fileprivate var queryDate = Date()
    
    //fileprivate var anyParamUpdate = false
    
    fileprivate var yelpQueryParams: YelpUrlQueryParameters?
    fileprivate var yelpQuery: YelpQuery!
    
    fileprivate var restaurants = [[String: Any]]()
    fileprivate var imageCache = [String: UIImage]()
    
    fileprivate let yelpStars: [Float: String] = [0.0: "regular_0", 1.0: "regular_1", 1.5: "regular_1_half", 2.0: "regular_2", 2.5: "regular_2_half", 3.0: "regular_3", 3.5: "regular_3_half", 4.0: "regular_4", 4.5: "regular_4_half", 5.0: "regular_5"]
    
    struct QueryParams {
        var hasChanged = false
        var category = "" {
            didSet { hasChanged = (category != oldValue) }
        }
        var date = Date() {
            didSet { hasChanged = (date != oldValue) }
        }
        var location = CLLocation() {
            didSet { hasChanged = (location != oldValue) }
        }
    }
    
    var queryParams = QueryParams()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MainTableViewController view did load")
        
        // tableView Cell
        let cellNib = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "mainCell")
        
        // Header
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        header.addGestureRecognizer(tap)
        
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        locationManager.completion = { currentLocation in
            let distance = currentLocation.distance(from: self.queryParams.location)
            if distance > 50.0 {
                self.queryParams.location = currentLocation
            } else {
                print("Distance difference < 50m, no update")
            }
            // Start Yelp Query
            self.doYelpQuery()
        }
        
        getCategory(category: "restaurants")
        updateHeader(queryParams.category)
        getDate()
    }
    
    @objc fileprivate func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard (sender.view != nil) else {
            fatalError("Unexpected view: \(String(describing: sender.view))")
        }
        performSegue(withIdentifier: "segueToCategories", sender: self)
    }
    
    @objc fileprivate func handleRefresh(_ sender: UIRefreshControl) {
        print("handle refresh")
        getDate()
        getLocationAndStartQuery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Main view will appear, reload table")
        // Reload visible cells to sync like button status with Saved.
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Main view will disappear.")
    }
    
    fileprivate func loadImagesToCache(from url: String, index: Int) {
        guard let urlString = URL(string: url) else {
            fatalError("Unexpected url string: \(url)")
        }
        URLSession.shared.dataTask(with: urlString) { data, response, error in
            guard error == nil, let imageData = data else {
                fatalError("error while getting url response: \(String(describing: error?.localizedDescription))")
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
    
    func showMap(cell: MainTableViewCell) {
        print("show map from main")
        //shouldSegue = true
        performSegue(withIdentifier: "segueToMap", sender: cell)
    }
    
    func linkToYelp(cell: MainTableViewCell) {
        print("show yelp from main")
        if cell.yelpUrl != "" {
            UIApplication.shared.openURL(URL(string: cell.yelpUrl)!)
        } else {
            let alert = UIAlertController(title: "Alert",
                              message: "Couldn't find a restaurant.",
                              actions: [.ok]
            )
            self.present(alert, animated: false)
        }
    }
    
    func updateSaved(cell: MainTableViewCell, button: UIButton) {
        if button.isSelected {
            print("Save object")
            let saved = NSEntityDescription.insertNewObject(forEntityName: "Saved", into: MainTableViewController.moc!) as! SavedMO
            
            saved.name = cell.name.text
            saved.categories = cell.category.text
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
    
    fileprivate func updateHeaderLabelText(toText labelText: String) {
        category.text = labelText
    }
    
    
    @IBAction func unwindToMain(sender: UIStoryboardSegue) {
        print("Unwind to main")
        //restaurants.removeAll(keepingCapacity: false)
        
        let sourceVC = sender.source
        guard sender.identifier == "backFromWhat" else {
            fatalError("Unexpeted id: \(String(describing: sender.identifier))")
        }
        
        guard let category = (sourceVC as! FoodCategoriesCollectionViewController).getCategory() else {
            fatalError("Couldn't get category")
        }
        
        getCategory(category: category)
        updateHeader(queryParams.category)
        getDate()
        getLocationAndStartQuery()
    }
    
    fileprivate func getCategory(category: String) {
        queryParams.category = category
        /*
        if queryCategory == category {
            print("Same category, no update")
        } else {
            queryCategory = category
            anyParamUpdate = true
            print("category: \(queryCategory)")
        }
        */
    }
    
    fileprivate func getDate() {
        let calendar = Calendar.current
        let myDate = Date()
        let hour = calendar.component(.hour, from: myDate)
        let min = calendar.component(.minute, from: myDate)
        
        guard let date = calendar.date(bySettingHour: hour, minute: min, second: 0, of: myDate) else {
            fatalError("Couldn't get date")
        }
        
        queryParams.date = date
        /*
        if queryDate == date {
            print("Same date, no update")
        } else {
            queryDate = date
            anyParamUpdate = true
            print("date: \(queryDate)")
        }
        */
    }
    
    fileprivate func getLocationAndStartQuery() {
        locationManager.requestLocation()
    }
    
    fileprivate func doYelpQuery() {
        if queryParams.hasChanged {
            yelpQueryParams = YelpUrlQueryParameters(
                latitude: queryParams.location.coordinate.latitude,
                longitude: queryParams.location.coordinate.longitude,
                category: queryParams.category,
                radius: 10000,
                limit: 3,
                openAt: Int(queryParams.date.timeIntervalSince1970),
                sortBy: "rating"
            )
            
            guard let queryString = yelpQueryParams?.queryString else {
                fatalError("Couldn't get Yelp query string.")
            }
            guard let query = YelpQuery(queryString: queryString) else {
                fatalError("Yelp query is nil.")
            }
            yelpQuery = query
            yelpQuery.completion = { results in
                self.restaurants = results
                
                //refreshControl?.endRefreshing()
                
                self.imageCache.removeAll(keepingCapacity: false)
                for (index, member) in self.restaurants.enumerated() {
                    self.loadImagesToCache(from: member["image_url"] as! String, index: index)
                }
            }

            yelpQuery.startQuery()
            
            queryParams.hasChanged = false
            //anyParamUpdate = false
        } else {
            print("Params no change, skip query")
        }
    }

    fileprivate func updateHeader(_ category: String) {
        let header = (category == "restaurants" ? "What: all" : category)
        updateHeaderLabelText(toText: header)
    }

    fileprivate func configureCell(_ cell: MainTableViewCell, _ indexPath: IndexPath) {
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

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainTableViewCell
        
        configureCell(cell, indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 380.0
    }
    /*
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section < 4 ? headerHeight: 20.0
    }
    */
    /*
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
    */
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldSegue = false
    }
    */
    /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < 4 ? nil : "Restaurants: \(restaurants.count)"
    }
    */

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
        if segue.identifier == "segueToMap" && sender is MainTableViewCell {
            guard let cell = sender as? MainTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            let destinationVC = segue.destination
            if cell.address == "" {
                let alert = UIAlertController(title: "Alert",
                                  message: "Couldn't find a restaurant.",
                                  actions: [.ok]
                )
                self.present(alert, animated: false)
            } else {
                if let mapVC = destinationVC as? GoogleMapViewController {
                    
                    mapVC.setBizLocation(cell.address)
                    mapVC.setBizCoordinate2D(CLLocationCoordinate2DMake(cell.latitude
                        , cell.longitude))
                    mapVC.setBizName(cell.name.text!)
                    mapVC.setDepartureTime(Int((yelpQueryParams?.openAt)!))
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueToMap" && sender is MainTableViewCell {
            return true
        } else {
            return false
        }
    }
    

}

extension UIImageView {
    func loadImage(from urlString: String) {
        //print("load image from url")
        guard let url = URL(string: urlString) else {
            fatalError("Unexpected url string: \(urlString)")
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let imageData = data else {
                fatalError("error while getting url response: \(String(describing: error?.localizedDescription))")
            }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
