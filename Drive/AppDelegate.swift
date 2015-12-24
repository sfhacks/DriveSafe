//
//  AppDelegate.swift
//  Drive
//
//  Created by Andrew Ke on 12/23/15.
//  Copyright © 2015 Andrew. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.let navAppearence = UINavigationBar.appearance()
        let navAppearence = UINavigationBar.appearance()
        navAppearence.translucent = true
        //navAppearence.barTintColor = UIColor(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)
        navAppearence.tintColor = UIColor.whiteColor()
        navAppearence.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!]
        
        // create background images for the navigation bar
        let image = UIImage.imageWithColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0))
        
        // customize the appearance of UINavigationBar
        UINavigationBar.appearance().setBackgroundImage(image, forBarMetrics: .Default)
        UINavigationBar.appearance().setBackgroundImage(image, forBarMetrics: .Compact)
        UINavigationBar.appearance().barStyle = .Default
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Avenir Next", size: 18)!], forState: UIControlState.Normal)
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension UIImage
{
    class func imageWithColor(colour: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        
        // Create a 1 by 1 pixel content
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        colour.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}

extension UIViewController
{
    func addBlurEffect() {
        // Add blur view
        var bounds = self.navigationController?.navigationBar.bounds as CGRect!
        bounds.offsetInPlace(dx: 0.0, dy: -20.0)
        bounds.size.height = bounds.height + 20.0
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = bounds
        visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        visualEffectView.userInteractionEnabled = false
        
        self.navigationController?.navigationBar.insertSubview(visualEffectView, atIndex: 0)
        
        // Here you can add visual effects to any UIView control.
        // Replace custom view with navigation bar in above code to add effects to custom view.
    }
}

extension UIToolbar {
    
    func hideHairline() {
        let navigationBarImageView = hairlineImageViewInToolbar(self)
        navigationBarImageView!.hidden = true
    }
    
    func showHairline() {
        let navigationBarImageView = hairlineImageViewInToolbar(self)
        navigationBarImageView!.hidden = false
    }
    
    private func hairlineImageViewInToolbar(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInToolbar(subview) {
                return imageView
            }
        }
        
        return nil
    }
    
}

extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = false
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        
        return nil
    }
    
}

