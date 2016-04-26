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

var savedExercises = [Exercise]()
var currentExerciseLocations = [CLLocation]()

// I use mlab.com Data API for testing purposes
// see http://docs.mlab.com/data-api/
// Api Keys are stored in ApiKeys.plist (not in git repository)
let apiUrl = valueForAPIKey("API_BASE_URL")
let apiKey = "?apiKey=" + valueForAPIKey("API_KEY")

let ws = WS(apiUrl)

struct Exercise {
    
    var _id: String? // mongodb id
    
    var startingDate: NSDate = NSDate()
    var totalDistance: Double = 0
    var averageSpeed: Double = 0
    
    var description: String = ""
    
    var trace: [Location] = []
    
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

extension Exercise {
    static func list() -> Promise<[Exercise]> {
        return ws.get("/"+apiKey)
    }
    
    func save() -> Promise<Exercise> {
        return ws.post("/"+apiKey, params: params())
    }
    
    func update() -> Promise<Void> {
        return ws.put("/\(_id!)"+apiKey, params: params())
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

extension Location : ArrowParsable {
    mutating func deserialize(json: JSON) {
        latitude <-- json["latitude"]
        longitude <-- json["longitude"]
        timestamp <-- json["timestamp"]
    }
}
