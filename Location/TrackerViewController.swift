//
//  ViewController.swift
//  Location
//
//  Created by Samuli Tamminen on 19.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import UIKit
import CoreLocation
import Arrow

class TrackerViewController: UIViewController {
    
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    @IBOutlet weak var startStopButton: UIButton!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    let stopwatch = Stopwatch()
    var isTracking: Bool = false
    var currentSpeed: Double = 0
    
    @IBOutlet weak var badSignalLabel: UILabel!
    var badSignalCounter: Int = 0 // Used to inform user if GPS signal accuracy is too bad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup rest api parsing
        //ws.logLevels = .CallsAndResponses
        ws.postParameterEncoding = .JSON
        Arrow.setDateFormat("yyyy-MM-dd'T'HH:mm:ssZ")
        Arrow.setUseTimeIntervalSinceReferenceDate(true)
        
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
        currentExercise = Exercise()
        currentSpeed = 0
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
        if currentExercise.trace.isEmpty {
            print("Nothing tracked.")
            return
        }
        
        // TODO: get description from user
        
        currentExercise.save().then() { createdExercise in
            savedExercises.append(createdExercise)
        }
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromTrackerToMapSegue" {
            if let navigationVC = segue.destinationViewController as? UINavigationController,
                let destination = navigationVC.topViewController as? MapViewController {
                destination.unwindDestination = "TrackerViewController"
            }
        }
    }

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
            if location.horizontalAccuracy < 20 {
                if isTracking {
                    var locationIsChanged: Bool = true
                    if let lastLocation = currentExercise.trace.last {
                        let lastCoordinate = lastLocation.toCLLocation().coordinate
                        if lastCoordinate.latitude != location.coordinate.latitude || lastCoordinate.longitude != location.coordinate.longitude {
                            // Location is different from the previous saved one
                            locationIsChanged = true
                        }
                    }
                    
                    // Update current values
                    if currentExercise.trace.count > 0 && locationIsChanged {
                        currentExercise.totalDistance += location.distanceFromLocation(currentExercise.trace.last!.toCLLocation())
                        distanceLabel.text = String(format: "%.2f", currentExercise.totalDistance/1000) // meters to kilometers
                        
                        currentExercise.averageSpeed = currentExercise.totalDistance / -currentExercise.trace.first!.timestamp.timeIntervalSinceNow
                        averageSpeedLabel.text = String(format: "%.1f", currentExercise.averageSpeed*3.6) // m/s to km/h
                        
                        currentSpeed = speed(currentExercise.trace.last!.toCLLocation(), current: location)
                        currentSpeedLabel.text = String(format: "%.1f", currentSpeed*3.6) // m/s to km/h
                    }
                    
                    // Append location
                    currentExercise.trace.append(Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: location.timestamp))
                    locationIsChanged = false
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
