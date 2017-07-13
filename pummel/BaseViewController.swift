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
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.viewDidAppear(_:)), name: k_PM_MOVE_SCREEN_NOTIFICATION, object: nil)
        
        self.checkMoveScreen()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get messasge notification + session notification
        self.updateSMBadge()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: k_PM_MOVE_SCREEN_NOTIFICATION, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSMBadge() {
        NotificationRouter.getMBadgeSBadge { (result, error) in
            if (error == nil) {
                let dataArray = result as? NSArray
                
                let sessionTabItem = self.tabBarController?.tabBar.items![1]
                let messageTabItem = self.tabBarController?.tabBar.items![3]
                if (dataArray == nil) {
                    // Get no data
                    sessionTabItem?.badgeValue = nil
                    messageTabItem?.badgeValue = nil
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                    
                } else {
                    let mBadge = dataArray![0] as? Int
                    let sBadge = dataArray![1] as? Int
                    var totalBadge = 0
                    
                    // Message badge
                    if (mBadge != nil && mBadge > 0) {
                        messageTabItem?.badgeValue = String(format: "%d", mBadge!)
                        
                        totalBadge = totalBadge + mBadge!
                    } else {
                        messageTabItem?.badgeValue = nil
                    }
                    
                    // Session badge
                    if (sBadge != nil && sBadge > 0) {
                        sessionTabItem?.badgeValue = String(format: "%d", sBadge!)
                        
                        totalBadge = totalBadge + sBadge!
                    } else {
                        sessionTabItem?.badgeValue = nil
                    }
                    
//                    UIApplication.sharedApplication().applicationIconBadgeNumber = totalBadge
                }
            } else {
                print("Request failed with error: \(error)")
            }
            }.fetchdata()
    }
    
    func checkMoveScreen() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(k_PM_MOVE_SCREEN) != nil) {
            let moveScreenType = defaults.objectForKey(k_PM_MOVE_SCREEN) as! String
            
            if moveScreenType == k_PM_MOVE_SCREEN_NO_MOVE {
                // Do nothing
            } else {
                if (self.isKindOfClass(LogSessionClientViewController) == false) {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                
                if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_1 {
                    if (self.isKindOfClass(FindViewController) == true ||
                        self.isKindOfClass(LetUsHelpViewController) == true){
                        // Do nothing
                    } else {
                        self.tabBarController?.selectedIndex = 2
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_2 {
                    if (self.isKindOfClass(ProgressViewController) == true) {
                        
                    } else if (self.isKindOfClass(LogSessionClientViewController) == true) {
                        
                    } else if (self.isKindOfClass(SessionCoachViewController) == true) {
                        
                    } else if (self.isKindOfClass(SessionClientViewController) == true){
                        
                    } else {
                        self.tabBarController?.selectedIndex = 1
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_3 {
                    if (self.isKindOfClass(MessageViewController) == true ){
                        
                    } else {
                        self.tabBarController?.selectedIndex = 3
                    }
                } else if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_4 {
                    if (self.isKindOfClass(FeaturedViewController) == true ){
                        
                    } else {
                        self.tabBarController?.selectedIndex = 0
                    }
                }  else if moveScreenType == k_PM_MOVE_SCREEN_NOTI_FEED {
                    if (self.isKindOfClass(FeaturedViewController) == true ){
                        
                    } else {
                        self.tabBarController?.selectedIndex = 0
                    }
                }  else if moveScreenType == k_PM_MOVE_SCREEN_NOTI_NEW_LEAD {
                    if (self.isKindOfClass(FindViewController) == true) {
                        
                    } else {
                        self.tabBarController?.selectedIndex = 2
                    }
                }  else if moveScreenType == k_PM_MOVE_SCREEN_NOTI_NEW_MESSAGE {
                    if (self.isKindOfClass(MessageViewController) == true ){
                        
                    } else {
                        self.tabBarController?.selectedIndex = 3
                    }
                }  else if moveScreenType == k_PM_MOVE_SCREEN_NOTI_INCOMING_SESSION {
                    if (self.isKindOfClass(ProgressViewController) == true) {
                        
                    } else if (self.isKindOfClass(LogSessionClientViewController) == true) {
                        
                    } else if (self.isKindOfClass(SessionCoachViewController) == true) {
                        
                    } else if (self.isKindOfClass(SessionClientViewController) == true){
                        
                    } else {
                        self.tabBarController?.selectedIndex = 1
                    }
                }
                
                else {
                    defaults.setObject(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
                }
            }
        } else {
            defaults.setObject(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        }
    }

    
}
