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
    
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    @IBOutlet weak var startStopButton: UIButton!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    let stopwatch = Stopwatch()
    var isTracking: Bool = false

    var distance: CLLocationDistance = 0
    var averageSpeed: Double = 0
    var currentSpeed: Double = 0
    
    @IBOutlet weak var badSignalLabel: UILabel!
    var badSignalCounter: Int = 0 // Used to inform user if GPS signal accuracy is too bad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ws.logLevels = .CallsAndResponses
        ws.postParameterEncoding = .JSON
        
        // Load saved exercises from API
        Exercise.list().then { loadedExercises in
            savedExercises = loadedExercises
        }

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.activityType = .Fitness
        // locationManager.distanceFilter = 1.0 // Movement treshold for new events
        locationManager.requestAlwaysAuthorization()
    }
    
    @IBAction func startStopButtonPressed(sender: UIButton) {
        if !isTracking {
            resetExercise()
            startTracking()
        } else {
            stopTracking()
            saveExercise()
        }
    }
    
    func startTracking() {
        isTracking = true
        startStopButton.setTitle("Stop Tracking", forState: .Normal)
        startStopButton.backgroundColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1)
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "eachSecond:", userInfo: nil, repeats: true)
        stopwatch.start()
    }
    
    func stopTracking() {
        isTracking = false
        startStopButton.setTitle("Start Tracking", forState: .Normal)
        startStopButton.backgroundColor = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1)
        stopwatch.stop()
    }
    
    // Called each and every second to update timerLabel
    func eachSecond(timer: NSTimer) {
        if stopwatch.isRunning {
            timerLabel.text = stopwatch.elapsedAsString
        } else {
            timer.invalidate()
        }
    }
    
    func resetExercise() {
        currentExerciseLocations.removeAll()
        currentSpeed = 0
        distance = 0
        averageSpeed = 0
        currentSpeedLabel.text = "0.0"
        distanceLabel.text = "0.0"
        averageSpeedLabel.text = "0.0"
    }
    
    // Get speed between two locations
    func speed(previous: CLLocation, current: CLLocation) -> Double {
        let distance = previous.distanceFromLocation(current)
        let time = previous.timestamp.timeIntervalSince1970 - current.timestamp.timeIntervalSince1970
        if time != 0 {
            return abs(distance/time)
        } else {
            return 0
        }
    }
    
    func saveExercise() {
        if currentExerciseLocations.isEmpty {
            print("No locations tracked.")
            return
        }
        
        // Create simplified locations
        var locations = [Location]()
        for loc in currentExerciseLocations {
            locations.append(Location(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, timestamp: loc.timestamp))
        }
        
        let newExercise = Exercise(_id: "", startingDate: locations.first!.timestamp, totalDistance: distance, averageSpeed: averageSpeed, description: "Kivaa juoksua", trace: locations)
        
        newExercise.save().then() { createdExercise in
            savedExercises.append(createdExercise)
        }
    }
    
    
    // MARK: - Navigation
    @IBAction func unwindToTrackerViewController(segue:UIStoryboardSegue) {
        //print("unwindToTrackerViewController")
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
            
            if location.horizontalAccuracy < 20 {
                //debugPrint(location)
                
                if isTracking {
                    // Update current values
                    if currentExerciseLocations.count > 0 {
                        distance += location.distanceFromLocation(currentExerciseLocations.last!)
                        distanceLabel.text = String(format: "%.2f", distance/1000) // meters to kilometers
                        
                        averageSpeed = distance / (location.timestamp.timeIntervalSince1970 - currentExerciseLocations.first!.timestamp.timeIntervalSince1970)
                        averageSpeedLabel.text = String(format: "%.1f", averageSpeed*3.6) // m/s to km/h
                        
                        currentSpeed = speed(currentExerciseLocations.last!, current: location)
                        currentSpeedLabel.text = String(format: "%.1f", currentSpeed*3.6) // m/s to km/h
                    }
                    
                    // Append location
                    currentExerciseLocations.append(location)
                }
                
                // We have good accuracy, let's clear the warning
                badSignalCounter = 0
                badSignalLabel.hidden = true
            } else {
                badSignalCounter += 1
                if badSignalCounter > 5 {
                    // 5 bad locations in row needed to show the warning
                    badSignalLabel.hidden = false
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        debugPrint(error)
    }

}
