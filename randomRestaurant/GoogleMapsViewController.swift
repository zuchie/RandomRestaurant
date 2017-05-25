//
//  GoogleMapsViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/30/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapsViewController: UIViewController {
    
    fileprivate var location: String?
    fileprivate var bizCoordinate2D: CLLocationCoordinate2D?
    fileprivate var bizName: String?
    fileprivate var departureTime: Int?
    fileprivate var drawRoute = GoogleMapsGetDirection()
    fileprivate var mapView: GMSMapView!
    fileprivate var isNavigationBarHidden: Bool?

    fileprivate var label = UILabel()
    
    var businesses = [MainTableViewController.DataSource()]
    var markersOnly = false
    private var barButtonItem: UIBarButtonItem!
    
    func getBusinesses(_ data: [MainTableViewController.DataSource]) {
        markersOnly = true
        businesses = data
    }
    
    func setBizLocation(_ location: String) {
        self.location = location
    }
    
    func setBizCoordinate2D(_ coordinate2D: CLLocationCoordinate2D) {
        self.bizCoordinate2D = coordinate2D
    }
    
    func setBizName(_ name: String) {
        self.bizName = name
    }

    func setDepartureTime(_ time: Int) {
        // Convert back from local time to UTC for Google Maps API departure_time use.
        self.departureTime = time - NSTimeZone.local.secondsFromGMT()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRoute.completionWithError = { error in
            let alert = UIAlertController(
                title: "Error: \(String(describing: error?.localizedDescription))",
                message: "Oops, looks like the Google Maps server is not available now, please try again at a later time.",
                actions: [.ok]
            )
            DispatchQueue.main.async {
                self.present(alert, animated: false, completion: { return })
            }
        }
        
        if !markersOnly {
            // Add label.
            let screenBounds = UIScreen.main.bounds
            let labelWidth: CGFloat = screenBounds.width * 0.5
            let labelHeight: CGFloat = labelWidth / 9.0
            
            label.frame = CGRect(x: screenBounds.width / 2.0 - labelWidth / 2.0, y: screenBounds.height - labelHeight , width: labelWidth, height: labelHeight)
            label.backgroundColor = UIColor.lightGray
            label.textAlignment = .center
            label.textColor = UIColor.white
            label.adjustsFontSizeToFitWidth = true
            
            view.addSubview(label)
        }
    }
    
    // KVO - Key Value Observer, to observe changes of mapView.myLocation.
    override func viewWillAppear(_ animated: Bool) {
        /*
        isNavigationBarHidden = navigationController?.isNavigationBarHidden
        if isNavigationBarHidden! {
            navigationController?.isNavigationBarHidden = false
        }
        */
        //tabBarController?.tabBar.isHidden = true
        
        if markersOnly {
            barButtonItem = navigationItem.rightBarButtonItem
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.title = "Route"
        }
        
        view.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
    }

    // Restore navigation bar status.
    override func viewWillDisappear(_ animated: Bool) {
        /*
        if isNavigationBarHidden! {
            navigationController?.isNavigationBarHidden = true
        }
        */
        if markersOnly {
            navigationItem.rightBarButtonItem = barButtonItem
        }
        //tabBarController?.tabBar.isHidden = false
        //view.removeObserver(self, forKeyPath: "myLocation")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "myLocation" && object is GMSMapView {
            
            if markersOnly {
                var coordinates = [CLLocationCoordinate2D]()
                for member in businesses {
                    guard let location = member.location else {
                        fatalError("Couldn't get location from businesses.")
                    }
                    coordinates.append(location)
                }
                if let myCoordinate = mapView.myLocation?.coordinate {
                    coordinates.append(myCoordinate)
                } else {
                    print("Couldn't get my location.")
                    let alert = UIAlertController(
                        title: "Missing your location",
                        message: "The Google Maps can't get your location, please try again at a later time.",
                        actions: [.ok]
                    )
                    DispatchQueue.main.async {
                        self.present(alert, animated: false, completion: nil)
                    }
                }
                
                guard let minLat = coordinates.map({ $0.latitude }).min(by: { Swift.abs($0) < Swift.abs($1) }),
                let minLong = coordinates.map({ $0.longitude }).min(by: { Swift.abs($0) < Swift.abs($1) }),
                let maxLat = coordinates.map({ $0.latitude }).max(by: { Swift.abs($0) < Swift.abs($1) }),
                    let maxLong = coordinates.map({ $0.longitude }).max(by: { Swift.abs($0) < Swift.abs($1) }) else {
                        fatalError("Could min, max coordinates.")
                }
                
                let northeast = CLLocationCoordinate2DMake(minLat, minLong)
                let southwest = CLLocationCoordinate2DMake(maxLat, maxLong)
                
                DispatchQueue.main.async {
                    // Update camera to new bounds.
                    let bounds = GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
                    let edges = UIEdgeInsetsMake(120, 40, 70, 40)
                    let camera = GMSCameraUpdate.fit(bounds, with: edges)
                    
                    //print("update camera")
                    self.mapView.animate(with: camera)
                }
            } else {
                // Draw route.
                drawRoute.makeGoogleDirectionsUrl(
                    "https://maps.googleapis.com/maps/api/directions/json?",
                    origin: mapView.myLocation!.coordinate,
                    dest: bizCoordinate2D!,
                    depart: departureTime!,
                    key: "AIzaSyA-vPWnAEHdO3V4TwUbedRuJO1mDEgIjr0"
                )
                
                drawRoute.makeUrlRequest() { routesPoints, distances, durationInTraffic, viewport in
                    
                    // Draw from returned polyline.
                    for points in routesPoints {
                        //print("poly points: \(points)")
                        DispatchQueue.main.async(execute: {
                            let path = GMSMutablePath(fromEncodedPath: points)
                            let polyline = GMSPolyline(path: path)
                            polyline.strokeWidth = 3
                            
                            polyline.map = self.mapView
                        })
                    }
                    
                    //print("distance: \(distances.first!), duration in traffic: \(durationInTraffic), viewport: \(viewport.northeast!), \(viewport.southwest!)")
                    
                    DispatchQueue.main.async(execute: {
                        
                        // Update camera to new bounds.
                        let bounds = GMSCoordinateBounds(coordinate: viewport.northeast!, coordinate: viewport.southwest!)
                        let edges = UIEdgeInsetsMake(120, 40, 70, 40)
                        let camera = GMSCameraUpdate.fit(bounds, with: edges)
                        
                        //print("update camera")
                        self.mapView.animate(with: camera)
                        
                        self.label.text = "\(distances.first!), \(durationInTraffic)"
                    })
                }
            }

        }
        // Deregister observer, to stop myLocation from updating.
        view.removeObserver(self, forKeyPath: "myLocation")
    }
    
    override func loadView() {
        //super.loadView()
        
        // Create a GMSCameraPosition that tells the map to display the
        // business position at zoom level 12.
        //print("==loadview")
        let target: CLLocationCoordinate2D
        if markersOnly {
            target = businesses[0].location!
        } else {
            target = bizCoordinate2D!
        }
        let camera = GMSCameraPosition.camera(withTarget: target, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        view = mapView
        
        if markersOnly {
            for member in businesses {
                let marker = GMSMarker()
                marker.position = member.location!
                marker.title = member.name
                marker.snippet = member.address
                marker.map = mapView
            }
        } else {
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = bizCoordinate2D!
            marker.title = bizName
            marker.snippet = location
            marker.map = mapView
        }
    }
    
    // Open Google Maps app for navigation. Need to add "comgooglemaps", and "comgooglemaps-x-callback" into plist "LSApplicationQueriesSchemes" array.
    @IBAction func StartNavigation(_ sender: UIBarButtonItem) {
        print("start navigation")
        let bizLat = bizCoordinate2D?.latitude
        let bizlng = bizCoordinate2D?.longitude
        let testURL = URL(string: "comgooglemaps-x-callback://")
        let app = UIApplication.shared
        if app.canOpenURL(testURL!) {
            let directionsRequest = "comgooglemaps-x-callback://" +
                "?daddr=\(bizLat!),\(bizlng!)" + "&x-success=sourceapp://?resume=true&x-source=AirApp";
            let directionsURL = URL(string: directionsRequest)
            UIApplication.shared.openURL(directionsURL!)
        } else {
            NSLog("Can't use comgooglemaps-x-callback:// on this device.");
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
