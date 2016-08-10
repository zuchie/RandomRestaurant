//
//  MapViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/8/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        map.delegate = self
        map.showsUserLocation = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var region = MKCoordinateRegion()
    
    func setLocation(latitude: Double, longitude: Double) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        region = MKCoordinateRegion(center: center, span: span)
        //map.setRegion(region, animated: true)
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        if fullyRendered {
            print("map has been fully rendered")
            map.setRegion(region, animated: true)
        } else {
            print("map has NOT been fully rendered")
        }
    }
/*
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        //mapView.showsUserLocation = true
        print("map has been fully loaded")
        map.setRegion(region, animated: true)
    }
*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     */
}
