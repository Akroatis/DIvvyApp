//
//  StationsTableViewController.swift
//  DivvyApp
//
//  Created by Keegan Brown on 6/4/19.
//  Copyright © 2019 Patrick Stacey-Vargas. All rights reserved.
//

import UIKit
import CoreLocation

class StationsTableViewController: UITableViewController {
    
    let apiAddress = "https://feeds.divvybikes.com/stations/stations.json"
    var numberOfStations = 0
    
//    var names : [String] = []
//    var location : [CLLocationCoordinate2D] = []
//    var bikes : [Int] = []
    
    var results : [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        query()
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfStations
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        let result = results[indexPath.row]
        cell?.textLabel!.text = result["stationName"].stringValue
        print ("cell returned")
        return cell!
    }
    
    
    
    func parse(json : JSON){
        numberOfStations = json["stationBeanList"].arrayValue.count
        for result in json["stationBeanList"].arrayValue{
            results.append(result)
            let name = result["stationName"].stringValue
            let availableBikes = result["availableBikes"].intValue
            let lat = result["latitude"].doubleValue
            let long = result["longitude"].doubleValue
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
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
    
    func loadError(){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Loading Error", message: "There was an issue loading bus stop data.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }
}
