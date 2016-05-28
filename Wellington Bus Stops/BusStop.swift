//
//  BusStop.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 28/05/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Foundation
import MapKit

class BusStop: NSObject, MKAnnotation {
    var name: String
    var sms: String
    var latitude: Double
    var longitude: Double
    
    var title: String? {
        return "Stop: " + sms
    }
    
    var subtitle: String? {
        return name
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, busStopName: String, sms: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = busStopName
        self.sms = sms
    }
    
    init(stop: NSDictionary) {
        self.name = stop["Name"] as! String!
        self.sms = stop["Sms"] as! String!
        self.latitude = Double(stop["Lat"] as! String)!
        self.longitude = Double(stop["Long"] as! String)!
        
    }
    
    class func getStop(sms: String, completion: (busStop: BusStop) -> ()) {
        let getEndpoint: String = "https://www.metlink.org.nz/api/v1/Stop/" + sms.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: getEndpoint)!
        let task = session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                
                // Parse the JSON to get the IP
                let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                let bs = BusStop(stop: jsonDictionary)
                completion(busStop: bs)
            } catch {
                print("bad things happened")
            }
        })
        
        task.resume()
    }
    
    class func getStopsGeo(completion: (busStop: BusStop) -> ()) {
        let getEndpoint: String = "https://www.metlink.org.nz/api/v1/StopNearby/-41.28916701/174.77593559000002"
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: getEndpoint)!
        let task = session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                
                // Parse the JSON to get the IP
                let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                
                for j in jsonDictionary {
                    let bs = BusStop(stop: j as! NSDictionary)
                    completion(busStop: bs)
                }
            } catch {
                print("bad things happened")
            }
        })
        
        task.resume()
    }
}