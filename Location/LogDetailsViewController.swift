//
//  LogDetailsViewController.swift
//  Location
//
//  Created by Samuli Tamminen on 20.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import UIKit
import Charts
import CoreLocation

class LogDetailsViewController: UIViewController {
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    
    // Filtered data
    var fTrace = [Location]()
    var fDistance = [Double]()
    var fTime = [NSDate]()
    var fChartLabels = [String]()
    var fSpeed = [Double]()
    
    var speedDataEntries: [ChartDataEntry] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        navigationItem.title = dateFormatter.stringFromDate(currentExercise.startingDate)
        
        totalDistanceLabel.text = stringFromDistance(currentExercise.totalDistance)
        averageSpeedLabel.text = String(format: "%.2f", currentExercise.averageSpeed * 3.6) + " km/h"
        durationLabel.text = stringFromTimeInterval(currentExercise.trace.last!.timestamp.timeIntervalSinceDate(currentExercise.startingDate))
        commentTextField.text = currentExercise.description
        
        filterData()
        setupChart()
    }

    @IBAction func saveComment(sender: UITextField) {
        if let comment = commentTextField.text {
            currentExercise.description = comment
        } else {
            currentExercise.description = ""
        }
        currentExercise.update().then {
            print(currentExercise)
        }
    }


    func setupChart() {

        lineChartView.descriptionText = ""
        lineChartView.xAxis.drawLabelsEnabled = true
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.drawBordersEnabled = true
        lineChartView.legend.enabled = false
        
        let chartDataSet = LineChartDataSet(yVals: speedDataEntries, label: "Speed")
        chartDataSet.axisDependency = .Left
        chartDataSet.colors = [UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)]
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.lineWidth = 2.0
        chartDataSet.drawValuesEnabled = false
        chartDataSet.highlightEnabled = false
        
        
        let chartData = LineChartData(xVals: fChartLabels, dataSet: chartDataSet)
        lineChartView.data = chartData
        
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        
    }
    
    func filterData() {
        
        let treshold = 0.0
        var avgSpeed: Double = 0
        let alpha: Double = 0.4
        
        let firstTimestamp: NSDate = currentExercise.trace.first!.timestamp
        
        fDistance.append(0)
        fSpeed.append(0)
        fTime.append(firstTimestamp)
        fChartLabels.append("0")
        
        fTrace.append(currentExercise.trace.first!)
        
        let traceCount = currentExercise.trace.count
        
        for i in 1..<traceCount {
            let loc = currentExercise.trace[i]
            
            let distanceFromLast = loc.toCLLocation().distanceFromLocation(fTrace.last!.toCLLocation())

            // Skip location if distance is too low
            // TODO: improve filtering...
            if distanceFromLast < treshold {
                print("Too short distance, skipping...")
                continue
            }
            
            // Skip location if timestamp is same
            if loc.timestamp == fTrace.last!.timestamp {
                print("Same timestamp, skipping...")
                continue
            }
            
            // raw speed between two last locations
            let speed: Double = distanceFromLast / loc.timestamp.timeIntervalSinceDate(fTrace.last!.timestamp) * 3.6
            fSpeed.append(speed)
            
            // Calculate exponential moving average of speed
            avgSpeed = (alpha * speed) + (1.0 - alpha) * avgSpeed
            let dataEntry = ChartDataEntry(value: avgSpeed, xIndex: i)
            speedDataEntries.append(dataEntry)
            
            // Timestamp there must be
            fTime.append(loc.timestamp)
            let time = stringFromTimeInterval(loc.timestamp.timeIntervalSinceDate(fTrace.first!.timestamp))
            fChartLabels.append(time)
            
            // Calculate total distance
            let cumulativeDistance: Double = fDistance.last! + distanceFromLast
            fDistance.append(cumulativeDistance)
            // fChartLabels.append(stringFromDistance(cumulativeDistance))
            
            // Trace for MapView
            fTrace.append(loc)
            
            // Do some tuning for the threshold
            // treshold = 0.5*avgSpeed
        }
        
        // For MapView
        currentExercise.trace = fTrace
    }
    

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromDetailsToMapSegue" {
            if let navigationVC = segue.destinationViewController as? UINavigationController,
               let destination = navigationVC.topViewController as? MapViewController {
                    destination.unwindDestination = "LogDetailsViewController"
                    destination.followMe = false
            }
        }
    }
    
    @IBAction func unwindToDetailsViewController(segue:UIStoryboardSegue) {
        //print("unwindToDetailsViewController")
    }

}
