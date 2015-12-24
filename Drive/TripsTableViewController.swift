//
//  TripsTableViewController.swift
//  Drive
//
//  Created by Andrew Ke on 12/24/15.
//  Copyright © 2015 Andrew. All rights reserved.
//

import UIKit

class TripsTableViewController: UITableViewController {
    
    var trips: [Trip]!
    override func viewDidLoad() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let tripsData = defaults.objectForKey("trips") as? NSData
        {
            trips = NSKeyedUnarchiver.unarchiveObjectWithData(tripsData) as! [Trip]
            trips = trips.reverse()
        }else
        {
            trips = []
        }
        
        super.viewDidLoad()
        navigationController?.navigationBar.hideBottomHairline()
        (presentingViewController as! UINavigationController).navigationBarHidden = true
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blur.frame = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y-64, width: view.bounds.width, height: view.bounds.height+64)
        blur.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        view.insertSubview(blur, atIndex: 0)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        (presentingViewController as! UINavigationController).navigationBarHidden = false
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = "\(indexPath.row)"
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)

        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .ShortStyle
        
        let trip = trips[indexPath.row]
        if let timeStamp = trip.data.first?.timestamp
        {
            cell.textLabel?.text = formatter.stringFromDate(timeStamp)
        }else
        {
            cell.textLabel?.text = "NA"
        }
        cell.detailTextLabel?.text = String(format: "%.1f out of 10", trip.driverRating)
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goToTrip")
        {
            let trip = trips[tableView.indexPathForCell((sender as! UITableViewCell))!.row]
            let tripVC = segue.destinationViewController as! TripSummaryTableViewController
            tripVC.trip = trip
        }
    }
    
}
