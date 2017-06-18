//
//  BaseTabBarController.swift
//  pummel
//
//  Created by Bear Daddy on 6/2/16.
//  Copyright © 2016 pummel. All rights reserved.
//
import UIKit
import Mixpanel

class BaseTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    @IBInspectable var defaultIndex: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BaseTabBarController.showMessage), name: k_PM_SHOW_LIST_MESSAGE_SCREEN, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BaseTabBarController.showFeed), name: k_PM_SHOW_FEED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BaseTabBarController.showSession), name: k_PM_SHOW_SHOW_SESSIONS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BaseTabBarController.showClients), name: k_PM_SHOW_SHOW_CLIENTS, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BaseTabBarController.showMessageBadge), name: k_PM_SHOW_MESSAGE_BADGE, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BaseTabBarController.showMessageBadgeWithoutRefresh), name: k_PM_SHOW_MESSAGE_BADGE_WITHOUT_REFRESH, object: nil)
        
        self.delegate = self
    }
    
    func showMessage() {
        if selectedIndex == 3 {
            NSNotificationCenter.defaultCenter().postNotificationName(k_PM_REFRESH_MESSAGE, object: nil)
        } else {
            selectedIndex = 3
        }
    }
    
    func showFeed() {
        selectedIndex = 0
    }
    
    func showSession() {
        if selectedIndex == 3 {
            NSNotificationCenter.defaultCenter().postNotificationName(k_PM_REFRESH_SESSION, object: nil)
        } else {
            selectedIndex = 3
        }
    }
    
    func showClients() {
        if selectedIndex == 3 {
            NSNotificationCenter.defaultCenter().postNotificationName(k_PM_REFRESH_CLIENTS, object: nil)
        } else {
            selectedIndex = 3
        }
    }
    
    func showMessageBadge() {
        var badgeV = NSUserDefaults.standardUserDefaults().integerForKey("MESSAGE_BADGE_VALUE")
        badgeV += 1
        NSUserDefaults.standardUserDefaults().setInteger(badgeV, forKey: "MESSAGE_BADGE_VALUE")
        if (badgeV > 0) {
            self.tabBar.items![3].badgeValue = String(badgeV)
        } else {
            self.tabBar.items![3].badgeValue = nil
        }
        
        if (selectedIndex == 3) {
             NSNotificationCenter.defaultCenter().postNotificationName(k_PM_REFRESH_MESSAGE, object: nil)
        }
    }
    
    func showMessageBadgeWithoutRefresh () {
        var badgeV = NSUserDefaults.standardUserDefaults().integerForKey("MESSAGE_BADGE_VALUE")
        badgeV += 1
        NSUserDefaults.standardUserDefaults().setInteger(badgeV, forKey: "MESSAGE_BADGE_VALUE")
        if (badgeV != 0) {
            self.tabBar.items![3].badgeValue = String(badgeV)
        } else {
            self.tabBar.items![3].badgeValue = nil
        }
    }

    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        var properties = ["Name": "Navigation Click", "Label":"ProfileTabbar"]
        
        switch self.selectedIndex {
        case 0:
            properties = ["Name": "Navigation Click", "Label":"FeedTabbar"]
            break
        case 1:
            properties = ["Name": "Navigation Click", "Label":"SessionTabbar"]
            break
        case 2:
            let slectedVC = self.selectedViewController as! FindViewController
            slectedVC.refind()
            properties = ["Name": "Navigation Click", "Label":"SearchTabbar"]
            break
        case 3:
            properties = ["Name": "Navigation Click", "Label":"MessageTabbar"]
            break
        default:
            break
        }
        
        mixpanel.track("IOS.Tabbar", properties: properties)
    }
}
