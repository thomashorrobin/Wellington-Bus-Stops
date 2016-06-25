//
//  Reachability.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 23/06/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

//import Foundation
import Cocoa
import SystemConfiguration

public class Reachability {
    class func isConnectedToNetwork(_ alertUser: Bool) -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let connected = isReachable && !needsConnection
        if alertUser && !connected {
            let alert = NSAlert()
            alert.messageText = "You're not connected to the internet."
            alert.informativeText = "Wellington Bus Stops requires a internet connection to work properly. Please connect to the internet and try again :)"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        return connected
    }
}
