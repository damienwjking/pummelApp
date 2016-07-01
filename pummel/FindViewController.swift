//
//  Find.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
// Find an expert view


import UIKit


class FindViewController: UIViewController {
    var showLetUsHelp: Bool!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLetUsHelp = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.title = "FIND"
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        let selectedImage = UIImage(named: "search")
        self.tabBarItem.image = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        if(showLetUsHelp == true) {
            performSegueWithIdentifier("letUsHelp", sender: nil)
        }
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"REFIND", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FindViewController.refind))
         self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "letUsHelp")
        {
        }
    }

    func refind() {
          performSegueWithIdentifier("letUsHelp", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}