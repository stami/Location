//
//  LogDetailsViewController.swift
//  Location
//
//  Created by Samuli Tamminen on 20.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import UIKit

class LogDetailsViewController: UIViewController {
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        navigationItem.title = dateFormatter.stringFromDate(currentExercise.startingDate)
        
        totalDistanceLabel.text = String(format: "%.2f", currentExercise.totalDistance) + " m"
        averageSpeedLabel.text = String(format: "%.2f", currentExercise.averageSpeed) + " m/s"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromDetailsToMapSegue" {
            if let navigationVC = segue.destinationViewController as? UINavigationController,
               let destination = navigationVC.topViewController as? MapViewController {
                    destination.unwindDestination = "LogDetailsViewController"
            }
        }
    }
    
    @IBAction func unwindToDetailsViewController(segue:UIStoryboardSegue) {
        //print("unwindToDetailsViewController")
    }

}
