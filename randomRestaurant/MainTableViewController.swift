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
    
    // Properties
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var category: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var moc: NSManagedObjectContext!

    fileprivate var locationManager = LocationManager.shared
    fileprivate var yelpQueryParams: YelpUrlQueryParameters?
    fileprivate var yelpQuery: YelpQuery!
    
    fileprivate var restaurants = [[String: Any]]()
    fileprivate var imgCache = Cache<String>()
    
    fileprivate let yelpStars: [Float: String] = [0.0: "regular_0", 1.0: "regular_1", 1.5: "regular_1_half", 2.0: "regular_2", 2.5: "regular_2_half", 3.0: "regular_3", 3.5: "regular_3_half", 4.0: "regular_4", 4.5: "regular_4_half", 5.0: "regular_5"]
    
    struct QueryParams {
        var hasChanged: Bool {
            return categoryChanged || dateChanged || locationChanged
        }
        var categoryChanged = false
        var dateChanged = false
        var locationChanged = false
        
        var category = "" {
            didSet { categoryChanged = (category != oldValue) }
        }
        var date = Date() {
            didSet { dateChanged = (date != oldValue) }
        }
        var location = CLLocation() {
            didSet { locationChanged = (location != oldValue) }
        }
    }
    
    var queryParams = QueryParams()
    var imageCount = 0
    
    // Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MainTableViewController view did load")
        
        moc = appDelegate?.managedObjectContext

        // tableView Cell
        let cellNib = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "mainCell")
        
        // Header
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        header.addGestureRecognizer(tap)
        
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        // Start query once location has been got
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
        
        getCategoryAndUpdateHeader("restaurants")
        getDate()
    }
    
    @objc fileprivate func handleRefresh(_ sender: UIRefreshControl) {
        print("handle refresh")
        getDate()
        getLocationAndStartQuery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //print("Main view will appear, reload table")
        // Reload visible cells to sync like button status with Saved.
        //tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Cache
    fileprivate func loadImagesToCache(from url: String) {
        guard let urlString = URL(string: url) else {
            fatalError("Unexpected url string while loading image: \(url)")
        }
        URLSession.shared.dataTask(with: urlString) { data, response, error in
            guard error == nil, let imageData = data else {
                print("Error while getting image url response: \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                print("Couldn't create image from data: \(imageData)")
                return
            }

            self.imgCache.add(key: url, value: image)
            self.imageCount -= 1
            
            // Reload table after the last image has been saved.
            if self.imageCount == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }.resume()
    }
    
    // Core Data
    func updateSaved(cell: MainTableViewCell, button: UIButton) {
        if button.isSelected {
            print("Save object")
            let saved = NSEntityDescription.insertNewObject(forEntityName: "Saved", into: moc) as! SavedMO
            
            saved.name = cell.name.text
            saved.categories = cell.category.text
            saved.yelpUrl = cell.yelpUrl
        } else {
            // TODO: Add url or address besides name for predicate
            let request: NSFetchRequest<SavedMO> = NSFetchRequest(entityName: "Saved")
            request.predicate = NSPredicate(format: "name == %@", cell.name.text!)
            
            guard let object = try? moc.fetch(request).first else {
                fatalError("Error fetching object in context")
            }
            
            guard let obj = object else {
                print("Didn't find object in context")
                return
            }
            
            moc.delete(obj)
            print("Deleted from Saved entity")
        }
        
        appDelegate?.saveContext()
    }
    
    // Is the object with name in Saved?
    fileprivate func objectSaved(name: String) -> Bool {
        // TODO: Add url or address besides name for predicate
        let request = NSFetchRequest<SavedMO>(entityName: "Saved")
        request.predicate = NSPredicate(format: "name == %@", name)
        guard let object = try? moc.fetch(request).first else {
            fatalError("Error fetching from context")
        }
        
        guard (object != nil) else {
            return false
        }
        
        return true
    }
    
    // Prepare params and do query
    fileprivate func getCategoryAndUpdateHeader(_ category: String) {
        getCategory(category)
        updateHeader(category)
    }
    
    fileprivate func getCategory(_ category: String) {
        queryParams.category = category
    }
    
    fileprivate func updateHeader(_ category: String) {
        let header = (category == "restaurants" ? "What: all" : category)
        self.category.text = header
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
                self.imgCache.removeAll(keepingCapacity: false)
                self.imageCount = self.restaurants.count
                
                if self.imageCount == 0 {
                    let alert = UIAlertController(
                        title: "No results",
                        message: "Sorry, couldn't find any restaurant.",
                        actions: [.ok])
                    
                    alert.show()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    return
                }
                //refreshControl?.endRefreshing()
                
                for member in self.restaurants {
                    self.loadImagesToCache(from: member["image_url"] as! String)
                }
            }

            yelpQuery.startQuery()
            
            queryParams.categoryChanged = false
            queryParams.dateChanged = false
            queryParams.locationChanged = false
        } else {
            print("Params no change, skip query")
        }
    }
    /*
    enum Operation {
        case getValue(([String: Any], String) -> Any)
    }
    
    private var operations: [String: Operation] = [
        "image_url": Operation.getValue({ $0[$1] as Any }),
        "name": Operation.getValue({ $0[$1] as Any }),
        "categories": Operation.getValue({
            guard let categories = $0[$1] as? [[String: String]] else {
                fatalError("Couldn't get categories from: \(String(describing: $0[$1]))")
            }
            let categoriesString = categories.reduce("", { $0 + $1["title"]! }).characters.dropLast(2)
            return String(categoriesString)
        }),
        "rating": Operation.getValue({ $0[$1] as Any }),
        "review_count": Operation.getValue({ (String($0[$1] as! Int) + " reviews") as Any }),
        "price": Operation.getValue({ $0[$1] as Any }),
        "url": Operation.getValue({ $0[$1] as Any }),
        "coordinates": Operation.getValue({ $0[$1] as Any }),
        "location": Operation.getValue({
            guard let location = $0[$1] as? [String: Any] else {
                fatalError("Couldn't get location from: \(String(describing: $0[$1]))")
            }
            guard let address = Address(of: location) else {
                fatalError("Couldn't compose address from location: \(location)")
            }
            
            return address.composeAddress()
        })
    ]
    */
    fileprivate func process(dict: [String: Any], key: String) -> Any? {
        switch key {
        case "image_url", "name", "price", "url", "rating", "review_count", "coordinates":
            return dict[key]
        case "categories":
            guard let categories = dict[key] as? [[String: String]] else {
                fatalError("Couldn't get categories from: \(String(describing: dict[key]))")
            }
            let categoriesString = categories.reduce("", { $0 + $1["title"]! }).characters.dropLast(2)
            return String(categoriesString)
        case "location":
            guard let location = dict[key] as? [String: Any] else {
                fatalError("Couldn't get location from: \(String(describing: dict[key]))")
            }
            guard let address = Address(of: location) else {
                fatalError("Couldn't compose address from location: \(location)")
            }
            return address.composeAddress()
        default:
            fatalError("Key not expected: \(key)")
        }
    }
    
    fileprivate func getRatingStar(from rating: Float) -> UIImage {
        guard let name = yelpStars[rating] else {
            fatalError("Couldn't get image name from rating: \(rating)")
        }
        guard let image = UIImage(named: name) else {
            fatalError("Couldn't get image from name: \(name)")
        }
        return image
    }
    
    // Table view
    fileprivate func configureCell(_ cell: MainTableViewCell, _ indexPath: IndexPath) {
        print("configure cell")
        let content = restaurants[indexPath.row]
        // Image
        cell.imageUrl = process(dict: content, key: "image_url") as? String
        var image: UIImage?
        if let value = imgCache.get(by: cell.imageUrl) as? UIImage {
            print("found image in cache")
            image = value
        } else {
            // TODO: Pick a globe image
            print("use globe image")
            image = UIImage(named: "globe")
        }
        
        DispatchQueue.main.async {
            cell.mainImage.image = image
        }
        // Name
        cell.name.text = process(dict: content, key: "name") as? String
        // Categories
        cell.category.text = process(dict: content, key: "categories") as? String
        // Rating
        cell.rating = process(dict: content, key: "rating") as? Float
        cell.ratingImage.image = getRatingStar(from: cell.rating)
        
        //cell.reviewsTotal = process(dict: content, key: "review_count") as? Int
        cell.reviewCount.text = process(dict: content, key: "review_count") as? String
        cell.price.text = process(dict: content, key: "price") as? String
        cell.yelpUrl = process(dict: content, key: "url") as? String
        cell.latitude = (process(dict: content, key: "coordinates") as? [String: Double])?["latitude"]
        cell.longitude = (process(dict: content, key: "coordinates") as? [String: Double])?["longitude"]
        
        //let location: PickedBusinessLocation = PickedBusinessLocation(businessObj: (process(dict: content, key: "location") as? [String: Any])!)!
        cell.address = process(dict: content, key: "location") as? String
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueToMap" && sender is MainTableViewCell {
            return true
        } else {
            return false
        }
    }

    // Segue to Category view controller
    @objc fileprivate func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard (sender.view != nil) else {
            fatalError("Unexpected view: \(String(describing: sender.view))")
        }
        performSegue(withIdentifier: "segueToCategories", sender: self)
    }
    
    // Segue to Map view controller
    func showMap(cell: MainTableViewCell) {
        performSegue(withIdentifier: "segueToMap", sender: cell)
    }
    
    // Link to Yelp app/website
    func linkToYelp(cell: MainTableViewCell) {
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
    
    @IBAction func unwindToMain(sender: UIStoryboardSegue) {
        print("Unwind to main")
        
        let sourceVC = sender.source
        guard sender.identifier == "backFromWhat" else {
            fatalError("Unexpeted id: \(String(describing: sender.identifier))")
        }
        
        guard let category = (sourceVC as! FoodCategoriesCollectionViewController).getCategory() else {
            fatalError("Couldn't get category")
        }
        
        getCategoryAndUpdateHeader(category)
        getDate()
        getLocationAndStartQuery()
    }
}

/*
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
*/
