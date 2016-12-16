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
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BaseTabBarController.showBadgeForMessage), name: k_PM_SHOW_BADGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BaseTabBarController.selectedNotification), name: k_PM_SELECTED_NOTIFI, object: nil)
        self.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func showBadgeForMessage() {
        if (UIApplication.sharedApplication().applicationIconBadgeNumber != 0) {
             let tabarItem = self.tabBar.items![3]
             tabarItem.badgeValue = String(UIApplication.sharedApplication().applicationIconBadgeNumber)
            if selectedIndex == 3 {
                NSNotificationCenter.defaultCenter().postNotificationName(k_PM_REFRESH_MESSAGE, object: nil)
            }
        }
    }
    
    func selectedNotification() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        let tabarItem = self.tabBar.items![3]
        tabarItem.badgeValue = nil
        if selectedIndex == 3 {
            NSNotificationCenter.defaultCenter().postNotificationName(k_PM_REFRESH_MESSAGE, object: nil)
        } else {
            selectedIndex = 3
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        var properties = ["Category": "IOS.Tabbar", "Name": "Navigation Click", "Label":"ProfileTabbar"]
        
        switch self.selectedIndex {
        case 0:
            properties = ["Category": "IOS.Tabbar", "Name": "Navigation Click", "Label":"FeedTabbar"]
            break
        case 1:
            properties = ["Category": "IOS.Tabbar", "Name": "Navigation Click", "Label":"SessionTabbar"]
            break
        case 2:
            properties = ["Category": "IOS.Tabbar", "Name": "Navigation Click", "Label":"SearchTabbar"]
            break
        case 3:
            properties = ["Category": "IOS.Tabbar", "Name": "Navigation Click", "Label":"MessageTabbar"]
            break
        default:
            break
        }
        
        mixpanel.track("Event", properties: properties)
    }
}
