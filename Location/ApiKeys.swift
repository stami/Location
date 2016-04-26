//
//  ApiKeys.swift
//  Location
//
//  Created by Samuli Tamminen on 26.4.2016.
//  Copyright © 2016 Samuli Tamminen. All rights reserved.
//

import Foundation

func valueForAPIKey(keyname: String) -> String {
    let filePath = NSBundle.mainBundle().pathForResource("ApiKeys", ofType: "plist")!
    let plist = NSDictionary(contentsOfFile:filePath)
    let value = plist?.valueForKey(keyname) as! String
    return value
}
