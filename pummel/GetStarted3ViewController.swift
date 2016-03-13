//
//  GetStarted3ViewController.swift
//  pummel
//
//  Created by Damien King on 13/03/2016.
//  Copyright © 2016 pummel. All rights reserved.
//


import UIKit

class GetStarted3ViewController: UIViewController {
    
        override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide back button word\
        self.navigationController?.navigationBarHidden = false
        
        // set background image
        /*
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "getStarted2")
        self.view.insertSubview(backgroundImage, atIndex:0)
        */
        self.view.backgroundColor = UIColor.redColor()
        
        
        
        // create getStarted Button
        let getStarted2:UIButton = UIButton(frame: CGRectMake(10, 600, 380, 50))
        let buttoncolour = UIColor(red:0.75, green:0.84, blue:0.83, alpha:1.0)
        
        getStarted2.backgroundColor = buttoncolour
        getStarted2.setTitle("NICE, LETS DO IT", forState: UIControlState.Normal)
        getStarted2.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        getStarted2.tag = 02;
        self.view.addSubview(getStarted2)
        
        
    }
    
    
    // Button Action
    
    func buttonAction(sender:UIButton!) {
        
        let btnsendtag:UIButton = sender
        
        if btnsendtag.tag == 02 {
            
            //button pushed.
            
            performSegueWithIdentifier("getStarted3Segue", sender: nil)
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
