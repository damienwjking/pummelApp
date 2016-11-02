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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.title = kNavSession
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let selectedImage = UIImage(named: "sessionsPressed")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.comingSoonTF.font = .pmmPlayFairReg33()
        self.comingSoonDetailTF.font = .pmmPlayFairReg15()
        self.comingSoonDetailTF.layer.opacity = 0.69
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
