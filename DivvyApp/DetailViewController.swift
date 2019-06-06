//
//  DetailViewController.swift
//  DivvyApp
//
//  Created by Keegan Brown on 6/4/19.
//  Copyright © 2019 Patrick Stacey-Vargas. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {
    
    var selectedResult : JSON?
    var userLocation : CLLocationCoordinate2D?
    var distanceString : String?
    var stationLocation : CLLocationCoordinate2D?
    
    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailMapView.delegate = self
        
        detailMapView.showsUserLocation = true
        
        let name = selectedResult!["stationName"].stringValue
        let availableBikes = selectedResult!["availableBikes"]
        let lat = selectedResult!["latitude"].doubleValue
        let long = selectedResult!["longitude"].doubleValue
        stationLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.title = name
        annotation.subtitle = "Available Bikes: \(availableBikes)"
        annotation.coordinate = stationLocation!
        detailMapView.addAnnotation(annotation)
        
        
        
        stationNameLabel.text = name
        distanceLabel.text =  "\(distanceString!) miles"
        
        //sizes map view
        let latDiff = 2.5 * abs(userLocation!.latitude - selectedResult!["latitude"].doubleValue)
        let longDiff = 2.5 * abs(userLocation!.longitude - selectedResult!["longitude"].doubleValue)
        
        let span = MKCoordinateSpan(latitudeDelta: latDiff, longitudeDelta: longDiff)
        let center = userLocation
        let region = MKCoordinateRegion(center: center!, span: span)
        detailMapView.region = region
        
        getRouteLine(mapItem: MKMapItem(placemark: MKPlacemark(coordinate: stationLocation!)))
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.alpha = 0.5
        return renderer
        
    }
    
    func getRouteLine (mapItem: MKMapItem){
        
        for overlay in self.detailMapView.overlays {
            self.detailMapView.removeOverlay(overlay)
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapItem
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        directions.calculate { (response: MKDirections.Response?, error: Error?) in
            guard let response = response else {return}
            for route in response.routes{
                self.detailMapView.addOverlay(route.polyline)
                print ("added route")
            }
        }
        
    }

}
