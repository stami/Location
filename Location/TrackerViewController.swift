//
//  ViewController.swift
//  Location
//
//  Created by Samuli Tamminen on 19.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import UIKit
import CoreLocation

class TrackerViewController: UIViewController {
    
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
            
            saveExercise()
            locations.removeAll()
            distance = 0
        }
    }
    
    func saveExercise() {
        
        if locations.isEmpty {
            print("No locations tracked.")
            return
        }
        
        
        var previousLocation: CLLocation = locations.first!
        var averageSpeed: Double = 0
        var totalDistance: Double = 0
        
        
        func speed(previous: CLLocation, current: CLLocation) -> Double {
            let distance = previous.distanceFromLocation(current)
            let time = previous.timestamp.timeIntervalSince1970 - current.timestamp.timeIntervalSince1970
            if time != 0 {
                return abs(distance/time)
            } else {
                return 0
            }
        }
        
        
        print("\n\n Statistics \n\n")
        
        for loc in locations {
            print("Lat: \(loc.coordinate.latitude)")
            print("Lon: \(loc.coordinate.longitude)")
            print("Speed: \(loc.speed)")
            print("Calculated speed: \(speed(previousLocation, current: loc))")
           
            averageSpeed += speed(previousLocation, current: loc)

            print("cumulative avg speed: \(averageSpeed)")
            
            totalDistance += previousLocation.distanceFromLocation(loc)
            
            previousLocation = loc
            
        }
        
        averageSpeed /= Double(locations.count - 1)
        
        exercises.append(Exercise(startingDate: locations.first!.timestamp, totalDistance: totalDistance, averageSpeed: averageSpeed, weather: nil, description: "Kivaa juoksua", trace: locations))
        
    }
    

}

// MARK: - CLLocationManagerDelegate
extension TrackerViewController: CLLocationManagerDelegate {
    
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
                
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        debugPrint(error)
    }

}
