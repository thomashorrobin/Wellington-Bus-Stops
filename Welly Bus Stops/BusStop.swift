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
        self.name = stop["Name"] as! String!
        self.sms = stop["Sms"] as! String!
    }
    
    class func getStop(_ sms: String, completion: (busStop: BusStop) -> ()) {
        let getEndpoint: String = "https://www.metlink.org.nz/api/v1/Stop/" + sms.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        let session = URLSession.shared()
        let url = URL(string: getEndpoint)!
        let task = session.dataTask(with: url, completionHandler: { ( data: Data?, response: URLResponse?, error: NSError?) -> Void in
            
            // Make sure we get an OK response
            guard let realResponse = response as? HTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                
                // Parse the JSON to get the IP
                let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                let bs = BusStop(stop: jsonDictionary)
                completion(busStop: bs)
            } catch {
                print("bad things happened")
            }
        })
        
        task.resume()
    }
    
    class func getDepartureTimes(_ sms: String, completion: (busStop: BusStop, departureTimes: [BusDeparture]) -> ()) {
        let getEndpoint: String = "https://www.metlink.org.nz/api/v1/StopDepartures/" + sms.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        let session = URLSession.shared()
        let url = URL(string: getEndpoint)!
        let task = session.dataTask(with: url, completionHandler: { ( data: Data?, response: URLResponse?, error: NSError?) -> Void in
            
            // Make sure we get an OK response
            guard let realResponse = response as? HTTPURLResponse where
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
                    completion(busStop: bs, departureTimes: [BusDeparture]())
                } else {
                    let departuresArray = jsonDictionary["Services"] as! NSArray
                    for d in departuresArray {
                        departures.append(BusDeparture(busDeparture: d as! NSDictionary))
                    }
                    completion(busStop: bs, departureTimes: departures)
                }
            } catch {
                print("bad things happened")
            }
        })
        
        task.resume()
    }
    
    class func searchStops(_ searchTerm: String, completion: (searchResults: [BusStop]) -> Void){
        let getEndpoint: String = "https://www.metlink.org.nz/api/v1/StopSearch/" + searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        let session = URLSession.shared()
        let url = URL(string: getEndpoint)!
        print(url.absoluteString)
        let task = session.dataTask(with: url, completionHandler: { ( data: Data?, response: URLResponse?, error: NSError?) -> Void in
            
            guard let realResponse = response as? HTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            var parsedResults = [BusStop]()
            
            // Read the JSON
            do {
                
                // Parse the JSON to get the IP
                let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                
                for j in jsonDictionary {
                    let bs = BusStop(stop: j as! NSDictionary)
                    parsedResults.append(bs)
                }
            } catch {
                print("bad things happened")
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                completion(searchResults: parsedResults)
            })
        })
        
        task.resume()
    }
}
