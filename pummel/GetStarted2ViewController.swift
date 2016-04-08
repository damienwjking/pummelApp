//
//  GetStarted2ViewController.swift
//  pummel
//
//  Created by Damien King on 29/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//


import UIKit

class GetStarted2ViewController: UIViewController {
    
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
        self.view.backgroundColor = UIColor.grayColor()
            
            
        
        // create getStarted Button
        let getStarted:UIButton = UIButton(frame: CGRectMake(10, 600, 380, 50))
        let buttoncolour = UIColor(red:0.75, green:0.84, blue:0.83, alpha:1.0)
        
        getStarted.backgroundColor = buttoncolour
        getStarted.setTitle("COOL, SHOW ME MORE", forState: UIControlState.Normal)
        getStarted.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        getStarted.tag = 01;
        self.view.addSubview(getStarted)
        
        
    }
    
    
    // Button Action
    
    func buttonAction(sender:UIButton!) {
        
        let btnsendtag:UIButton = sender
        
        if btnsendtag.tag == 01 {
            
            //button pushed.
            
            performSegueWithIdentifier("getStarted2Segue", sender: nil)

        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
