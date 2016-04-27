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
    
    // Chart Data
    var distanceData = [Double]()
    var timeData = [String]()
    var speedData = [Double]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        navigationItem.title = dateFormatter.stringFromDate(currentExercise.startingDate)
        
        totalDistanceLabel.text = stringFromDistance(currentExercise.totalDistance)
        averageSpeedLabel.text = String(format: "%.2f", currentExercise.averageSpeed * 3.6) + " km/h"
        durationLabel.text = stringFromTimeInterval(currentExercise.trace.last!.timestamp.timeIntervalSinceDate(currentExercise.startingDate))
        commentTextField.text = currentExercise.description
        
        getDataForChart()
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
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<distanceData.count {
            let dataEntry = ChartDataEntry(value: speedData[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "Distance")
        chartDataSet.axisDependency = .Left
        chartDataSet.colors = [UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)]
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.lineWidth = 2.0
        chartDataSet.drawValuesEnabled = false
        chartDataSet.highlightEnabled = false
        
        
        let chartData = LineChartData(xVals: timeData, dataSet: chartDataSet)
        lineChartView.data = chartData
        
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        

    }
    
    func getDataForChart() {
        
        distanceData.append(0)
        timeData.append("0")
        speedData.append(0)
        
        let firstTimestamp: NSDate = currentExercise.trace.first!.timestamp
        
        for i in 1..<currentExercise.trace.count {
            
            let older: CLLocation = currentExercise.trace[i-1].toCLLocation()
            let latest: CLLocation = currentExercise.trace[i].toCLLocation()
            
            let distanceToOlder = latest.distanceFromLocation(older)
            distanceData.append(distanceData[i-1] + distanceToOlder)
            
            timeData.append(stringFromTimeInterval(latest.timestamp.timeIntervalSinceDate(firstTimestamp)))
            
            // TODO: fix issue when timeInterval is 0
            // calculate some running average...
            let speed: Double = distanceToOlder / latest.timestamp.timeIntervalSinceDate(older.timestamp) * 3.6
            speedData.append(speed)
        }
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
