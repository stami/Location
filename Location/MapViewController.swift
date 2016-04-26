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
    
    var unwindDestination: String? // Where we came here
    @IBAction func prepareForUnwind(sender: UIBarButtonItem) {
        if unwindDestination == "LogDetailsViewController" {
            self.performSegueWithIdentifier("unwindToDetailsViewController", sender: self)
        } else if unwindDestination == "TrackerViewController" {
            self.performSegueWithIdentifier("unwindToTrackerViewController", sender: self)
        }
    }
    
    @IBOutlet weak var followMeButton: UIBarButtonItem!
    @IBAction func followMeButtonPressed(sender: UIBarButtonItem) {
        toggleFollowMe()
    }
    var followMe: Bool = true
    
    
    var timer = NSTimer()
    
    override func viewWillAppear(animated: Bool) {
        initMap()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateMap:", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    func initMap() {
        mapView.showsUserLocation = true
        
        if currentExercise.trace.count > 0 {
            mapView.setRegion(mapRegion(true), animated: false) // Set region only first time
            mapView.addOverlay(polyline())
        }
    }
    
    func updateMap(timer: NSTimer) {
        if currentExercise.trace.count > 0 {
            if followMe {
                mapView.setRegion(mapRegion(false), animated: true)
            }
            mapView.addOverlay(polyline())
        }
    }
    
    
    func mapRegion(showAll: Bool) -> MKCoordinateRegion {
        if showAll {
            let initialLoc: CLLocation = currentExercise.trace.first!.toCLLocation()
            
            var minLat = initialLoc.coordinate.latitude
            var minLon = initialLoc.coordinate.longitude
            var maxLat = minLat
            var maxLon = minLon
            
            // Get the min and max coordinates
            for location in currentExercise.trace {
                let cLLoc = location.toCLLocation()
                minLat = min(minLat, cLLoc.coordinate.latitude)
                minLon = min(minLon, cLLoc.coordinate.longitude)
                maxLat = max(maxLat, cLLoc.coordinate.latitude)
                maxLon = max(maxLon, cLLoc.coordinate.longitude)
            }
            
            debugPrint(MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1, longitudeDelta: (maxLon - minLon)*1.1))
            
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                    longitude: (minLon + maxLon)/2),
                span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                    longitudeDelta: (maxLon - minLon)*1.1))
        } else {
            return MKCoordinateRegion(
                center: currentExercise.trace.last!.toCLLocation().coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        }
    }
    
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        for location in currentExercise.trace {
            coords.append(location.toCLLocation().coordinate)
        }
        return MKPolyline(coordinates: &coords, count: currentExercise.trace.count)
    }
    
    
    func toggleFollowMe() {
        if followMe {
            followMeButton.title = "◎ Follow"
            followMe = false
        } else {
            followMeButton.title = "◉ Follow"
            followMe = true
        }
    }

}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blackColor()
        renderer.lineWidth = 3
        return renderer
    }

}

