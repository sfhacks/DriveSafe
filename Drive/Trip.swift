//
//  Trip.swift
//  Drive
//
//  Created by Andrew Ke on 12/24/15.
//  Copyright © 2015 Andrew. All rights reserved.
//

import Foundation
import CoreLocation

class Trip: NSObject, NSCoding
{
    // MARK: - Properties
    var startDate: NSDate!
    var stopDate: NSDate!
    
    var data: [CLLocation] // Array of locations
    {
        didSet
        {
            for component in data
            {
                print(component)
            }
        }
    }
    var limits: [Int] // Array of speed limits
    
    var timeLapsed: Double
        {
        get
        {
            guard (data.count > 0) else {return 0.0}
            print(startDate)
            return stopDate.timeIntervalSinceDate(startDate)
        }
    }
    
    var averageSpeed: Double
        {
        get
        {
            guard (data.count > 0) else {return 0.0}
            var total: CLLocationSpeed = 0
            for location in data
            {
                total += abs(location.speed)
            }
            return total/Double(data.count)
        }
    }
    
    var numberOfOffenses:Int
    {
        get {
            var count = 0
            for (var i = 0; i < min(data.count, limits.count); i++)
            {
                if (data[i].speed > Double(limits[i]))
                {
                    count++;
                }
            }
            
            return count
        }
    }
    
    var driverRating: Double
        {
        get
        {
            guard (data.count > 0) else {return 0.0}
            return 10-Double(Double(numberOfOffenses)/Double(data.count))*10
        }
    }
    
    // MARK: - Constructors
    
    init(data: [CLLocation], limits: [Int])
    {
        self.data = data
        self.limits = limits
    }
    
    // MARK: - NSUserDefaults configuration
    
    // These two methods are required in order to store Trip objects in NSUserDefaults
    required init (coder decoder: NSCoder)
    {
        data = decoder.decodeObjectForKey("data") as! [CLLocation]
        limits = decoder.decodeObjectForKey("limits") as! [Int]
        startDate = decoder.decodeObjectForKey("startDate") as! NSDate
        stopDate = decoder.decodeObjectForKey("stopDate") as! NSDate
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(data, forKey: "data")
        coder.encodeObject(limits, forKey: "limits")
        coder.encodeObject(startDate, forKey: "startDate")
        coder.encodeObject(stopDate, forKey: "stopDate")
    }
    
}