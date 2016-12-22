//
//  ProgressViewController.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
// Progress is the view that shows goals and can log progress and activity


import UIKit

class ProgressViewController: UIViewController {
    @IBOutlet var comingSoonTF : UILabel!
    @IBOutlet var comingSoonDetailTF : UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.title = kNavSession
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        let selectedImage = UIImage(named: "sessionsPressed")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
            let sessionCoachVC = UIStoryboard(name: "Session", bundle: nil).instantiateViewControllerWithIdentifier("SessionCoachViewController")
            self.addChildViewController(sessionCoachVC)
            self.view.addSubview(sessionCoachVC.view)
        } else {
            let sessionCLientVC = UIStoryboard(name: "Session", bundle: nil).instantiateViewControllerWithIdentifier("SessionClientViewController")
            self.addChildViewController(sessionCLientVC)
            self.view.addSubview(sessionCLientVC.view)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.title = " "
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
