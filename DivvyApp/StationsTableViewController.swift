//
//  StationsTableViewController.swift
//  DivvyApp
//
//  Created by Keegan Brown on 6/4/19.
//  Copyright © 2019 Patrick Stacey-Vargas. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class StationsTableViewController: UITableViewController {
    
    let apiAddress = "https://feeds.divvybikes.com/stations/stations.json"
    var numberOfStations = 0
    var userLocation : CLLocationCoordinate2D?

    //these will be passed to the detailVC
    var results : [JSON] = []
    var selectedResult : JSON?
    var formattedRouteString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        let result = results[indexPath.row]
        let lat = result["latitude"].doubleValue
        let long = result["longitude"].doubleValue
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        cell?.textLabel!.text = result["stationName"].stringValue
        
        let bikeString = "Available Bikes: \(result["availableBikes"].intValue)"

        self.getDrivingDistance(start: self.userLocation!, end: location, cell: cell!, bikeString: bikeString)
        
        //print ("cell returned")
        return cell!
    }
    
    func getDrivingDistance(start : CLLocationCoordinate2D, end : CLLocationCoordinate2D, cell : UITableViewCell, bikeString: String){
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
                cell.detailTextLabel?.text = ("\(bikeString)\n\(self.formattedRouteString) miles")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedResult = results[indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath)
        formattedRouteString = (selectedCell?.detailTextLabel!.text)!
        performSegue(withIdentifier: "segueToDetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DVC = segue.destination as! DetailViewController
        DVC.selectedResult = selectedResult
        DVC.userLocation = userLocation
        DVC.distanceString = formattedRouteString

    }
    
}
