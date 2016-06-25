//
//  TableViewController.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 12/06/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Cocoa

class TableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ITableDataRefreshable {
    
    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    var busStops = [NSManagedObject]()
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        readBusStopsFromCoreData()
        tableView.delegate = self
        tableView.dataSource = self
        appDelegate.tablesToRefresh.append(self)
        tableView.doubleAction = #selector(TableViewController.tableViewDoubleClick)
    }
    
    @IBAction func addRemoveControlsClicked(_ sender: NSSegmentedControl) {
        let clickedButtonIndex = sender.selectedSegment
        if clickedButtonIndex == 0 {
            addBusStopDialog()
        } else if clickedButtonIndex == 1 {
            let selectedRow = tableView.selectedRow
            if selectedRow != -1 {
                appDelegate.deleteBusStop(busStops[selectedRow].value(forKey: "sms")! as! String)
            }
        }
    }
    
    func addBusStopDialog() {
        if Reachability.isConnectedToNetwork(true) {
            let alert = NSAlert()
            alert.messageText = "Add stop to widget by bus stop number"
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            let tf = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            alert.accessoryView = tf
            let response: NSModalResponse = alert.runModal()
            if response == NSAlertFirstButtonReturn {
                appDelegate.addFromSms(tf.stringValue)
            }
        }
    }
    
    func refreshTableData() {
        readBusStopsFromCoreData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return busStops.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if tableColumn!.title == "Name"
        {
            return busStops[row].value(forKey: "name")
        }
        else
        {
            return busStops[row].value(forKey: "sms")
        }
    }
    
    func tableViewDoubleClick(){
        let sms = busStops[tableView.selectedRow].value(forKey: "sms") as! String
        appDelegate.openNewDepartureBoardWindow(sms)
    }
    
    func readBusStopsFromCoreData() {
        busStops.removeAll()
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "BusStop")
        do {
            let results = try managedContext.fetch(fetchRequest)
            self.busStops = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    
}
