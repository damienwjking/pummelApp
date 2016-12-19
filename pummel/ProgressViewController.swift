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
        self.navigationController?.navigationBar.userInteractionEnabled = true
        
        let selectedImage = UIImage(named: "sessionsPressed")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
            //TODO: ADD Book Button As Right Navigationbar Item
            self.tabBarController?.navigationItem.rightBarButtonItem?.title = kBook
            self.tabBarController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmWarmGreyColor()], forState: .Normal)
            self.tabBarController?.navigationItem.rightBarButtonItem?.addAction({ (_) in
                self.logButtonClicked()
            })
            
            // TODO: ADD Log Button As Left Navigationbar Item
            self.tabBarController?.navigationItem.leftBarButtonItem?.title = kLog
            self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmWarmGreyColor()], forState: .Normal)
            self.tabBarController?.navigationItem.leftBarButtonItem?.addAction({ (_) in
                self.logButtonClicked()
            })
            
            
            let sessionCoachVC = UIStoryboard(name: "Session", bundle: nil).instantiateViewControllerWithIdentifier("SessionCoachViewController")
            self.addChildViewController(sessionCoachVC)
            self.view.addSubview(sessionCoachVC.view)
        } else {
            self.tabBarController?.navigationItem.leftBarButtonItem = nil
            
            //TODO: ADD Log Button As Right Navigationbar Item
            self.tabBarController?.navigationItem.rightBarButtonItem?.title = kLog
            self.tabBarController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmWarmGreyColor()], forState: .Normal)
            self.tabBarController?.navigationItem.rightBarButtonItem?.addAction({ (_) in
                self.logButtonClicked()
            })
            
            let sessionCLientVC = UIStoryboard(name: "Session", bundle: nil).instantiateViewControllerWithIdentifier("SessionClientViewController")
            self.addChildViewController(sessionCLientVC)
            self.view.addSubview(sessionCLientVC.view)
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - Public function
    func bookButtonClicked() {
        print("book clicked")
        
    }
    
    func logButtonClicked() {
        print("log clicked")
        
    }

}
