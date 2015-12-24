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

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mphHeightConstraint: NSLayoutConstraint!
    
    var manager: CLLocationManager!
    var data: [CLLocation] = []
    
    var isDriving: Bool = false
    
    override func viewDidLoad() {
        mphLabel.alpha = 0.0
        mphHeightConstraint.constant = -50
        super.viewDidLoad()
        navigationController?.navigationBar.hideBottomHairline()

        //addBlurEffect()
        setUpCoreLocation()
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "locationUpdate", userInfo: nil, repeats: true)
        timer.tolerance = 0.05
        
        startStopButton.layer.cornerRadius = startStopButton.bounds.width/2
        startStopButton.clipsToBounds = true
    }
    
    func locationUpdate()
    {
        if isDriving
        {
            if let speed2 = manager.location?.speed
            {
                mphLabel.text = "\(2*round(speed2)) MPH"
                data += [manager.location!]
            }
        }
    }
    
    
    @IBAction func startStopPressed() {
        if isDriving == false
        {
            isDriving = true
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                
                let tweetShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                tweetShare.setInitialText("I'm driving. Don't Text. #X")
                //self.presentViewController(tweetShare, animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to activate this function", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            startStopButton.setTitle("Stop", forState: UIControlState.Normal)
            startStopButton.backgroundColor = UIColor(red: 223/255, green: 0, blue: 0, alpha: 0.8)
            buttonHeightConstraint.constant = view.bounds.height/3 - startStopButton.bounds.height/2
            mphHeightConstraint.constant = 0
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.mphLabel.alpha = 1.0
            })
            manager.startUpdatingLocation()
        }else
        {
            manager.stopUpdatingLocation()
            startStopButton.setTitle("Start Drive", forState: UIControlState.Normal)
            print("\(data.count) data points saved")
            data = []
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
        manager.distanceFilter = 1; // meters
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
            manager.startUpdatingLocation()
        }else
        {
            print("Authorizaiton failed. Not always")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("Updating locations...")
        //print(manager.location)
        //speed.text = "\(locations[0].speed) MPH"
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failiure!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

