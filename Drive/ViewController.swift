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
    
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var speedLimitLabel: UILabel!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mphHeightConstraint: NSLayoutConstraint!
    
    var manager: CLLocationManager!
    
    var data: [CLLocation] = [] // Array of locations
    var limits: [Int] = [] // Array of speed limits
    
    var isDriving: Bool = false
    var startDate: NSDate!
    var stopDate: NSDate!
    
    override func viewDidLoad() {
        mphLabel.alpha = 0.0
        mphHeightConstraint.constant = -50
        super.viewDidLoad()
        navigationController?.navigationBar.hideBottomHairline()

        //addBlurEffect()
        setUpCoreLocation()
        //let timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "locationUpdate", userInfo: nil, repeats: true)
        //timer.tolerance = 0.05
        
        startStopButton.layer.cornerRadius = startStopButton.bounds.width/2
        startStopButton.clipsToBounds = true
        
        SpeedLimitFinder.getSpeedLimit(CLLocationCoordinate2D(latitude: 37.360214, longitude: -122.148528)) { (limit) -> Void in
            print(limit)
        }
    }
    
    
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
            mphHeightConstraint.constant = 0
            mphLabel.text = "\(0) MPH"

            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.mphLabel.alpha = 1.0
            })
            manager.startUpdatingLocation()
            startDate = NSDate()
        }else
        {
            stopDate = NSDate()
            manager.stopUpdatingLocation()
            startStopButton.setTitle("Start Drive", forState: UIControlState.Normal)
            startStopButton.setTitle("Start Drive", forState: UIControlState.Normal)
            startStopButton.backgroundColor = UIColor(red: 0/255, green: 198/255, blue: 0/255, alpha: 1.0)
            buttonHeightConstraint.constant = 0
            mphHeightConstraint.constant = -50
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.mphLabel.alpha = 0.0
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
            //manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == CLAuthorizationStatus.AuthorizedAlways {
            //manager.startUpdatingLocation()
        }else
        {
            print("Authorizaiton failed. Not always")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Adding new location data point")
        if (locations[0].speed < 0)
        {
            mphLabel.text = "\(0) MPH"
        }else
        {
            mphLabel.text = "\(round(2.2374*locations[0].speed)) MPH"
        }
        
        SpeedLimitFinder.getSpeedLimit(locations[0].coordinate, completion: { (var limit) -> Void in
            if limit == nil
            {
                limit = 40
            }
            self.speedLimitLabel.text! = "Current Speed Limit: \(limit!) MPH"
            self.limits.append(limit!)
            if let speed = manager.location?.speed
            {
                if (speed > Double(limit!))
                {
                    AudioServicesPlaySystemSound(1255)
                }
            }
        })
        
        data.append(locations[0])
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed!")
    }
    
    func didDismiss() {
        blur.removeFromSuperview()
    }
    
    var blur: UIVisualEffectView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blur.frame = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y-64, width: view.bounds.width, height: view.bounds.height+64)
        blur.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        view.addSubview(blur)
        
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

