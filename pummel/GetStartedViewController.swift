
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
        self.navigationController?.isNavigationBarHidden = true
        self.backgroundV.backgroundColor = .pmmWhite07Color()
        
        self.betterTogetherTF.font = .pmmPlayFairReg42()
        self.reachYourGoalsTF.font = .pmmPlayFairReg15()
        
        self.getStartedBT.layer.cornerRadius = 2
        self.getStartedBT.layer.borderWidth = 0.5
        self.getStartedBT.layer.borderColor = UIColor.white.cgColor
        self.getStartedBT.titleLabel?.font = .pmmMonReg13()
        
        self.imNewBT.layer.cornerRadius = 2
        self.imNewBT.layer.borderWidth = 0.5
        self.imNewBT.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
        self.imNewBT.layer.backgroundColor = UIColor.pmmBrightOrangeColor().cgColor
        self.imNewBT.titleLabel?.font = .pmmMonReg13()
        
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: k_PM_IS_LOGINED) == nil) {
            // Do Nothing
        } else if  (defaults.object(forKey: k_PM_IS_LOGINED) as! Bool) {
            let urlString = defaults.object(forKey: k_PM_URL_LAST_COOKIE)
            let url = NSURL(string: urlString as! String)
            let headerFields = defaults.object(forKey: k_PM_HEADER_FILEDS) as! [String : String]
            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url!)
            Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: url!, mainDocumentURL: nil)
            performSegue(withIdentifier: "showClientWithoutLogin", sender: nil)
        } else {
            performSegue(withIdentifier: "toSignin", sender: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated: animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.signinNotification), name: k_PM_MOVE_SCREEN_NOTIFICATION, object: nil)
    }
    
    func signinNotification() {
        self.navigationController?.popToRootViewController(animated: true)
        
        let userDefaults = UserDefaults.standard
        let moveScreenType = userDefaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_LOGIN {
            userdefaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
            userDefaults.synchronize()
            
            self.gotSignin(UIButton()) // UIButton : to call function
        }
    }
    
    // Button Action
    @IBAction func gotSignin(sender:UIButton!) {
        NotificationCenter.default.removeObserver(self, name: k_PM_MOVE_SCREEN_NOTIFICATION, object: nil)
        
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: k_PM_IS_LOGINED) == nil) {
            performSegue(withIdentifier: "toSignin", sender: nil)
        } else if  (defaults.object(forKey: k_PM_IS_LOGINED) as! Bool) {
            let urlString = defaults.object(forKey: k_PM_URL_LAST_COOKIE)
            let url = NSURL(string: urlString as! String)
            let headerFields = defaults.object(forKey: k_PM_HEADER_FILEDS) as! [String : String]
            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url!)
            Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: url!, mainDocumentURL: nil)
            performSegue(withIdentifier: "showClientWithoutLogin", sender: nil)
        } else {
            performSegue(withIdentifier: "toSignin", sender: nil)
        }
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toSignin") {
            let destinationVC = segue.destination as! LoginAndRegisterViewController
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
