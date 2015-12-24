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
    var data: [CLLocation]
    {
        didSet
        {
            for component in data
            {
                print(component)
            }
        }
    }
    var limits: [Int]
    
    
    init(data: [CLLocation], limits: [Int])
    {
        self.data = data
        self.limits = limits
    }
    
    required init (coder decoder: NSCoder)
    {
        data = decoder.decodeObjectForKey("data") as! [CLLocation]
        limits = decoder.decodeObjectForKey("limits") as! [Int]
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(data, forKey: "data")
        coder.encodeObject(limits, forKey: "limits")
    }
    
    
    
    
    var timeLapsed: Double
        {
        get
        {
            guard (data.count > 0) else {return 0.0}
            return data.last!.timestamp.timeIntervalSinceDate(data.first!.timestamp)
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
    
}