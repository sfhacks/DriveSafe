//
//  ViewController.swift
//  Drive
//
//  Created by Andrew Ke on 12/23/15.
//  Copyright © 2015 Andrew. All rights reserved.
//

import UIKit
import CoreLocation
import Social
import AEXML
import AudioToolbox

class ViewController: UIViewController, CLLocationManagerDelegate, ModalPresenterVC {
    
    // MARK: - properties
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var speedLimitLabel: UILabel!
    
    // Used for animation
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var speedLimitHeightContraint: NSLayoutConstraint!
    
    var manager: CLLocationManager!
    
    var data: [CLLocation] = [] // Array of locations
    var limits: [Int] = [] // Array of speed limits
    
    var isDriving: Bool = false
    var wasSpeeding: Bool = false
    
    // Stores start and stop dates of current drive
    var startDate: NSDate!
    var stopDate: NSDate!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        speedLimitLabel.alpha = 0.0
        speedLimitHeightContraint.constant = -50
        super.viewDidLoad()
        navigationController?.navigationBar.hideBottomHairline()

        setUpCoreLocation()
        
        // Make button a circle
        startStopButton.layer.cornerRadius = startStopButton.bounds.width/2
        startStopButton.clipsToBounds = true
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("legal") == nil)
        {
            performSegueWithIdentifier("goToLegal", sender: nil)
        }
    }
    
    // MARK: - Core Location
    func setUpCoreLocation()
    {
        manager = CLLocationManager()
        manager.delegate = self
        
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        // Set a movement threshold for new events.
        manager.distanceFilter = 2; // meters
        manager.requestAlwaysAuthorization()
        
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            print("Requesting authorization")
            manager.requestAlwaysAuthorization()
        }else
        {
            print("Authorization good")
        }
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == CLAuthorizationStatus.AuthorizedAlways {
            print("Authorization successful")
        }else
        {
            print("Authorizaiton failed. Not always")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard (NSDate().timeIntervalSinceDate(startDate) > 5)else{return}
        
        print("Adding new location data point \(locations[0].speed)")
        if (locations[0].speed < 0)
        {
            mphLabel.text = "Your Speed: \(0) MPH"
        }else
        {
            mphLabel.text = "Your Speed: \(round(2.2374*locations[0].speed)) MPH"
        }
        
        SpeedLimitFinder.getSpeedLimit(locations[0].coordinate, completion: { (var limit) -> Void in
            if limit == nil
            {
                limit = 40 // Default speed limit
            }
            self.speedLimitLabel.text! = "\(limit!) MPH"
            self.limits.append(limit!)
            if let speed = manager.location?.speed
            {
                if (2.2374 * speed > Double(limit!+5))
                {
                    if (self.wasSpeeding == false)
                    {
                        print("Beeping")
                        AudioServicesPlaySystemSound(1255) // Play beep if user is over the speed limit
                    }
                    self.wasSpeeding = true
                }else
                {
                    self.wasSpeeding = false
                }
            }
        })
        
        data.append(locations[0])
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed!")
    }

    
    // MARK: - Drive Control
    @IBAction func startStopPressed() {
        if isDriving == false
        {
            let alert = UIAlertController(title: "Do Not Disturb", message: "Make sure to turn on Do Not Disturb mode on your iPhone to block calls and notifications so you can stay safe on the road", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                self.tweet()
            }))
            presentViewController(alert, animated: true, completion: nil)
            
            isDriving = true
            startStopButton.setTitle("Stop", forState: UIControlState.Normal)
            startStopButton.backgroundColor = UIColor(red: 223/255, green: 0, blue: 0, alpha: 0.8)
            buttonHeightConstraint.constant = view.bounds.height/3 - startStopButton.bounds.height/2
            speedLimitHeightContraint.constant = 0
            mphLabel.text = "Current Speed: \(0) MPH"
            speedLimitLabel.text = "0 MPH"
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.speedLimitLabel.alpha = 1.0
            })
            manager.startUpdatingLocation()
            startDate = NSDate()
        }else
        {
            stopDate = NSDate()
            speedLimitLabel.text = "0 MPH"
            manager.stopUpdatingLocation()
            startStopButton.setTitle("Start Drive", forState: UIControlState.Normal)
            startStopButton.setTitle("Start Drive", forState: UIControlState.Normal)
            startStopButton.backgroundColor = UIColor(red: 0/255, green: 198/255, blue: 0/255, alpha: 1.0)
            buttonHeightConstraint.constant = 0
            speedLimitHeightContraint.constant = -50
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.speedLimitLabel.alpha = 0.0
            })
            isDriving = false
            
            performSelector("showTripData", withObject: self, afterDelay: 1.0)
        }
    }
    
    func tweet()
    {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let tweetShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            let formatter = NSDateFormatter()
            formatter.dateStyle = .NoStyle
            formatter.timeStyle = .ShortStyle
            tweetShare.setInitialText("I'm driving. Don't text me until \(formatter.stringFromDate(NSDate().dateByAddingTimeInterval(600))). #X")
            self.presentViewController(tweetShare, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to activate this function", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    func showTripData()
    {
        performSegueWithIdentifier("showTripData", sender: data)
    }
    
    // MARK: - Navigation
    
    func didDismiss() {
        blur.removeFromSuperview()
    }
    
    var blur: UIVisualEffectView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != "goToLegal")
        {
            blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
            blur.frame = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y-64, width: view.bounds.width, height: view.bounds.height+64)
            blur.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            view.addSubview(blur)

        }
        if (segue.identifier == "showTripData")
        {
            let nav = segue.destinationViewController as! UINavigationController
            let tripSummary = nav.viewControllers[0] as! TripSummaryTableViewController
            tripSummary.delegate = self
            print("\(data.count) data points saved")
            print("\(limits.count) speed limits saved")
            tripSummary.trip = Trip(data: data, limits: limits)
            tripSummary.trip.startDate = startDate
            tripSummary.trip.stopDate = stopDate
            
            data = []
            limits = []
            let defaults = NSUserDefaults.standardUserDefaults()
            
            // Store new trip in NSUserDefaults
            if let tripsData = defaults.objectForKey("trips") as? NSData
            {
                var trips = NSKeyedUnarchiver.unarchiveObjectWithData(tripsData) as! [Trip]
                trips.append(tripSummary.trip)
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(trips), forKey: "trips")
            }else
            {
                var trips = [Trip]()
                trips.append(tripSummary.trip)
                let tripsData = NSKeyedArchiver.archivedDataWithRootObject(trips)
                defaults.setObject(tripsData, forKey: "trips")
            }
            defaults.synchronize()
        }
        if (segue.identifier == "showTrips")
        {
            let nav = segue.destinationViewController as! UINavigationController
            let trips = nav.viewControllers[0] as! TripsTableViewController
            trips.delegate = self
        }
        if (segue.identifier == "showTips")
        {
            let nav = segue.destinationViewController as! UINavigationController
            let tips = nav.viewControllers[0] as! TipsViewController
            tips.delegate = self
        }
    }
}

