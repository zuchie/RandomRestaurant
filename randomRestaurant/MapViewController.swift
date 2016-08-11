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
    /*
    var region = MKCoordinateRegion()
    */
    private var myLocation: CLLocationCoordinate2D? = nil
    private var bizLocation: CLLocationCoordinate2D? = nil
    func setMyLocation(coordinates: CLLocationCoordinate2D) {
        myLocation = coordinates
    }
    func setBizLocation(coordinates: CLLocationCoordinate2D) {
        bizLocation = coordinates
    }
    
    private var mapBrain = MapBrain()
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        if fullyRendered {
            print("map has been fully rendered")
            if myLocation != nil {
                mapBrain.setMyLocation(myLocation!)
                mapBrain.drawLocation("my")
                map.setRegion(mapBrain.region, animated: true)
            }
            if bizLocation != nil {
                print("pin biz")
                mapBrain.setBizLocation(bizLocation!)
                mapBrain.drawLocation("biz")
                let annotation = BizAnnotation(title: "My", locationName: "biz", coordinate: mapBrain.center)
                map.addAnnotation(annotation)
            }

        } else {
            print("map has NOT been fully rendered")
        }
    }
    // Referenced to: https://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial & http://stackoverflow.com/questions/24523702/stuck-on-using-mkpinannotationview-within-swift-and-mapkit/24532551#24532551
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("into mapView")
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = UIColor.redColor()
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
        
        /*
        if let annotation = annotation as? BizAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                //view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView
            }
            return view
        }
        return nil
        */
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
