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
        
        let buttonColor = UIColor.hex("FB4311", alpha: 1)
        //TODO: ADD Book Button At Right Navigationbar Item
        let rightButton = UIButton()
        rightButton.titleLabel?.font = .pmmMonReg13()
        rightButton.setTitle(kBook, forState: .Normal)
        rightButton.setTitleColor(buttonColor, forState: .Normal)
        rightButton.addTarget(self, action: #selector(SessionCoachViewController.bookButtonClicked), forControlEvents: .TouchUpInside)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        rightButton.sizeToFit()
        self.tabBarController?.navigationItem.rightBarButtonItem? = rightBarButton
        
        // TODO: ADD Log Button At Left Navigationbar Item
        let leftButton = UIButton()
        leftButton.titleLabel?.font = .pmmMonReg13()
        leftButton.setTitle(kLog, forState: .Normal)
        leftButton.setTitleColor(buttonColor, forState: .Normal)
        leftButton.addTarget(self, action: #selector(SessionCoachViewController.logButtonClicked), forControlEvents: .TouchUpInside)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        leftButton.sizeToFit()
        self.tabBarController?.navigationItem.leftBarButtonItem? = leftBarButton
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
