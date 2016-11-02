//
//  BaseTabBarController.swift
//  pummel
//
//  Created by Bear Daddy on 6/2/16.
//  Copyright © 2016 pummel. All rights reserved.
//
import UIKit

class BaseTabBarController: UITabBarController {
    
    @IBInspectable var defaultIndex: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BaseTabBarController.showBadgeForMessage), name: k_PM_SHOW_BADGE, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func showBadgeForMessage() {
        let tabarItem = self.tabBar.items![3]
        tabarItem.badgeValue = String(UIApplication.sharedApplication().applicationIconBadgeNumber)
        
    }
}
