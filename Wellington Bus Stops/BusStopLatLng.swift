//
//  BusStop.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 28/05/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Foundation
import MapKit

class BusStopLatLng: NSObject, MKAnnotation {
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
    
    @objc
    func launchDepartureBoard(_ sender: AnyObject?) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.openNewDepartureBoardWindow(sms)
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
        self.name = stop["Name"] as! String
        self.sms = stop["Sms"] as! String
        self.latitude = stop["Lat"] as! Double
        self.longitude = stop["Long"] as! Double
        
    }
    
	class func getStop(_ sms: String, completion: @escaping (_ busStop: BusStopLatLng) -> (), error err: @escaping (_ sms: String) -> ()) {
        let getEndpoint: String = "https://backend.metlink.org.nz/api/v1/stops/" + sms.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        let session = URLSession.shared
        let url = URL(string: getEndpoint)!
        let task = session.dataTask(with: url, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            // Make sure we get an OK response
			guard let realResponse = response as? HTTPURLResponse,
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
					err(sms)
                    return
            }
            
            // Read the JSON
            do {
                
                // Parse the JSON to get the IP
                let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                let bs = BusStopLatLng(stop: jsonDictionary)
				completion(bs)
            } catch {
                print("bad things happened")
            }
        })
        
        task.resume()
    }
    
	class func getDepartureTimes(_ sms: String, completion: @escaping (_ busStop: BusStopLatLng, _ departureTimes: [BusDeparture]) -> (), error err: @escaping () -> ()) {
        let getEndpoint: String = "https://api.opendata.metlink.org.nz/v1/stop-predictions?stop_id=" + sms.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        let session = URLSession.shared
        let url = URL(string: getEndpoint)!
        let task = session.dataTask(with: url, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            // Make sure we get an OK response
			guard let realResponse = response as? HTTPURLResponse,
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    err()
                    return
            }
            
            // Read the JSON
            do {
                
                // Parse the JSON to get the IP
                let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                let bs = BusStopLatLng(stop: jsonDictionary["Stop"] as! NSDictionary)
                var departures = [BusDeparture]()
                let departuresArray = jsonDictionary["Services"] as? NSArray
                if departuresArray != nil {
                    for d in departuresArray! {
                        departures.append(BusDeparture(busDeparture: d as! NSDictionary))
                    }
                }
				completion(bs, departures)
            } catch {
                print("bad things happened")
            }
        })
        
        task.resume()
    }
    
	class func getStopsCsv(_ completion: (_ busStop: BusStopLatLng) -> ()) {
		let file = Bundle.main.path(forResource: "stops", ofType:"txt")
        do {
            let csvFile = try NSString(contentsOfFile: file!, encoding: String.Encoding.utf8.rawValue) as String
            let csvLines = csvFile.components(separatedBy: "\n")
            //for i in 1...1500 {
            let endOfCsvFile = csvLines.count - 1
            for i in 1...endOfCsvFile {
                let line = csvLines[i]
                if line != "" {
                    let lineParts = line.components(separatedBy: ",")
                    do {
                        let lat:Double = Double(lineParts[4])!
                        let long:Double = Double(lineParts[5])!
                        let bs = BusStopLatLng(latitude: lat, longitude: long, busStopName: lineParts[2], sms: lineParts[0])
						completion(bs)
                    }
                }
            }
        } catch _ {
            print("do fucking something")
        }
    }
}
