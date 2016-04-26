//
//  LogsTableViewController.swift
//  Location
//
//  Created by Samuli Tamminen on 20.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import UIKit

class LogsTableViewController: UITableViewController {
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedExercises.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseLogCell", forIndexPath: indexPath) as! ExerciseLogTableViewCell
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE dd.MM.yyyy"
        
        let dateString = dateFormatter.stringFromDate(savedExercises[indexPath.row].startingDate)
        
        cell.dateLabel.text = dateString
        cell.distanceLabel.text = String(format: "%.2f", savedExercises[indexPath.row].totalDistance / 1000) + " km"

        return cell
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            savedExercises[indexPath.row].delete().then() {
                savedExercises.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
        }
    }
    

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showExerciseDetailsSegue" {
            let detailViewController = segue.destinationViewController as! LogDetailsViewController
            
            if let selectedCell = sender as? ExerciseLogTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCell)!
                currentExercise = savedExercises[indexPath.row]
            }
        }
        
    }

}
