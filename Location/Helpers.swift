//
//  Helpers.swift
//  Location
//
//  Created by Samuli Tamminen on 26.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import Foundation

// Format time ("00:00" or "00:00:00")
func stringFromTimeInterval(interval: NSTimeInterval) -> String {
    
    let seconds = Int(round(interval % 60))
    let minutes = Int((interval / 60) % 60)
    let hours = Int(interval / 3600)
    
    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    return String(format: "%02d:%02d", minutes, seconds)
}

// Format meters (146.66 => "147 m", 8329.33 => "8.329 km")
func stringFromDistance(distance: Double) -> String {
    if distance < 1000 {
        return String(format: "%.0f m", distance)
    }
    return String(format: "%0.2f km", distance/1000)
}

// Used to get API credentials from ApiKeys.plist
func valueForAPIKey(keyname: String) -> String {
    let filePath = NSBundle.mainBundle().pathForResource("ApiKeys", ofType: "plist")!
    let plist = NSDictionary(contentsOfFile:filePath)
    let value = plist?.valueForKey(keyname) as! String
    return value
}
