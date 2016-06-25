//
//  ListRowViewController.swift
//  Welly Bus Stops
//
//  Created by Thomas Horrobin on 28/05/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Cocoa

class ListRowViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var departureTimes = [BusDeparture]()
    var sms = "4323"
    
    @IBAction func refreshDepatureData(_ sender: AnyObject) {
        self.departureTimes.removeAll()
        self.tableView.reloadData()
        BusStop.getDepartureTimes(sms, completion: {(busStop: BusStop, departureTimes: [BusDeparture]) -> Void in
            self.departureTimes.append(contentsOf: departureTimes)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
    }
    
    @IBOutlet weak var tableView: NSTableView!

    override var nibName: String? {
        return "ListRowViewController"
    }

    override func loadView() {
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear() {
        let thisBusStop = self.representedObject as! BusStop
        sms = thisBusStop.sms
        BusStop.getDepartureTimes(thisBusStop.sms, completion: {(busStop: BusStop, departureTimes: [BusDeparture]) -> Void in
            self.departureTimes.append(contentsOf: departureTimes)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return departureTimes.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if tableColumn!.title == "Route"
        {
            return departureTimes[row].route
        }
        else if tableColumn!.title == "Destination"
        {
            return departureTimes[row].destination
        }
        else if tableColumn!.title == "Departs"
        {
            return departureTimes[row].timeToDeparture.description
        }
        else
        {
            return "ERROR"
        }
    }

}
