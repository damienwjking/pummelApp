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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.viewDidAppear(_:)), name: k_PM_3D_TOUCH_NOTIFICATION, object: nil)
        
        self.touch3DMovePage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: k_PM_3D_TOUCH_NOTIFICATION, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touch3DMovePage() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(k_PM_3D_TOUCH) != nil) {
            let touch3DType = defaults.objectForKey(k_PM_3D_TOUCH) as! String
            
            if touch3DType == k_PM_3D_TOUCH_VALUE {
                // Do nothing
            } else {
                if (self.isKindOfClass(LogSessionClientViewController) == false) {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                
                if touch3DType == "3dTouch_1" {
                    if (self.isKindOfClass(FindViewController) == true ||
                        self.isKindOfClass(LetUsHelpViewController) == true){
                        // Do nothing
                    } else {
                        self.tabBarController?.selectedIndex = 2
                    }
                } else if touch3DType == "3dTouch_2" {
                    if (self.isKindOfClass(ProgressViewController) == true) {
                        
                    } else if (self.isKindOfClass(LogSessionClientViewController) == true) {
                        
                    } else if (self.isKindOfClass(SessionCoachViewController) == true) {
                        
                    } else if (self.isKindOfClass(SessionClientViewController) == true){
                        
                    } else {
                        self.tabBarController?.selectedIndex = 1
                    }
                } else if touch3DType == "3dTouch_3" {
                    if (self.isKindOfClass(SessionsViewController) == true ){
                        
                    } else {
                        self.tabBarController?.selectedIndex = 3
                    }
                } else if touch3DType == "3dTouch_4" {
                    if (self.isKindOfClass(FeaturedViewController) == true ){
                        
                    } else {
                        self.tabBarController?.selectedIndex = 0
                    }
                } else {
                    defaults.setObject(k_PM_3D_TOUCH_VALUE, forKey: k_PM_3D_TOUCH)
                }
            }
        } else {
            defaults.setObject(k_PM_3D_TOUCH_VALUE, forKey: k_PM_3D_TOUCH)
        }
    }

    
}