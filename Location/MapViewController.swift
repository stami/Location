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
        
        if currentExerciseLocations.count > 0 {
            mapView.setRegion(mapRegion(true), animated: false) // Set region only first time
            mapView.addOverlay(polyline())
        }
    }
    
    func updateMap(timer: NSTimer) {
        if currentExerciseLocations.count > 0 {
            if followMe {
                mapView.setRegion(mapRegion(false), animated: true)
            }
            mapView.addOverlay(polyline())
        }
    }
    
    
    func mapRegion(showAll: Bool) -> MKCoordinateRegion {
        if showAll {
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
            
            debugPrint(MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1, longitudeDelta: (maxLon - minLon)*1.1))
            
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                    longitude: (minLon + maxLon)/2),
                span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                    longitudeDelta: (maxLon - minLon)*1.1))
        } else {
            return MKCoordinateRegion(
                center: currentExerciseLocations.last!.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        }
    }
    
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        for location in currentExerciseLocations {
            coords.append(location.coordinate)
        }
        return MKPolyline(coordinates: &coords, count: currentExerciseLocations.count)
    }
    
    
    func toggleFollowMe() {
        "◉◎ Follow"
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

