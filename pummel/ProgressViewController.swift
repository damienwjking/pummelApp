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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.title = "SESSIONS"
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        let selectedImage = UIImage(named: "sessionsPressed")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        self.comingSoonTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 33)
        self.comingSoonDetailTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 15)
        self.comingSoonDetailTF.layer.opacity = 0.69
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}