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

class ViewController: NSViewController, MKMapViewDelegate {

    @IBAction func addStop(sender: AnyObject) {
        let alert = NSAlert()
        alert.informativeText = "To add bus stop enter its number below and press okay"
        alert.alertStyle = .InformationalAlertStyle
        alert.messageText = "Bus Stop Number?"
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
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
//        BusStop.getStopsGeo({(busStop: BusStop) -> () in
//            self.mapView.addAnnotation(busStop)
//        })
        BusStop.getStopsCsv({(busStop: BusStop) -> () in
            self.mapView.addAnnotation(busStop)
        })
    }
    
    func addStop2(sms: String) -> Void {
        BusStop.getStop(sms, completion: {(bs: BusStop) -> Void in
//            self.saveBusStop(bs)
            print(bs.name)
        })
    }
    
    var busStops = [NSManagedObject]()

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func saveBusStop(busStop: BusStop) {
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
}

