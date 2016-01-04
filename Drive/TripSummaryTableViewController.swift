//
//  TripSummaryTableViewController.swift
//  Drive
//
//  Created by Andrew Ke on 12/23/15.
//  Copyright © 2015 Andrew. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

// didDismiss is called when a modalally presented view controller dismisses itself
// This protocol is used to allow ViewController.swift to be notified so it can remove the blur when needed
protocol ModalPresenterVC
{
    func didDismiss()
}

class TripSummaryTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var driverRatingCircle: UILabel!
    
    // MARK: - Properties
    var info = ["Average Speed", "Time Elapsed", "Driver Rating", "Number of offenses"]
    var trip: Trip!
    var delegate: ModalPresenterVC?
    var notModal: Bool = false // If this is true, the view controller was pushed by a navigation controller. If false, it was modally presented
    
    var colors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor()]
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.hideBottomHairline()
        (presentingViewController as! UINavigationController).navigationBarHidden = true

        if (!notModal)
        {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneButtonPressed:")
        }
        
        print("****DEBUG LOG****")
        print("\(trip.data.count) locations recorded, \(trip.limits.count) speed limits recorded")
        for (var i = 0; i < min(trip.data.count, trip.limits.count); i++)
        {
            print("\(i). Recorded: \(2.2374 * trip.data[i].speed)    Limit: \(trip.limits[i])")
        }
        
        driverRatingCircle.alpha = 0.5
        driverRatingCircle.layer.borderColor = colors[Int(round(trip.driverRating/2.5))].CGColor
        driverRatingCircle.layer.borderWidth = 8.0
        driverRatingCircle.layer.cornerRadius = driverRatingCircle.bounds.width/2
        driverRatingCircle.clipsToBounds = true
        driverRatingCircle.text = "\(trip.driverRating)"
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if let delegate = delegate
        {
            delegate.didDismiss()
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            (presentingViewController as! UINavigationController).navigationBarHidden = false
        }
    }
    
    // MARK: - Email Sending
    @IBAction func sendEmail(sender: UIBarButtonItem) {
        revertNav()
        let vc = MFMailComposeViewController()
        vc.view.backgroundColor = UIColor.clearColor()
        vc.mailComposeDelegate = self
        vc.setSubject("My Driver Rating")
        vc.setMessageBody("On my latest drive, I got a driver rating of \(trip.driverRating) out of 10!", isHTML: false)
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        setNav()
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        cell.textLabel?.text = info[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
        
        switch info[indexPath.row] {
        case "Time Elapsed":
            cell.detailTextLabel?.text = String(format: "%.1f minutes", trip.timeLapsed/60.0)
        case "Average Speed":
            cell.detailTextLabel?.text = String(format: "%.1f MPH", 2.2374 * trip.averageSpeed)
        case "Driver Rating":
            cell.detailTextLabel?.text = String(format: "%.1f out of 10", trip.driverRating)
        case "Number of offenses":
            cell.detailTextLabel?.text = String(format: "%d/%d", trip.numberOfOffenses, trip.totalDataPoints)
        default:
            break
        }
        return cell
    }


}
