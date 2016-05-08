//
//  Helpers.swift
//  Location
//
//  Created by Samuli Tamminen on 26.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import Foundation

func stringFromTimeInterval(interval: NSTimeInterval) -> String {
    
    let seconds = Int(round(interval % 60))
    let minutes = Int((interval / 60) % 60)
    let hours = Int(interval / 3600)
    
    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    return String(format: "%02d:%02d", minutes, seconds)
}

func stringFromDistance(distance: Double) -> String {
    if distance < 1000 {
        return String(format: "%.0f m", distance)
    }
    return String(format: "%0.2f km", distance/1000)
}