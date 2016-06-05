//
//  DepartureBoardViewController.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 4/06/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Cocoa

class DepartureBoardViewController: NSViewController {
    
    var busStop: BusStopLatLng?
    var savedToWidget = false

    @IBOutlet weak var busStopNameLabel: NSTextField!
    @IBOutlet weak var addOrRemoveBtn: NSButton!
    
    @IBAction func addOrRemoveBusStop(sender: NSButton) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveBusStop(busStop!, completetion: {(busStop: NSManagedObject) -> Void in
            self.savedToWidget = true
            appDelegate.refreshTableData()
            self.addOrRemoveBtn.title = "remove"
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func populateDepartureBoard(sms: String) {
        BusStopLatLng.getStop(sms, completion: {(bs: BusStopLatLng) -> Void in
            self.busStopNameLabel.stringValue = bs.name
            self.busStop = bs
        })
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
