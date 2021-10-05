//
//  DepartureBoardViewController.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 4/06/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Cocoa

enum DepartureBoardErrors: Error {
	case dataDoesntExist
}

class DepartureBoardViewController: NSViewController, ITableDataRefreshable, NSTableViewDelegate, NSTableViewDataSource {
    
    var busStop: BusStopLatLng?
    var savedToWidget: Bool
    var sms: String
    
    var departures = [BusDeparture]()
    
    func refreshTableData() {
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
        setSavedToWidgetStatus(appDelegate.busStopExists(sms))
    }
    
    func setSavedToWidgetStatus(_ savedToWidget: Bool){
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
    
    @IBAction func refreshDepartureData(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            self.departures.removeAll()
            self.tableView.reloadData()
        })
        BusStopLatLng.getDepartureTimes(sms, completion: {(busStop: BusStopLatLng, departureTimes: [BusDeparture]) -> Void in
            self.departures.append(contentsOf: departureTimes)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })}, error: {})
    }
    
    @IBAction func addOrRemoveBusStop(_ sender: NSButton) {
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
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
        tableView.delegate = self
        tableView.dataSource = self
        // Do view setup here.
    }
    
	func populateDepartureBoard(_ sms: String, savedToWidget: Bool, kill: @escaping () -> ()) {
        self.sms = sms
        setSavedToWidgetStatus(savedToWidget)
        BusStopLatLng.getDepartureTimes(sms, completion: {(busStop: BusStopLatLng, departureTimes: [BusDeparture]) -> Void in
            self.busStopNameLabel.stringValue = busStop.name
            self.busStop = busStop
            self.departures.append(contentsOf: departureTimes)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.addOrRemoveBtn.isEnabled = true
            })
            }, error: kill)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return departures.count
    }
    
	private func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) throws -> AnyObject? {

        if tableColumn!.title == "Route"
        {
			return departures[row].route as AnyObject
        }
        else if tableColumn!.title == "Destination"
        {
            return departures[row].destination as AnyObject
        }
        else if tableColumn!.title == "Departure"
        {
            return departures[row].timeToDeparture.description as AnyObject
        }
        else
        {
			throw DepartureBoardErrors.dataDoesntExist
			
        }
    }
    
    required init?(coder: NSCoder) {
        savedToWidget = false
        sms = "4323"
        super.init(coder: coder)
    }
}
