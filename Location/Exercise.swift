//
//  Exercise.swift
//  Location
//
//  Created by Samuli Tamminen on 20.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import Foundation
import CoreLocation

import ws
import Alamofire
import Arrow
import then

var savedExercises = [Exercise]() // Will be populated from API
var currentExercise = Exercise()  // Will hold the current exercise (during tracking or previously saved one)

// I use mlab.com Data API for testing purposes
// see http://docs.mlab.com/data-api/
// Api Keys are stored in ApiKeys.plist (not in git repository)
let apiUrl = valueForAPIKey("API_BASE_URL")
let apiKey = "?apiKey=" + valueForAPIKey("API_KEY")

// Use ws (https://github.com/s4cha/ws) for easy API usage
let ws = WS(apiUrl)


struct Exercise {
    
    var _id: String? // mongodb id
    
    var startingDate: NSDate = NSDate()
    var totalDistance: Double = 0
    var averageSpeed: Double = 0
    
    var description: String = ""
    
    var trace: [Location] = []
    
    // Return key-value array for API POST parameter
    func params() -> [String:AnyObject] {
        
        // Dates to JSON
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        var paramTrace: [[String:AnyObject]] = []
        for location in trace {
            paramTrace.append(["latitude": location.latitude, "longitude": location.longitude, "timestamp": dateFormatter.stringFromDate(location.timestamp)])
        }
        
        return [
            "startingDate": dateFormatter.stringFromDate(startingDate),
            "totalDistance": totalDistance,
            "averageSpeed": averageSpeed,
            "description": description,
            "trace": paramTrace
        ]
    }
    
}

// Defines how to map JSON to Swift object (required by ws)
extension Exercise : ArrowParsable {
    mutating func deserialize(json: JSON) {
        _id <-- json["_id.$oid"]
        startingDate <-- json["startingDate"]
        totalDistance <-- json["totalDistance"]
        averageSpeed <-- json["averageSpeed"]
        description <-- json["description"]
        trace <-- json["trace"]
    }
}

// API methods
extension Exercise {
    static func list() -> Promise<[Exercise]> {
        return ws.get("/"+apiKey)
    }
    
    func save() -> Promise<Exercise> {
        return ws.post("/"+apiKey, params: params())
    }
    
    func update() -> Promise<Void> {
        // Only description should be updated
        return ws.put("/\(_id!)"+apiKey, params: ["_id": _id!, "description": description])
    }
    
    func delete() -> Promise<Void> {
        return ws.delete("/\(_id!)"+apiKey)
    }
}


struct Location {
    var latitude: Double = 0
    var longitude: Double = 0
    var timestamp: NSDate = NSDate()
}

extension Location {
    func toCLLocation() -> CLLocation {
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: 1, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: timestamp)
    }
}

extension Location : ArrowParsable {
    mutating func deserialize(json: JSON) {
        latitude <-- json["latitude"]
        longitude <-- json["longitude"]
        timestamp <-- json["timestamp"]
    }
}
