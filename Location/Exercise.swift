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


struct Exercise {
    
    var startingDate: NSDate
    var totalDistance: Double
    var averageSpeed: Double
    
    var weather: Weather?
    
    var description: String
    
    var trace: [CLLocation]

}


struct Weather {
    var temperature: Double
    var description: String
}
