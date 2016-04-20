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
    
    var elapsedAsString: String {
        return String(format: "%02d:%02d:%02d", Int(elapsed / 3600), Int(elapsed / 60), Int(elapsed))
    }
    
    
}