//
//  Stopwatch.swift
//  Location
//
//  Created by Samuli Tamminen on 20.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import Foundation

class Stopwatch {
    
    private var startTime: NSDate?
    
    // Initialize timer. Set startTime to current time.
    func start() {
        startTime = NSDate()
    }
    
    func stop() {
        startTime = nil
    }
    
    var isRunning: Bool {
        return startTime != nil
    }
    
    var elapsed: NSTimeInterval {
        if isRunning {
            return -startTime!.timeIntervalSinceNow
        } else {
            return 0
        }
    }
    
    // Return "(00:)00:00" formatted string (see Helpers.swift)
    var elapsedAsString: String {
        return stringFromTimeInterval(elapsed)
    }
    
}
