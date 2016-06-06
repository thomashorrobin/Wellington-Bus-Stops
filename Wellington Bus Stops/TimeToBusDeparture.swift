//
//  TimeToBusDeparture.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 6/06/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Foundation

struct TimeToBusDeparture {
    let secondsToDeparture: Int
    
    var description:String {
        if secondsToDeparture < 90 {
            return "Due"
        } else if secondsToDeparture < 3600 {
            let minutes: Int = secondsToDeparture / 60
            return minutes.description + "mins"
        } else {
            let hours: Int = secondsToDeparture / 3600
            return hours.description + "hrs"
        }
    }
}