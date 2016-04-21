//
//  MapViewController.swift
//  Location
//
//  Created by Samuli Tamminen on 20.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var timer = NSTimer()
    
    override func viewWillAppear(animated: Bool) {
        updateMap(timer)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateMap:", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    
    func updateMap(timer: NSTimer) {
        if currentExerciseLocations.count > 0 {
            print("updateMap")
            mapView.setRegion(mapRegion(), animated: true)
            mapView.addOverlay(polyline())
        }
    }
    
    
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc: CLLocation = currentExerciseLocations.first!
        
        var minLat = initialLoc.coordinate.latitude
        var minLon = initialLoc.coordinate.longitude
        var maxLat = minLat
        var maxLon = minLon
        
        // Get the min and max coordinates
        for location in currentExerciseLocations {
            minLat = min(minLat, location.coordinate.latitude)
            minLon = min(minLon, location.coordinate.longitude)
            maxLat = max(maxLat, location.coordinate.latitude)
            maxLon = max(maxLon, location.coordinate.longitude)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLon + maxLon)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLon - minLon)*1.1))
    }
    
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        for location in currentExerciseLocations {
            coords.append(location.coordinate)
//            coords.append(CLLocationCoordinate2D(
//                latitude: location.coordinate.latitude,
//                longitude: location.coordinate.longitude))
        }
        
        return MKPolyline(coordinates: &coords, count: currentExerciseLocations.count)
    }

}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKPolyline) {
            // return nil
            print("Error: overlay is not kind of MKPolyline")
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blackColor()
        renderer.lineWidth = 3
        return renderer
    }

}

