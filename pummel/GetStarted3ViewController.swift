//
//  GetStarted3ViewController.swift
//  pummel
//
//  Created by Damien King on 13/03/2016.
//  Copyright © 2016 pummel. All rights reserved.
//


import UIKit

class GetStarted3ViewController: UIViewController {
   
    @IBOutlet var reachTF : UILabel!
    @IBOutlet var shareTF : UILabel!
    @IBOutlet var letSetItBT : UIButton!
    @IBOutlet var backgroundV : UIView!
    @IBOutlet var mainTextDistantCT: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.backgroundV.backgroundColor = UIColor(white: 32.0/255.0, alpha: 0.7)
        self.reachTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 42)
        self.shareTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 15)
        
        self.letSetItBT.layer.cornerRadius = 2
        self.letSetItBT.layer.borderWidth = 0.5
        self.letSetItBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.letSetItBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.updateUI()
    }

    // Button Action
    @IBAction func buttonAction(sender:UIButton!) {
        performSegueWithIdentifier("toRegister", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toRegister")
        {
            let destinationVC = segue.destinationViewController as! LoginAndRegisterViewController
            destinationVC.isShowLogin = false
        }
    }

    @IBAction func backToFirstScreenTour(sender:UIButton!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
        let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
        let SCREEN_MAX_LENGTH    = max(SCREEN_WIDTH, SCREEN_HEIGHT)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
            self.mainTextDistantCT.constant = 40
        }
    }
    
}
