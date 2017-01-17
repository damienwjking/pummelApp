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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touch3DMovePage() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(k_PM_3D_TOUCH) != nil) {
            let touch3DType = defaults.objectForKey(k_PM_3D_TOUCH) as! String
            
            if touch3DType == "1" {
                self.tabBarController?.selectedIndex = 2
            } else if touch3DType == "2" {
                self.tabBarController?.selectedIndex = 1
            } else if touch3DType == "3" {
                self.tabBarController?.selectedIndex = 3
            } else if touch3DType == "4" {
                
            }
        } else {
            defaults.setObject("0", forKey: k_PM_3D_TOUCH)
        }
    }

}
