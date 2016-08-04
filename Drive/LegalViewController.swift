//
//  LegalViewController.swift
//  DriveSafe
//
//  Created by Andrew Ke on 12/30/15.
//  Copyright © 2015 Andrew. All rights reserved.
//

import UIKit

class LegalViewController: UIViewController {
    override func viewDidLoad() {
        revertNav()
    }
    
    @IBAction func agree(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(true, forKey: "legal")
        defaults.synchronize()
        setNav()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
