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
    }
}
