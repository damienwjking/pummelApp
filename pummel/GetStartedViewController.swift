
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.signinNotification), name: k_PM_MOVE_SCREEN_NOTIFICATION, object: nil)
    }
    
    func signinNotification() {
        self.navigationController?.popToRootViewControllerAnimated(true)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let moveScreenType = userDefaults.objectForKey(k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_LOGIN {
            userDefaults.setObject(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
            userDefaults.synchronize()
            
            self.gotSignin(UIButton()) // UIButton : to call function
        }
    }
    
    // Button Action
    @IBAction func gotSignin(sender:UIButton!) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: k_PM_MOVE_SCREEN_NOTIFICATION, object: nil)
        
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
}
