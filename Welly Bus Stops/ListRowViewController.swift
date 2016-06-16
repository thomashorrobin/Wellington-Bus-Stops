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
    
    @IBOutlet weak var tableView: NSTableView!

    override var nibName: String? {
        return "ListRowViewController"
    }

    override func loadView() {
        super.loadView()
        tableView.setDelegate(self)
        tableView.setDataSource(self)
    }
    
    override func viewDidAppear() {
        let thisBusStop = self.representedObject as! BusStop
        BusStop.getDepartureTimes(thisBusStop.sms, completion: {(busStop: BusStop, departureTimes: [BusDeparture]) -> Void in
            self.departureTimes.appendContentsOf(departureTimes)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return departureTimes.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
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
