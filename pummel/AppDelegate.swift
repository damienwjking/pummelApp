//
//  AppDelegate.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
//  Required Cocoapods
//


import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var token: NSString!
    var currentUserId: String!
    var searchDetail: NSDictionary!
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
    //    Mixpanel.initialize(token: "9007be62479ca54acb05b03991f1e56e")
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.currentNotificationCenter()
            center.delegate = self
            center.requestAuthorizationWithOptions([.Alert, .Badge, .Sound],completionHandler: { (granted, error) in
                // Enable or disable features based on authorization
            })

        } else {
            // Fallback on earlier versions
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        return true
    }
    
    func incrementBadgeNumberBy(badgeNumberIncrement: Int) {
        let currentBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
        let updatedBadgeNumber = currentBadgeNumber + badgeNumberIncrement
        if (updatedBadgeNumber > -1) {
            UIApplication.sharedApplication().applicationIconBadgeNumber = updatedBadgeNumber
        }
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
         NSNotificationCenter.defaultCenter().postNotificationName(k_PM_SHOW_BADGE, object: nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // implemented in your application delegate
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
       let deviceTokenString = deviceToken.hexString
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(deviceTokenString, forKey: k_PM_PUSH_TOKEN)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Couldn't register: \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    @available(iOS 10.0, *)
    internal func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
}

extension NSData {
    var hexString: String {
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        return bytes.map { String(format: "%02hhx", $0) }.reduce("", combine: { $0 + $1 })
    }
}

