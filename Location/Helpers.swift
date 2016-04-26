//
//  Helpers.swift
//  Location
//
//  Created by Samuli Tamminen on 26.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import Foundation

func stringFromTimeInterval(interval: NSTimeInterval) -> String {
    
    let seconds = Int(interval % 60)
    let minutes = Int((interval / 60) % 60)
    let hours = Int(interval / 3600)
    
    if hours > 0 {
        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }
    return String(format: "%0.2d:%0.2d", minutes, seconds)
}