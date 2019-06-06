//
//  ViewController.swift
//  DivvyApp
//
//  Created by Patrick Stacey-Vargus on 6/4/19.
//  Copyright © 2019 Patrick Stacey-Vargas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    let apiAddress = "https://feeds.divvybikes.com/stations/stations.json"
    
    var results : [JSON] = []
    
    var userLocation : CLLocationCoordinate2D?
    var selectedLocation : CLLocationCoordinate2D?
    var selectedResult : JSON?
    var formattedRouteString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        query()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        formattedRouteString = ""
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first
        let center = location!.coordinate
        userLocation = location?.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func parse (json: JSON){
        for result in json["stationBeanList"].arrayValue{
            results.append(result)
            let name = result["stationName"].stringValue
            let availableBikes = result["availableBikes"]
            let lat = result["latitude"].doubleValue
            let long = result["longitude"].doubleValue
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.title = name
            annotation.subtitle = "Available Bikes: \(availableBikes)"
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        self.selectedLocation = annotation?.coordinate
        for result in self.results {
            if result["stationName"].stringValue == annotation?.title{
                self.selectedResult = result
                self.getDrivingDistance(start: self.userLocation!, end: self.selectedLocation!)
                
            }
        }
        DispatchQueue.main.async {
            self.segueCheck()
        }
    }
    
    func loadError(){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Loading Error", message: "There was an issue loading bus stop data.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }
    
    func query(){
        let query = apiAddress
        
        DispatchQueue.global(qos: .userInitiated).async {
            [unowned self] in
            if let url = URL(string: query){
                if let data = try? Data(contentsOf: url){
                    let json = try! JSON(data: data)
                    self.parse(json: json)
                    return
                }
            }
            self.loadError()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToDetailVCFromMap"{
            let DVC = segue.destination as! DetailViewController
            DVC.userLocation = userLocation
            DVC.selectedResult = selectedResult
            let bikes = selectedResult!["availableBikes"]
            formattedRouteString = "Available Bikes: \(bikes)\nDistance: \(formattedRouteString)"
            DVC.distanceString = formattedRouteString
        } else{
            let tvc = segue.destination as! StationsTableViewController
            tvc.results = results
            tvc.userLocation = userLocation
        }
        
    }
    
    func getDrivingDistance(start : CLLocationCoordinate2D, end : CLLocationCoordinate2D){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            if let response = response, let route = response.routes.first {
                print(route.distance)
                //converts from meters to miles
                let routeDistance = route.distance / 1609.34
                //formats the string to two decimals.
                self.formattedRouteString = String(format: "%.02f" , routeDistance)
            }
        }
    }
    
    func segueCheck() {
        if formattedRouteString == "" {
            DispatchQueue.main.async {
                self.segueCheck()
            }
        } else{
            self.performSegue(withIdentifier: "segueToDetailVCFromMap", sender: nil)
        }
    }
    
}

