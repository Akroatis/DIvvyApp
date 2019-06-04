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
        cell?.textLabel!.text = result["stationName"].stringValue
        print ("cell returned")
        return cell!
    }
    
}
