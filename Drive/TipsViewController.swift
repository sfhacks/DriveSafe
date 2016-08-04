//
//  TipsViewController.swift
//  Drive
//
//  Created by Andrew Ke on 12/26/15.
//  Copyright © 2015 Andrew. All rights reserved.
//

import UIKit

class TipsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var delegate:ModalPresenterVC!
    
    var data: [String] = ["When available, use a hands-free device."
        ,"Position your cell phone within easy reach."
        ,"Suspend conversations during hazardous driving conditions or situations."
        ,"Do not engage in stressful or emotional conversations that may be distracting."
        ,"Obey the speed limits. Going too fast gives you less time to stop or react. Excess speed is one of the main causes of teenage accidents."
        ,"Don’t leave valuables like wallets, shoes, laptops, jackets, phones, or sports equipment in your car where they can be seen easily."
        ,"Make sure your windshield is clean. At sunrise and sunset, light reflecting off your dirty windshield can momentarily blind you from seeing what’s going on."
        ,"Always wear your seat belt – and make sure all passengers buckle up, too. Don’t try to fit more people in the car than you have seat belts for them to use."]
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Configure autosizing cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        navigationController?.navigationBar.hideBottomHairline()
        (presentingViewController as! UINavigationController).navigationBarHidden = true
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        (presentingViewController as! UINavigationController).navigationBarHidden = false
        if let delegate = delegate
        {
            delegate.didDismiss()
        }
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}
