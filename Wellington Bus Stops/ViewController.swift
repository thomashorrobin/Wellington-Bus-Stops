//
//  ViewController.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 28/05/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Cocoa
import MapKit
import CoreData

class ViewController: NSViewController, MKMapViewDelegate, NSTableViewDelegate, NSTableViewDataSource {

    @IBAction func addStop(sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = "Add stop to widget by bus stop number"
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        let tf = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = tf
        let response: NSModalResponse = alert.runModal()
        if response == NSAlertFirstButtonReturn {
            addStop2(tf.stringValue)
        }
    }
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        BusStopLatLng.getStopsCsv({(busStop: BusStopLatLng) -> () in
            self.mapView.addAnnotation(busStop)
        })
        populateBusStops()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return busStops.count //your data ist the array of data for each row
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if tableColumn!.title == "Name" //if you have more columns
        {
            return busStops[row].valueForKey("name")
        }
        else  //second column
        {
            return busStops[row].valueForKey("sms")
        }
    }
    
    func addStop2(sms: String) -> Void {
        BusStopLatLng.getStop(sms, completion: {(bs: BusStopLatLng) -> Void in
            self.saveBusStop(bs)
        })
    }
    
    var busStops = [NSManagedObject]()

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func saveBusStop(busStop: BusStopLatLng) {
        //1
        let appDelegate =
            NSApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("BusStop",
                                                        inManagedObjectContext:managedContext)
        
        let bs = NSManagedObject(entity: entity!,
                                     insertIntoManagedObjectContext: managedContext)
        
        //3
        bs.setValue(busStop.name, forKey: "name")
        bs.setValue(busStop.sms, forKey: "sms")
        
        //4
        do {
            try managedContext.save()
            //5
            busStops.append(bs)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func populateBusStops() {
        
        //1
        let appDelegate =
            NSApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "BusStop")
        
        //3
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            self.busStops = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        //4 - table refeash
        tableView.reloadData()
    }
}

