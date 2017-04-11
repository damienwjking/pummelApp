
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
    @IBOutlet var imNewWidthCT: NSLayoutConstraint!
    @IBOutlet var getStartWidthCT: NSLayoutConstraint!
    @IBOutlet var mainTextDistantCT: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBarHidden = true
        self.backgroundV.backgroundColor = .pmmWhite07Color()
        
        self.betterTogetherTF.font = .pmmPlayFairReg42()
        self.reachYourGoalsTF.font = .pmmPlayFairReg15()
        
        self.getStartedBT.layer.cornerRadius = 2
        self.getStartedBT.layer.borderWidth = 0.5
        self.getStartedBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.getStartedBT.titleLabel?.font = .pmmMonReg13()
        
        self.imNewBT.layer.cornerRadius = 2
        self.imNewBT.layer.borderWidth = 0.5
        self.imNewBT.layer.borderColor = UIColor.pmmBrightOrangeColor().CGColor
        self.imNewBT.layer.backgroundColor = UIColor.pmmBrightOrangeColor().CGColor
        self.imNewBT.titleLabel?.font = .pmmMonReg13()
        
        self.updateUI()
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey(k_PM_IS_LOGINED) == nil) {
            // Do Nothing
        } else if  (defaults.objectForKey(k_PM_IS_LOGINED) as! Bool) {
            let urlString = defaults.objectForKey(k_PM_URL_LAST_COOKIE)
            let url = NSURL(string: urlString as! String)
            let headerFields = defaults.objectForKey(k_PM_HEADER_FILEDS) as! [String : String]
            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url!)
            Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: url!, mainDocumentURL: nil)
            performSegueWithIdentifier("showClientWithoutLogin", sender: nil)
        } else {
            performSegueWithIdentifier("toSignin", sender: nil)
        }
    }
    
    // Button Action
    @IBAction func gotSignin(sender:UIButton!) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey(k_PM_IS_LOGINED) == nil) {
            performSegueWithIdentifier("toSignin", sender: nil)
        } else if  (defaults.objectForKey(k_PM_IS_LOGINED) as! Bool) {
            let urlString = defaults.objectForKey(k_PM_URL_LAST_COOKIE)
            let url = NSURL(string: urlString as! String)
            let headerFields = defaults.objectForKey(k_PM_HEADER_FILEDS) as! [String : String]
            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url!)
            Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: url!, mainDocumentURL: nil)
            performSegueWithIdentifier("showClientWithoutLogin", sender: nil)
        } else {
            performSegueWithIdentifier("toSignin", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toSignin") {
            let destinationVC = segue.destinationViewController as! LoginAndRegisterViewController
            destinationVC.isShowLogin = true
        } else if(segue.identifier == "showClientWithoutLogin") {
            // Send token
            let application = UIApplication.sharedApplication()
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
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
            self.imNewWidthCT.constant = 137.0
            self.getStartWidthCT.constant = 138.0
            self.mainTextDistantCT.constant = 50
        }
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 736.0) {
            self.imNewWidthCT.constant = 180.0
            self.getStartWidthCT.constant = 180.0
            self.mainTextDistantCT.constant = 50
        }
    }
}
