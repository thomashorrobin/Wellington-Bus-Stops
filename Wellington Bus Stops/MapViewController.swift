//
//  MapViewController.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 12/06/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Cocoa
import MapKit
import CoreLocation

class MapViewController: NSViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        BusStopLatLng.getStopsCsv({(busStop: BusStopLatLng) -> () in
            self.mapView.addAnnotation(busStop)
        })
        let wellingtonRegionMKView = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -41.286103, longitude: 174.775535), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapView.setRegion(wellingtonRegionMKView, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
        }
        
        let bs = annotation as! BusStopLatLng
        
        let button = NSButton()
        button.title = "show"
        button.target = bs
		button.bezelStyle = NSButton.BezelStyle.recessed
        
        button.action = #selector(bs.launchDepartureBoard)
        
        pinView?.rightCalloutAccessoryView = button
        
        
        return pinView
    }
    
}
