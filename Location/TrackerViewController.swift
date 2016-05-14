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
    @IBOutlet weak var logsBarButtonItem: UIBarButtonItem!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    let stopwatch = Stopwatch()
    var currentSpeed: Double = 0
    
    var isTracking: Bool = false {
        didSet {
            if isTracking {
                logsBarButtonItem.enabled = false
            } else {
                logsBarButtonItem.enabled = true
            }
        }
    }
    
    // Used to inform user if GPS signal accuracy is too bad
    @IBOutlet weak var badSignalLabel: UILabel!
    var badSignalCounter: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup rest api parsing
        // ws.logLevels = .CallsAndResponses
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
    
    
    
    // MARK: - Start and Stop tracking
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
    
    func resetExercise() {
        currentExercise = Exercise()
        currentSpeed = 0
        currentSpeedLabel.text = "0.0"
        distanceLabel.text = "0.0"
        averageSpeedLabel.text = "0.0"
        timerLabel.text = "00:00"
    }
    
    // Update timerLabel
    func eachSecond(timer: NSTimer) {
        if stopwatch.isRunning {
            timerLabel.text = stopwatch.elapsedAsString
        } else {
            timer.invalidate()
        }
    }
    
    
    func saveExercise() {
        if currentExercise.trace.isEmpty {
            print("Nothing tracked.")
            return
        }
        
        // Get Exercise description from user
        let alertController = UIAlertController(title: "Description", message: "Enter exercise description", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler({ (textField: UITextField!) in
                textField.placeholder = "Good cycling!"
        })
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
            (UIAlertAction) in
            if let description = alertController.textFields!.first!.text {
                currentExercise.description = description
                print(currentExercise)
                
                // Save new exercise with provided description
                currentExercise.save().then() { createdExercise in
                    savedExercises.append(createdExercise)
                }
            }
        })
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
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
    
    
    
    // MARK: - CLLocationManagerDelegate Helpers
    func incrementBadSignalCounter() {
        badSignalCounter += 1
        if badSignalCounter > 5 {
            badSignalLabel.hidden = false // 5 bad locations in row needed to show the warning
        }
    }
    
    func clearBadSignalWarning() {
        badSignalCounter = 0
        badSignalLabel.hidden = true
    }
    
    func speed(previous: CLLocation, current: CLLocation) -> Double {
        let distance = previous.distanceFromLocation(current)
        let time = previous.timestamp.timeIntervalSince1970 - current.timestamp.timeIntervalSince1970
        if time != 0 {
            return abs(distance/time)
        } else {
            return 0
        }
    }
    
    func updateExerciseStats(location: CLLocation) {
        if !currentExercise.trace.isEmpty {
            currentExercise.totalDistance += location.distanceFromLocation(currentExercise.trace.last!.toCLLocation())
            distanceLabel.text = String(format: "%.2f", currentExercise.totalDistance/1000) // m to km
        
            currentExercise.averageSpeed = currentExercise.totalDistance / -currentExercise.trace.first!.timestamp.timeIntervalSinceNow
            averageSpeedLabel.text = String(format: "%.1f", currentExercise.averageSpeed*3.6) // m/s to km/h
        
            currentSpeed = speed(currentExercise.trace.last!.toCLLocation(), current: location)
            currentSpeedLabel.text = String(format: "%.1f", currentSpeed*3.6) // m/s to km/h
        }
    }
    
    func appendNewLocation(location: CLLocation) {
        currentExercise.trace.append(Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: location.timestamp))
    }

}

// MARK: - CLLocationManagerDelegate
extension TrackerViewController: CLLocationManagerDelegate {
    
    // Wait for user to authorize location services
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    // Called when new location is received
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latestLocation = locations.last {
            if latestLocation.horizontalAccuracy < 20 {
                if isTracking {
                    updateExerciseStats(latestLocation)
                    appendNewLocation(latestLocation)
                }
                clearBadSignalWarning()
            } else {
                incrementBadSignalCounter()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        debugPrint(error)
    }

}
