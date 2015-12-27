//
//  SpeedLimitFinder.swift
//  Given a coordinate, this class finds the speed limit
//
//  Created by Andrew Ke on 12/26/15.
//
//

/*
Example nominatim xml:

<reversegeocode timestamp="Sun, 27 Dec 15 18:28:29 +0000" attribution="Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright" querystring="format=xml&lat=37.391280&lon=-122.085907&zoom=15&addressdetails=0">
<result place_id="48979245" osm_type="way" osm_id="8379917" ref="South Shoreline Boulevard" lat="37.391715" lon="-122.0855545">
South Shoreline Boulevard, Mountain View, Santa Clara County, California, 94041, United States of America
</result>
</reversegeocode>

*/
import Foundation
import CoreLocation
import AEXML

class SpeedLimitFinder
{
    static func getSpeedLimit(location: CLLocationCoordinate2D, completion: (limit: Int?) -> Void)
    {
        let nominatimURL = NSURL(string: "https://nominatim.openstreetmap.org/reverse?format=xml&lat=\(location.latitude)&lon=\(location.longitude)&zoom=17&addressdetails=0") // This url contains the id of the closest road
        
        SpeedLimitFinder.performGetRequest(nominatimURL) { (data, HTTPStatusCode, error) -> Void in
            guard let data = data else {completion(limit: nil); return;}
            do // Catching risky AEXMLDocument constructor
            {
                let xmlDoc = try AEXMLDocument(xmlData: data)
                if let wayID = xmlDoc.root["result"].attributes["osm_id"] // Get the id of the road
                {
                    getSpeedLimit(wayID,completion: completion)
                }else
                {
                    completion(limit: nil)
                }
            }catch
            {
                completion(limit: nil)
            }
        }
    }
    
    static func getSpeedLimit(id: String, completion: (limit: Int?) -> Void)
    {
        let osmURL = NSURL(string: "https://www.openstreetmap.org/api/0.6/way/\(id)") // Returns info about the road
        SpeedLimitFinder.performGetRequest(osmURL) { (data, HTTPStatusCode, error) -> Void in
            guard let data = data else {completion(limit: nil); return;}
            do
            {
                let xmlDoc = try AEXMLDocument(xmlData: data)
                if let speedTags = xmlDoc.root["way"]["tag"].allWithAttributes(["k": "maxspeed"]) // Look for explicit speed tag
                {
                    print("Explicit speed limit found")
                    if let value = speedTags[0].attributes["v"] // value = "25 mph"
                    {
                        if let speed = Int(value.characters.split{$0 == " "}.map(String.init)[0])
                        {
                            completion(limit: speed)
                            return
                        }
                    }
                }else if let roadTag = xmlDoc.root["way"]["tag"].allWithAttributes(["k": "highway"]) // Look for road type
                {
                    print("Inferring speed limit from road type")
                    if let roadType = roadTag[0].attributes["v"]
                    {
                        completion(limit: speedLimitForRoadType(roadType))
                        return
                    }
                }
            }catch
            {
                completion(limit: nil)
            }
            completion(limit: nil)
        }
    }
    
    static private func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        })
        
        task.resume()
    }
    
    // Values sourced from http://wiki.openstreetmap.org/wiki/California#Highway_types
    static private func speedLimitForRoadType(roadType: String) -> Int
    {
        var limit = 40
        switch(roadType)
        {
        case "motorway":
            limit = 60
        case "trunk":
            limit = 50
        case "primary":
            limit = 40
        case "secondary":
            limit = 35
        case "tertiary":
            limit = 30
        case "residential":
            limit = 25
        default:
            limit = 30
        }
        return limit
    }
}