//
//  BaseViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 1/17/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidAppear(_:)), name: NSNotification.Name(rawValue: k_PM_MOVE_SCREEN_NOTIFICATION), object: nil)
        
        // Get messasge notification + session notification
        self.updateSMLCBadge()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.moveScreen()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: k_PM_MOVE_SCREEN_NOTIFICATION), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func resetSBadge() {
        NotificationRouter.resetSBadge { (result, error) in
            self.updateSMLCBadge()
            }.fetchdata()
    }
    
    func resetLBadge() {
        NotificationRouter.resetLBadge { (result, error) in
            self.updateSMLCBadge()
            }.fetchdata()
    }
    
    func resetCBadge() {
        NotificationRouter.resetCBadge { (result, error) in
            self.updateSMLCBadge()
            }.fetchdata()
    }
    
    func updateSMLCBadge() {
        NotificationRouter.getNotificationBadge { (result, error) in
            if (error == nil) {
                let dataArray = result as? NSArray
                
                let feedTabItem = self.tabBarController?.tabBar.items![0]
                let sessionTabItem = self.tabBarController?.tabBar.items![1]
                let messageTabItem = self.tabBarController?.tabBar.items![3]
                
                if #available(iOS 10.0, *) {
                    feedTabItem?.badgeColor = UIColor.pmmBrightOrangeColor()
                    sessionTabItem?.badgeColor = UIColor.pmmBrightOrangeColor()
                    messageTabItem?.badgeColor = UIColor.pmmBrightOrangeColor()
                }
                
                
                if (dataArray == nil) {
                    // Get no data
                    sessionTabItem?.badgeValue = nil
                    messageTabItem?.badgeValue = nil
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    
                } else {
                    // [Message] [Session] [Lead] [Comment]
                    let mBadge = dataArray![0] as? Int
                    let sBadge = dataArray![1] as? Int
                    let lBadge = dataArray![2] as? Int
                    let cBadge = dataArray![3] as? Int
                    
                    var totalBadge = 0
                    
                    // Comment badge
                    if (cBadge != nil && cBadge! > 0) {
                        feedTabItem?.badgeValue = String(format: "%d", cBadge!)
                        
                        totalBadge = totalBadge + cBadge!
                    } else {
                        feedTabItem?.badgeValue = nil
                    }
                    
                    // Message badge
                    if (mBadge != nil && mBadge! > 0) {
                        messageTabItem?.badgeValue = String(format: "%d", mBadge!)
                        
                        totalBadge = totalBadge + mBadge!
                    } else {
                        messageTabItem?.badgeValue = nil
                    }
                    
                    // Session badge
                    if (sBadge != nil && sBadge! > 0) {
                        sessionTabItem?.badgeValue = String(format: "%d", sBadge!)
                        
                        totalBadge = totalBadge + sBadge!
                    } else {
                        sessionTabItem?.badgeValue = nil
                    }
                    
                    // Lead Badge
                    if (lBadge != nil && lBadge! > 0) {
                        totalBadge = totalBadge + lBadge!
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_UPDATE_LEAD_BADGE), object: lBadge)
                    
                    UIApplication.shared.applicationIconBadgeNumber = totalBadge
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func showPostTestimonialViewController() {
        let defaults = UserDefaults.standard
        defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        
        // Get user information + add to navigation
        let userID = defaults.object(forKey: k_PM_MOVE_SCREEN_DEEPLINK_TESTIMONIAL) as? String
        defaults.set("", forKey: k_PM_MOVE_SCREEN_DEEPLINK_TESTIMONIAL)
        
        // Capture screen shot
        let screenImage = self.view.renderImage()
        
        let postTestimonialVC = UIStoryboard(name: "PostTestimonial", bundle: nil).instantiateInitialViewController() as! PostTestimonialViewController
        postTestimonialVC.userID = userID!
        postTestimonialVC.backgroundImage = screenImage
        
        self.present(postTestimonialVC, animated: true, completion: nil)
    }
    
    func moveScreen() {
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: k_PM_MOVE_SCREEN) != nil) {
            let moveScreenType = defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
            
            if moveScreenType == k_PM_MOVE_SCREEN_NO_MOVE {
                // Do nothing
            } else {
                if (self as? LogSessionClientViewController != nil) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
                if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_1 {
                    if (((self as? FindViewController) != nil) ||
                        ((self as? LetUsHelpViewController) != nil)) {
                        // Do nothing
                    } else {
                        self.tabBarController?.selectedIndex = 2
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_2 {
                    if (((self as? LogSessionClientViewController) != nil) ||
                        ((self as? SessionCoachViewController) != nil)) {
                        // Do nothing
                    } else {
                        self.tabBarController?.selectedIndex = 1
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_3 {
                    if ((self as? MessageViewController) == nil){
                        self.tabBarController?.selectedIndex = 3
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_4 {
                    if ((self as? FeaturedViewController) == nil){
                        self.tabBarController?.selectedIndex = 0
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_NOTI_FEED {
                    if ((self as? FeaturedViewController) == nil){
                        self.tabBarController?.selectedIndex = 0
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_NOTI_NEW_LEAD {
                    if ((self as? FindViewController) == nil) {
                        self.tabBarController?.selectedIndex = 2
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_NOTI_NEW_MESSAGE {
                    if ((self as? MessageViewController) == nil) {
                        self.tabBarController?.selectedIndex = 3
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_NOTI_INCOMING_SESSION {
                    if (((self as? LogSessionClientViewController) != nil) ||
                        ((self as? SessionCoachViewController) != nil)) {
                        // Do nothing
                    } else {
                        self.tabBarController?.selectedIndex = 1
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_SEARCH {
                    self.tabBarController?.selectedIndex = 2
                } else if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_LOGIN {
                    // Check in GetStartedViewController
                } else if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_PROFILE {
                    defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
                    
                    // Get user information + add to navigation
                    let userID = defaults.object(forKey: k_PM_MOVE_SCREEN_DEEPLINK_PROFILE) as? String
                    defaults.set("", forKey: k_PM_MOVE_SCREEN_DEEPLINK_PROFILE)
                    
                    if (userID != nil && userID?.isEmpty == false) {
                        PMHelper.showCoachOrUserView(userID: userID!)
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_TESTIMONIAL {
                    // Get user information + add to navigation
                    let userID = defaults.object(forKey: k_PM_MOVE_SCREEN_DEEPLINK_TESTIMONIAL) as? String
                    
                    if (userID != nil && userID?.isEmpty == false) {
                        PMHelper.showCoachOrUserView(userID: userID!, showTestimonial: true)
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_MESSAGE_DETAIL {
                    self.tabBarController?.selectedIndex = 3
                } else if moveScreenType == k_PM_MOVE_SCREEN_CURRENT_PROFILE {
                    if (self.navigationController != nil) {
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    if (self.tabBarController != nil) {
                        defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
                        
                        self.tabBarController?.selectedIndex = 4
                    }
                } else {
                    defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
                }
            }
        } else {
            defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        }
    }

    
}
