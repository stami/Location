//
//  Exercise.swift
//  Location
//
//  Created by Samuli Tamminen on 20.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import Foundation
import CoreLocation
// ws
import Alamofire
import Arrow
import then

var savedExercises = [Exercise]()
var currentExerciseLocations = [CLLocation]()

// let apiUrl = "" // not in git repository
// let apiKey = "&apiKey" + "" // not in git repository
// I use mlab.com Data API for testing purposes
// see http://docs.mlab.com/data-api/


let ws = WS(apiUrl)

struct Exercise {
    
    var startingDate: NSDate = NSDate()
    var totalDistance: Double = 0
    var averageSpeed: Double = 0
    
    var description: String = ""
    
    var trace: [Location] = []
    
    func params() -> [String:AnyObject] {
        
        var paramTrace: [[String:AnyObject]] = []
        
        for location in trace {
            paramTrace.append(["latitude": location.latitude, "longitude": location.longitude, "timestamp": location.timestamp])
        }
        
        return [
            "startingDate": startingDate,
            "totalDistance": totalDistance,
            "averageSpeed": averageSpeed,
            "description": description,
            "trace": paramTrace
        ]
    }
    
}

extension Exercise : ArrowParsable {
    
    init(json: JSON) {
        startingDate <-- json["startingDate"]
        totalDistance <-- json["totalDistance"]
        averageSpeed <-- json["averageSpeed"]
        description <-- json["description"]
        trace <-- json["trace"]
    }

}

extension Exercise {
    static func list() -> Promise<[Exercise]> {
        return ws.get("/exercises")
    }
    
    func save() -> Promise<Exercise> {
        return ws.post("/exercises"+apiKey, params: ["data": ["date": startingDate, "number": 123]])
    }
    
    func update() -> Promise<Void> {
        return ws.put("/exercises/\(startingDate.timeIntervalSince1970)", params: ["data": params()])
    }
    
    func delete() -> Promise<Void> {
        return ws.delete("/exercises/\(startingDate.timeIntervalSince1970)")
    }
}


struct Location {
    var latitude: Double
    var longitude: Double
    var timestamp: NSDate
}