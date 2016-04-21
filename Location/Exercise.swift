//
//  Exercise.swift
//  Location
//
//  Created by Samuli Tamminen on 20.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import Foundation
import CoreLocation


var exercises = [Exercise]()
var currentExerciseLocations = [CLLocation]()


struct Exercise {
    
    var startingDate: NSDate
    var totalDistance: Double
    var averageSpeed: Double
    
    var weather: Weather?
    
    var description: String
    
    var trace: [Location]

}


struct Weather {
    var temperature: Double
    var description: String
}

struct Location {
    var latitude: Double
    var longitude: Double
    var timestamp: NSDate
}