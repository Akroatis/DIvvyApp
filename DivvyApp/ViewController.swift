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
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        locationManager.delegate = self
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        query()
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first
        let center = location!.coordinate
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
        let tvc = segue.destination as! StationsTableViewController
        tvc.results = results
        
    }

}

