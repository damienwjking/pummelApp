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
        UserRouter.getCurrentUserInfo { (result, error) in
            if (error == nil) {
                let userDetail = result as! NSDictionary
                
                let mNotiNumber = userDetail["messageNotification"] as? Int
                let sNotiNumber = userDetail["sessionNotification"] as? Int
                
                var totalBadge = 0
                // Set message number
                if (mNotiNumber != nil && mNotiNumber > 0) {
                    let messageTabItem = self.tabBarController?.tabBar.items![3]
                    messageTabItem?.badgeValue = String(format: "%d", mNotiNumber!)
                    
                    totalBadge = totalBadge + mNotiNumber!
                }
                
                // Set session number
                if (sNotiNumber != nil && sNotiNumber > 0) {
                    let sessionTabItem = self.tabBarController?.tabBar.items![1]
                    sessionTabItem?.badgeValue = String(format: "%d", sNotiNumber!)
                    
                    totalBadge = totalBadge + sNotiNumber!
                }
                
                // Set app badge number
                if (totalBadge > 0) {
                    UIApplication.sharedApplication().applicationIconBadgeNumber = totalBadge
                }
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: k_PM_MOVE_SCREEN_NOTIFICATION, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    if (self.isKindOfClass(SessionsViewController) == true ){
                        
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
                    if (self.isKindOfClass(SessionsViewController) == true ){
                        
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
