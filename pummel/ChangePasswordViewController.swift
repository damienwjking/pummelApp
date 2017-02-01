//
//  ChangePasswordViewController.swift
//  pummel
//
//  Created by Bear Daddy on 2/1/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordViewController : BaseViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kChangePassword
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.translucent = false;
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"DONE", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChangePasswordViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChangePasswordViewController.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
    }
    
    func done() {
        // Check new password & retype new password are the same
        // Call API change password
        // Show Incicator
        // Turn off Indicator
        // Back to settting
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
