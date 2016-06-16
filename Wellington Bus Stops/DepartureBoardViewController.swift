//
//  DepartureBoardViewController.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 4/06/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Cocoa

class DepartureBoardViewController: NSViewController, ITableDataRefreshable, NSTableViewDelegate, NSTableViewDataSource {
    
    var busStop: BusStopLatLng?
    var savedToWidget: Bool
    var sms: String
    
    var departures = [BusDeparture]()
    
    func refreshTableData() {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        setSavedToWidgetStatus(appDelegate.busStopExists(sms))
    }
    
    func setSavedToWidgetStatus(savedToWidget: Bool){
        self.savedToWidget = savedToWidget
        if savedToWidget {
            addOrRemoveBtn.title = "remove"
        } else {
            addOrRemoveBtn.title = "add"
        }
    }

    @IBOutlet weak var busStopNameLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var addOrRemoveBtn: NSButton!
    
    @IBAction func addOrRemoveBusStop(sender: NSButton) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        if !self.savedToWidget {
            appDelegate.saveBusStop(busStop!, completetion: {(busStop: NSManagedObject) -> Void in
                appDelegate.refreshTableData()
                self.setSavedToWidgetStatus(true)
            })
        } else {
            appDelegate.deleteBusStop(sms)
            setSavedToWidgetStatus(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        // Do view setup here.
    }
    
    func populateDepartureBoard(sms: String, savedToWidget: Bool, kill: () -> ()) {
        self.sms = sms
        setSavedToWidgetStatus(savedToWidget)
        BusStopLatLng.getDepartureTimes(sms, completion: {(busStop: BusStopLatLng, departureTimes: [BusDeparture]) -> Void in
            self.busStopNameLabel.stringValue = busStop.name
            self.busStop = busStop
            self.departures.appendContentsOf(departureTimes)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.addOrRemoveBtn.enabled = true
            })
            }, error: kill)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return departures.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if tableColumn!.title == "Route"
        {
            return departures[row].route
        }
        else if tableColumn!.title == "Destination"
        {
            return departures[row].destination
        }
        else if tableColumn!.title == "Departure"
        {
            return departures[row].timeToDeparture.description
        }
        else
        {
            return "ERROR"
        }
    }
    
    required init?(coder: NSCoder) {
        savedToWidget = false
        sms = "4323"
        super.init(coder: coder)
    }
}
