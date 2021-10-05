//
//  BusStop.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 30/05/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Foundation

class BusStop: NSObject {
    var name: String
    var sms: String
    
    override var description: String{
        return name
    }
    
    init(busStopName: String, sms: String) {
        self.name = busStopName
        self.sms = sms
    }
    
    init(stop: NSDictionary) {
		self.name = stop["Name"] as! String
		self.sms = stop["Sms"] as! String
    }
    
	class func getStop(_ sms: String, completion: (_ busStop: BusStop) -> ()) {
        let getEndpoint: String = "https://backend.metlink.org.nz/api/v1/stops/" + sms.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        let url = URL(string: getEndpoint)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            // Make sure we get an OK response
			guard let realResponse = response as? HTTPURLResponse,
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                
                // Parse the JSON to get the IP
                let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                let bs = BusStop(stop: jsonDictionary)
				completion(bs)
            } catch {
                print("bad things happened")
            }
        })
        
        task.resume()
    }
    
	class func getDepartureTimes(_ sms: String, completion: (_ busStop: BusStop, _ departureTimes: [BusDeparture]) -> ()) {
        let getEndpoint: String = "https://api.opendata.metlink.org.nz/v1/stop-predictions?stop_id=" + sms.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        let session = URLSession.shared
        let url = URL(string: getEndpoint)!
        let task = session.dataTask(with: url, completionHandler: { ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            // Make sure we get an OK response
			guard let realResponse = response as? HTTPURLResponse,
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                
                // Parse the JSON to get the IP
                let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                let bs = BusStop(stop: jsonDictionary["Stop"] as! NSDictionary)
                var departures = [BusDeparture]()
                let services = jsonDictionary["Services"]
                if services == nil {
					completion(bs, [BusDeparture]())
                } else {
                    let departuresArray = jsonDictionary["Services"] as! NSArray
                    for d in departuresArray {
                        departures.append(BusDeparture(busDeparture: d as! NSDictionary))
                    }
					completion(bs, departures)
                }
            } catch {
                print("bad things happened")
            }
        })
        
        task.resume()
    }
}
