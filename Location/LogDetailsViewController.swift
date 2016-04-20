//
//  LogDetailsViewController.swift
//  Location
//
//  Created by Samuli Tamminen on 20.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import UIKit

class LogDetailsViewController: UIViewController {
    
    var exercise: Exercise?

    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let exercise = exercise {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            navigationItem.title = dateFormatter.stringFromDate(exercise.startingDate)
            
            totalDistanceLabel.text = String(format: "%.2f", exercise.totalDistance) + " m"
            averageSpeedLabel.text = String(format: "%.2f", exercise.averageSpeed) + " m/s"
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
