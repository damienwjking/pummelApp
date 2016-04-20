//
//  GetStartedViewController.swift
//  pummel
//
//  Created by Damien King on 29/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class GetStartedViewController: UIViewController {

    @IBOutlet var betterTogetherTF : UILabel!
    @IBOutlet var reachYourGoalsTF : UILabel!
    @IBOutlet var imNewBT : UIButton!
    @IBOutlet var getStartedBT : UIButton!
    @IBOutlet var backgroundV : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBarHidden = true
        self.backgroundV.backgroundColor = UIColor(white: 32.0/255.0, alpha: 0.7)
        
        self.betterTogetherTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 42)
        self.reachYourGoalsTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 15)
        
        self.getStartedBT.layer.cornerRadius = 2
        self.getStartedBT.layer.borderWidth = 0.5
        self.getStartedBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.getStartedBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 13)
        
        self.imNewBT.layer.cornerRadius = 2
        self.imNewBT.layer.borderWidth = 0.5
        self.imNewBT.layer.borderColor = UIColor(red:1, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0).CGColor
        self.imNewBT.layer.backgroundColor = UIColor(red:1, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0).CGColor
        self.imNewBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 13)
    }
    
    // Button Action
    @IBAction func gotSignin(sender:UIButton!) {
        performSegueWithIdentifier("toSignin", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toSignin")
        {
            let destinationVC = segue.destinationViewController as! LoginAndRegisterViewController
            destinationVC.isShowLogin = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}