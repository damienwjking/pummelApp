//
//  SessionCoachViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation


class SessionCoachViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: ADD Log Button At Left Navigationbar Item
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title:kLog, style:.Plain, target: self, action: #selector(SessionCoachViewController.logButtonClicked))
        self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState:.Normal)
        
        
        //TODO: ADD Book Button At Right Navigationbar Item
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kBook, style:.Plain, target: self, action: #selector(SessionCoachViewController.bookButtonClicked))
        self.tabBarController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState:.Normal)
    }
    
    
    // MARK: Public function
    func bookButtonClicked() {
        print("book clicked")
        self.performSegueWithIdentifier("coachMakeABook", sender: nil)
        
    }
    
    func logButtonClicked() {
        print("log clicked")
        self.performSegueWithIdentifier("coachLogASession", sender: nil)
    }
}
