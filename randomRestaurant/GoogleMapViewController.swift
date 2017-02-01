//
//  GoogleMapViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/30/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapViewController: UIViewController {
    
    fileprivate var location: String?
    fileprivate var bizCoordinate2D: CLLocationCoordinate2D?
    fileprivate var bizName: String?
    fileprivate var departureTime: Int?
    fileprivate var drawRoute = GetDirection()
    fileprivate var mapView: GMSMapView!
    
    fileprivate var label = UILabel()
    //fileprivate var button = UIButton()
    
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
    
    // KVO - Key Value Observer, to observe changes of mapView.myLocation.
    override func viewWillAppear(_ animated: Bool) {
        view.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
    }
    /*
    // Deregister observer.
    override func viewWillDisappear(animated: Bool) {
        view.removeObserver(self, forKeyPath: "myLocation")
    }
    */

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //if keyPath == "myLocation" && ((object as AnyObject).isKind(of: GMSMapView())) {
        if keyPath == "myLocation" && object is GMSMapView {
            
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
                
                print("distance: \(distances.first!), duration in traffic: \(durationInTraffic), viewport: \(viewport.northeast!), \(viewport.southwest!)")
                
                DispatchQueue.main.async(execute: {
                    
                    // Update camera to new bounds.
                    let bounds = GMSCoordinateBounds(coordinate: viewport.northeast!, coordinate: viewport.southwest!)
                    let edges = UIEdgeInsetsMake(120, 40, 40, 40)
                    let camera = GMSCameraUpdate.fit(bounds, with: edges)
                    
                    print("update camera")
                    self.mapView.animate(with: camera)
                    
                    self.label.text = "\(distances.first!), \(durationInTraffic)"
                })
            }

        }
        // Deregister observer, to stop myLocation from updating.
        view.removeObserver(self, forKeyPath: "myLocation")
    }
    
    override func loadView() {
        //super.loadView()
        
        // Create a GMSCameraPosition that tells the map to display the
        // business position at zoom level 12.
        let camera = GMSCameraPosition.camera(withTarget: bizCoordinate2D!, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        //mapView = GMSMapView()

        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = bizCoordinate2D!
        marker.title = bizName
        marker.snippet = location
        marker.map = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    // Open Google Maps app for navigation. Need to add "comgooglemaps", and "comgooglemaps-x-callback" into plist "LSApplicationQueriesSchemes" array.
    @IBAction func StartNavigation(_ sender: UIBarButtonItem) {
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
