//
//  DepartureBoardViewController.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 4/06/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Cocoa

class DepartureBoardViewController: NSViewController {

    @IBOutlet weak var busStopNameLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func populateDepartureBoard(sms: String) {
        BusStopLatLng.getStop(sms, completion: {(bs: BusStopLatLng) -> Void in
            self.busStopNameLabel.stringValue = bs.name
        })
    }
    
}
