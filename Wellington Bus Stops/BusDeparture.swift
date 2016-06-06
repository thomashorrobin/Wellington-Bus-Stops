//
//  BusDeparture.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 6/06/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Foundation
class BusDeparture {
    let route: String
    let destination: String
    let timeToDeparture: TimeToBusDeparture
    
    init(route: String, destination: String, secondsToDeparture: Int){
        self.route = route
        self.destination = destination
        self.timeToDeparture = TimeToBusDeparture(secondsToDeparture: secondsToDeparture)
    }
    
    init(busDeparture: NSDictionary){
        self.route = busDeparture["ServiceID"] as! String
        self.destination = busDeparture["DestinationStopName"] as! String
        self.timeToDeparture = TimeToBusDeparture(secondsToDeparture: Int(busDeparture["DisplayDepartureSeconds"] as! Int))
    }
}