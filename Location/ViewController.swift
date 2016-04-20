//
//  ViewController.swift
//  Location
//
//  Created by Samuli Tamminen on 19.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var horizontalAccuracyLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var verticalAccuracyLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var startStopButton: UIButton!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var locations = [CLLocation]()
    var distance: CLLocationDistance = 0
    
    var isTracking: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.activityType = .Fitness
        // locationManager.distanceFilter = 10.0 // Movement treshold for new events
        locationManager.requestAlwaysAuthorization()
        
    }
    
    @IBAction func startStopButtonPressed(sender: UIButton) {
        if !isTracking {
            isTracking = true
            startStopButton.setTitle("Stop Tracking", forState: .Normal)
            startStopButton.backgroundColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1)
        } else {
            isTracking = false
            startStopButton.setTitle("Start Tracking", forState: .Normal)
            startStopButton.backgroundColor = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1)
            
            printStats()
        }
    }
    
    func printStats() {
        if locations.isEmpty {
            print("No locations tracked.")
            return
        }
        
        var previousLocation: CLLocation = locations.first!
        
        
        func speed(loc1: CLLocation, loc2: CLLocation) -> Double {
            let distance = loc1.distanceFromLocation(loc2)
            let time = loc1.timestamp.timeIntervalSince1970 - loc2.timestamp.timeIntervalSince1970
            return abs(distance/time)
        }
        
        print("\n\n Statistics \n\n")
        
        for loc in locations {
            print("Lat: \(loc.coordinate.latitude)")
            print("Lon: \(loc.coordinate.longitude)")
            print("Speed: \(loc.speed)")
            print("Calculated speed: \(speed(previousLocation, loc2: loc))")
            
            
        }
        

    }
    

}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            // debugPrint(location)
            
            if location.horizontalAccuracy < 100 && isTracking {
                debugPrint(location)
                
                // Update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    distanceLabel.text = String(format: "%.2f", distance)
                }
                
                // Append location
                self.locations.append(location)
                
                // Show in labels
                latitudeLabel.text = String(format: "%.4f", location.coordinate.latitude)
                longitudeLabel.text = String(format: "%.4f", location.coordinate.longitude)
                horizontalAccuracyLabel.text = String(format: "%.4f", location.horizontalAccuracy)
                altitudeLabel.text = String(format: "%.4f", location.altitude)
                verticalAccuracyLabel.text = String(format: "%.4f", location.verticalAccuracy)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        debugPrint(error)
    }

}
