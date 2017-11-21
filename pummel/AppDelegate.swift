
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
import Stripe
import Firebase
import Mixpanel
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import SwiftMessages
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var token: NSString!
    var currentUserId: String!
    var searchDetail: NSDictionary!
    var notificationText = "" // Only for notification
    
    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
    //    Mixpanel.initialize(token: "9007be62479ca54acb05b03991f1e56e")
        
        UserDefaults.standard.set(0, forKey: "MESSAGE_BADGE_VALUE")
        
        UIApplication.shared.applicationIconBadgeNumber = 0;
        let token = "9007be62479ca54acb05b03991f1e56e"
        _ = Mixpanel.sharedInstance(withToken: token)
        
        FirebaseApp.configure()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

//    @available(iOS 10.0, *)
//    internal func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
//        UIApplication.shared.applicationIconBadgeNumber == 0
//    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }
}

// MARK: - Life circle
extension AppDelegate {
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        let defaults = UserDefaults.standard
        if ((defaults.object(forKey: k_PM_CURRENT_ID)) != nil) {
            var prefix = kPMAPIUSER
            prefix.append(PMHelper.getCurrentID())
            prefix.append("/resetNotificationBadge")
            Alamofire.request(prefix, method: .put, parameters: [:])
                .responseJSON { response in
            }
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //     NotificationCenter.default.post(name: k_PM_SHOW_BADGE, object: nil)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Remove badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Reset badge in server
        let defaults = UserDefaults.standard
        if ((defaults.object(forKey: k_PM_CURRENT_ID)) != nil) {
            var prefix = kPMAPIUSER
            prefix.append(PMHelper.getCurrentID())
            prefix.append("/resetNotificationBadge")
            Alamofire.request(prefix, method: .put, parameters: [:])
                .responseJSON { response in
            }
            
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
}

// MARK: - URL
extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.absoluteString.contains("pummel://") == true) {
            let userDefaults = UserDefaults.standard
            let urlPath = url.path.lowercased()
            
            let urlAbsoluteString = url.absoluteString.lowercased()
            
            let kProfileKey = "coach?userId=".lowercased()
            let kTestimonialKey = "givetestimonial/coachId=".lowercased()
            
            if ((urlPath.contains("search")) == true) {
                // Open Pummel
                userDefaults.set(k_PM_MOVE_SCREEN_DEEPLINK_SEARCH, forKey: k_PM_MOVE_SCREEN)
            } else if ((urlPath.contains("login")) == true) {
                // Allow me to Login/Register
                let logined = userDefaults.value(forKey: k_PM_IS_LOGINED)
                
                if (logined as? Bool != nil && logined as? Bool == false) {
                    userDefaults.set(k_PM_MOVE_SCREEN_DEEPLINK_LOGIN, forKey: k_PM_MOVE_SCREEN)
                }
            } else if ((urlAbsoluteString.contains(kProfileKey)) == true) {
                // Take me directly to my coaches Profile and connect me to him automatically.
                userDefaults.set(k_PM_MOVE_SCREEN_DEEPLINK_PROFILE, forKey: k_PM_MOVE_SCREEN)
                
                let userID = url.absoluteString.components(separatedBy: "=")[1]
                if (userID.isEmpty == false) {
                    userDefaults.set(userID, forKey: k_PM_MOVE_SCREEN_DEEPLINK_PROFILE)
                }
            } else if ((urlAbsoluteString.contains(kTestimonialKey)) == true) {
                // Show post testimonial view.
                userDefaults.set(k_PM_MOVE_SCREEN_DEEPLINK_TESTIMONIAL, forKey: k_PM_MOVE_SCREEN)
                
                let userID = url.absoluteString.components(separatedBy: "=")[1]
                if (userID.isEmpty == false) {
                    userDefaults.set(userID, forKey: k_PM_MOVE_SCREEN_DEEPLINK_TESTIMONIAL)
                }
            }
            
            userDefaults.synchronize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_MOVE_SCREEN_NOTIFICATION), object: nil)
            }
            
            return true
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url as URL!, options: options)
    }
}

// MARK: - Notification
extension AppDelegate {
    // implemented in your application delegate
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.hexString
        let defaults = UserDefaults.standard
        defaults.set(deviceTokenString, forKey: k_PM_PUSH_TOKEN)
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel?.people.addPushDeviceToken(deviceToken)
        
        let currentId = PMHelper.getCurrentID()
        let param = [kUserId:currentId,
                     kProtocol:"APNS",
                     kToken: deviceTokenString]
        
        var linkPostNotif = kPMAPIUSER
        linkPostNotif.append(currentId)
        linkPostNotif.append(kPM_PATH_DEVICES)
        Alamofire.request(linkPostNotif, method: .post, parameters: param)
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        let aps = userInfo["aps"] as! NSDictionary
        let alert = aps["alert"] as! String
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_SHOW_MESSAGE_BADGE), object: nil)
        
        if (UIApplication.shared.applicationState != .active) {
            // Update badge app
            //            let totalBadge = userInfo["aps"]!["badge"] as! Int
            //            UIApplication.shared.applicationIconBadgeNumber = totalBadge
            
            // check message
            if (alert.contains(find: "Hey you have a new message")) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_SHOW_LIST_MESSAGE_SCREEN), object: nil)
            }
            if (alert.contains(find: "you have a new comment in your post:")) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_SHOW_FEED), object: nil)
            }
            if (alert.contains(find: "You have a new Lead")) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_SHOW_SHOW_CLIENTS), object: nil)
            }
            if (alert.contains(find: "You have a new booking")){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_SHOW_SHOW_SESSIONS), object: nil)
            }
        } else {
            // Prepare router navigation
            if (alert.contains(find: "Hey you have a new message")) {
                // OPEN MESSAGE TAB
                self.notificationText = k_PM_SHOW_LIST_MESSAGE_SCREEN
            } else if (alert.contains(find: "you have a new comment in your post:")) {
                // OPEN FEED TAB
                self.notificationText = k_PM_SHOW_FEED
            } else if (alert.contains(find: "You have a new Lead")) {
                // OPEN CLIENT SCREEN (ONLY COACH)
                self.notificationText = k_PM_SHOW_SHOW_CLIENTS
            }
            if (alert.contains(find: "You have a new booking")){
                // OPEN INCOMING SESSION SCREEN
                self.notificationText = k_PM_SHOW_SHOW_SESSIONS
            }
            
            // Show push notification
            let notification = MessageView.viewFromNib(layout: .CardView)
            notification.configureTheme(.success)
            notification.configureTheme(backgroundColor: UIColor.pmmBrightOrangeColor(), foregroundColor: UIColor.white)
            notification.configureDropShadow()
            notification.configureContent(title: "Pummel", body: alert)
            notification.button?.isHidden = true
            notification.iconImageView?.image = UIImage(named: "miniPummelLogo")
            var notificationConfig = SwiftMessages.defaultConfig
            notificationConfig.duration = .seconds(seconds: 3);
            notificationConfig.presentationStyle = .top
            notificationConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
            SwiftMessages.show(config: notificationConfig, view: notification)
            
            let foregroundButton = UIButton()
            foregroundButton.addTarget(self, action: #selector(self.foreGroundButtonClicked(_:)), for: .touchUpInside)
            foregroundButton.frame = CGRect(x: 0, y: 0, width: 1000, height: 1000)
            
            notification.addSubview(foregroundButton)
        }
    }
    
    func foreGroundButtonClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.notificationText), object: nil)
    }
}

// MARK: - 3D Touch
extension AppDelegate {
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let type = shortcutItem.type.components(separatedBy: ".").last!
        
        let defaults = UserDefaults.standard
        defaults.set(type, forKey: k_PM_MOVE_SCREEN)
        defaults.synchronize()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_MOVE_SCREEN_NOTIFICATION), object: nil)
        }
    }
}

