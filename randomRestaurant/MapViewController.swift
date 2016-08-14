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
    @IBOutlet weak var distanceAndETA: UILabel!
    
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

    private var myLocation: CLLocationCoordinate2D? = nil
    private var bizLocation: CLLocationCoordinate2D? = nil
    func setMyLocation(coordinates: CLLocationCoordinate2D) {
        myLocation = coordinates
    }
    func setBizLocation(coordinates: CLLocationCoordinate2D) {
        bizLocation = coordinates
    }
    
    private var mapBrain = MapBrain()
    
    private var mapHasBeenLoaded = false
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        print("map has been loaded")
        if !mapHasBeenLoaded {
            if myLocation != nil {
                print("show my location")
                mapBrain.setMyLocationBrain(myLocation!)
                mapBrain.drawLocation("my")
                map.setRegion(mapBrain.region, animated: true)
            }
            if bizLocation != nil {
                print("pin biz location")
                mapBrain.setBizLocationBrain(bizLocation!)
                mapBrain.drawLocation("biz")
                let annotation = BizAnnotation(title: "My", locationName: "biz", coordinate: mapBrain.center)
                map.addAnnotation(annotation)
                calculateETAAndPlotRoute()
            }
            mapHasBeenLoaded = true
        }
    }
    
    // Referenced to: http://stackoverflow.com/questions/24523702/stuck-on-using-mkpinannotationview-within-swift-and-mapkit/24532551#24532551
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("into mapView")
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            print("annotation returned nil")
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
        print("annotation returned pin view")
        return pinView
    }
    
    private func calculateETAAndPlotRoute() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: myLocation!, addressDictionary: nil ))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: bizLocation!, addressDictionary: nil ))
        request.requestsAlternateRoutes = false
        request.transportType = .Automobile
        request.departureDate = NSDate()
        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler {
            response, error in
            print("plot route")
            if error != nil {
                print("error while calculating directions: \(error) ")
            }
            if let unwrappedResponse = response {
                for route in unwrappedResponse.routes {
                    // Show distance & ETA.
                    let distanceInMi = Int(route.distance / 1609.344)
                    let etaInMinutes = Int(route.expectedTravelTime / 60)
                    self.distanceAndETA.text = "\(distanceInMi) mi, \(etaInMinutes) min"
                    // Plot route.
                    self.map.addOverlay(route.polyline)
                    // Adjust visible area.
                    let mapRect = route.polyline.boundingMapRect
                    var edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                    if route.polyline.intersectsMapRect(mapRect) {
                        print("map intersects")
                        edgeInsets.top = 40
                        edgeInsets.bottom = 40
                        edgeInsets.left = 40
                        edgeInsets.right = 40
                    }
                    self.map.setVisibleMapRect(mapRect, edgePadding: edgeInsets, animated: true)
                    
                }
            } else {
                print("response for calculate direction is nil")
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5
        renderer.alpha = 0.5
        return renderer
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
