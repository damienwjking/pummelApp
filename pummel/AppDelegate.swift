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
import SwiftMessages
import Mixpanel
import Alamofire
import FBSDKCoreKit
import Branch
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var token: NSString!
    var currentUserId: String!
    var searchDetail: NSDictionary!
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
    //    Mixpanel.initialize(token: "9007be62479ca54acb05b03991f1e56e")
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
        let token = "9007be62479ca54acb05b03991f1e56e"
        _ = Mixpanel.sharedInstanceWithToken(token)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let branch: Branch = Branch.getInstance()
        branch.initSessionWithLaunchOptions(launchOptions, automaticallyDisplayDeepLinkController: true) { (params, error) in
            if error == nil {
                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                // params will be empty if no data found
                // ... insert custom logic here ...
                print("params: %@", params!.description)
            }
        }
       
        FIRApp.configure()
        
        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String!, annotation: nil)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if ((defaults.objectForKey(k_PM_CURRENT_ID)) != nil) {
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf("/resetNotificationBadge")
            Alamofire.request(.PUT, prefix, parameters: [:])
                .responseJSON { response in
            }
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //     NSNotificationCenter.defaultCenter().postNotificationName(k_PM_SHOW_BADGE, object: nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Remove badge
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        // Reset badge in server
        let defaults = NSUserDefaults.standardUserDefaults()
        if ((defaults.objectForKey(k_PM_CURRENT_ID)) != nil) {
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf("/resetNotificationBadge")
            Alamofire.request(.PUT, prefix, parameters: [:])
                .responseJSON { response in
            }

        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(k_PM_IS_LOGINED) != nil) {
            if defaults.boolForKey(k_PM_IS_LOGINED) == true {
                let type = shortcutItem.type.componentsSeparatedByString(".").last!
                
                defaults.setObject(type, forKey: k_PM_MOVE_SCREEN)
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(k_PM_MOVE_SCREEN_NOTIFICATION, object: nil)
                }
            }
        }
    }
    
    // implemented in your application delegate
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenString = deviceToken.hexString
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(deviceTokenString, forKey: k_PM_PUSH_TOKEN)
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.people.addPushDeviceToken(deviceToken)
        
        let currentId = NSUserDefaults.standardUserDefaults().objectForKey(k_PM_CURRENT_ID) as! String
        let param = [kUserId:currentId,
                     kProtocol:"APNS",
                     kToken: deviceTokenString]
        
        var linkPostNotif = kPMAPIUSER
        linkPostNotif.appendContentsOf(currentId)
        linkPostNotif.appendContentsOf(kPM_PATH_DEVICES)
        Alamofire.request(.POST, linkPostNotif, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    print("Already push tokenString")
                } else {
                    print("Can't push tokenString")
                }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Couldn't register: \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let alert = userInfo["aps"]!["alert"] as! String
        let defaults = NSNotificationCenter.defaultCenter()
        
        if (UIApplication.sharedApplication().applicationState != .Active) {
            if (alert.containsString("Hey you have a new message")) {
                // OPEN MESSAGE SCREEEN --> RELOAD
                defaults.setValue(k_PM_MOVE_SCREEN_NOTI_NEW_MESSAGE, forKey: k_PM_MOVE_SCREEN)
            }
            if (alert.containsString("you have a new comment in your post:")) {
                // OPEN FEED
                defaults.setValue(k_PM_MOVE_SCREEN_NOTI_FEED, forKey: k_PM_MOVE_SCREEN)
            }
            if (alert.containsString("You have a new Lead")) {
                // OPEN CLIENT SCREEN (ONLY COACH)
                defaults.setValue(k_PM_MOVE_SCREEN_NOTI_NEW_LEAD, forKey: k_PM_MOVE_SCREEN)
            }
            if (alert.containsString("You have a new booking")){
                // OPEN INCOMING SESSION SCREEN
                defaults.setValue(k_PM_MOVE_SCREEN_NOTI_INCOMING_SESSION, forKey: k_PM_MOVE_SCREEN)
            }
            
            defaults.postNotificationName(k_PM_MOVE_SCREEN_NOTIFICATION, object: nil)
        } else {
            if (alert.containsString("Hey you have a new message")) {
                defaults.setValue(k_PM_MOVE_SCREEN_NOTI_NEW_MESSAGE, forKey: k_PM_MOVE_SCREEN)
                
                let notification = MessageView.viewFromNib(layout: .CardView)
                notification.configureTheme(.Success)
                notification.configureTheme(backgroundColor: UIColor.pmmBrightOrangeColor(), foregroundColor: UIColor.whiteColor())
                notification.configureDropShadow()
                notification.configureContent(title: "Pummel", body: alert)
                notification.button?.hidden = true
                notification.iconImageView?.image = UIImage(named: "miniPummelLogo")
                var notificationConfig = SwiftMessages.defaultConfig
                notificationConfig.duration = .Seconds(seconds: 3);
                notificationConfig.presentationStyle = .Top
                notificationConfig.presentationContext = .Window(windowLevel: UIWindowLevelNormal)
                SwiftMessages.show(config: notificationConfig, view: notification)
                
                let foregroundButton = UIButton(action: { (UIControl) in
                    //TODO: GO TO LIST MESSAGE, IF DANG O LIST MESSAGE --> RELOAD
                    defaults.setValue(k_PM_MOVE_SCREEN_NOTI_NEW_MESSAGE, forKey: k_PM_MOVE_SCREEN)
                    
                    }, forControlEvents: .TouchUpInside)
                foregroundButton.frame = CGRectMake(0, 0, 1000, 1000)
                
                notification.addSubview(foregroundButton)
            }
            
            if (alert.containsString("you have a new comment in your post:")) {
                let notification = MessageView.viewFromNib(layout: .CardView)
                notification.configureTheme(.Success)
                notification.configureTheme(backgroundColor: UIColor.pmmBrightOrangeColor(), foregroundColor: UIColor.whiteColor())
                notification.configureDropShadow()
                notification.configureContent(title: "Pummel", body: alert)
                notification.button?.hidden = true
                notification.iconImageView?.image = UIImage(named: "miniPummelLogo")
                var notificationConfig = SwiftMessages.defaultConfig
                notificationConfig.duration = .Seconds(seconds: 3);
                notificationConfig.presentationStyle = .Top
                notificationConfig.presentationContext = .Window(windowLevel: UIWindowLevelNormal)
                SwiftMessages.show(config: notificationConfig, view: notification)
                
                let foregroundButton = UIButton(action: { (UIControl) in
                    //TODO: GO TO FEED, IF DANG O FEED --> RELOAD
                    }, forControlEvents: .TouchUpInside)
                foregroundButton.frame = CGRectMake(0, 0, 1000, 1000)
                
                notification.addSubview(foregroundButton)
            }
            if (alert.containsString("You have a new Lead")) {
                // TODO: OPEN CLIENT SCREEN (ONLY COACH)
                let notification = MessageView.viewFromNib(layout: .CardView)
                notification.configureTheme(.Success)
                notification.configureTheme(backgroundColor: UIColor.pmmBrightOrangeColor(), foregroundColor: UIColor.whiteColor())
                notification.configureDropShadow()
                notification.configureContent(title: "Pummel", body: alert)
                notification.button?.hidden = true
                notification.iconImageView?.image = UIImage(named: "miniPummelLogo")
                var notificationConfig = SwiftMessages.defaultConfig
                notificationConfig.duration = .Seconds(seconds: 3);
                notificationConfig.presentationStyle = .Top
                notificationConfig.presentationContext = .Window(windowLevel: UIWindowLevelNormal)
                SwiftMessages.show(config: notificationConfig, view: notification)
                
                let foregroundButton = UIButton(action: { (UIControl) in
                    //TODO: GO TO LIST CLIENTS, NEU DANG O LIST CLIENTS --> RELOAD (ONLY COACH)
                    }, forControlEvents: .TouchUpInside)
                foregroundButton.frame = CGRectMake(0, 0, 1000, 1000)
                
                notification.addSubview(foregroundButton)
            }
            if (alert.containsString("You have a new booking")){
                // TODO: OPEN INCOMING SESSION SCREEN
                let notification = MessageView.viewFromNib(layout: .CardView)
                notification.configureTheme(.Success)
                notification.configureTheme(backgroundColor: UIColor.pmmBrightOrangeColor(), foregroundColor: UIColor.whiteColor())
                notification.configureDropShadow()
                notification.configureContent(title: "Pummel", body: alert)
                notification.button?.hidden = true
                notification.iconImageView?.image = UIImage(named: "miniPummelLogo")
                var notificationConfig = SwiftMessages.defaultConfig
                notificationConfig.duration = .Seconds(seconds: 3);
                notificationConfig.presentationStyle = .Top
                notificationConfig.presentationContext = .Window(windowLevel: UIWindowLevelNormal)
                SwiftMessages.show(config: notificationConfig, view: notification)
                
                let foregroundButton = UIButton(action: { (UIControl) in
                    //TODO: GO TO LIST INCOMMING SESSION. NEU DANG O LIST ICOMMING SESSION --> RELOAD
                    }, forControlEvents: .TouchUpInside)
                foregroundButton.frame = CGRectMake(0, 0, 1000, 1000)
                
                notification.addSubview(foregroundButton)
            }
        }
    }

//    @available(iOS 10.0, *)
//    internal func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
//        UIApplication.sharedApplication().applicationIconBadgeNumber == 0
//    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().handleDeepLink(url);
        
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
    
    // Respond to Universal Links
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        Branch.getInstance().continueUserActivity(userActivity)
        
        return true
    }
}


extension NSData {
    var hexString: String {
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        return bytes.map { String(format: "%02hhx", $0) }.reduce("", combine: { $0 + $1 })
    }
}

