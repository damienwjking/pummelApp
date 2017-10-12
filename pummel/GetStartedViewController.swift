
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
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet var backgroundV : UIView!
    @IBOutlet var mainTextDistantCT: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.isNavigationBarHidden = true
        self.backgroundV.backgroundColor = .pmmWhite07Color()
        
        self.betterTogetherTF.font = .pmmPlayFairReg42()
        self.reachYourGoalsTF.font = .pmmPlayFairReg15()
        
        self.signInButton.layer.cornerRadius = 2
        self.signInButton.layer.borderWidth = 0.5
        self.signInButton.layer.borderColor = UIColor.white.cgColor
        
        self.imNewBT.layer.cornerRadius = 2
        self.imNewBT.layer.borderWidth = 0.5
        self.imNewBT.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
        self.imNewBT.layer.backgroundColor = UIColor.pmmBrightOrangeColor().cgColor
        
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: k_PM_IS_LOGINED) == nil) {
            // Do Nothing
        } else if  (defaults.object(forKey: k_PM_IS_LOGINED) as! Bool) {
            let urlString = defaults.object(forKey: k_PM_URL_LAST_COOKIE)
            let url = NSURL(string: urlString as! String)
            let headerFields = defaults.object(forKey: k_PM_HEADER_FILEDS) as! [String : String]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url! as URL)
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: url! as URL, mainDocumentURL: nil)
            performSegue(withIdentifier: "showClientWithoutLogin", sender: nil)
        } else {
            performSegue(withIdentifier: "toSignin", sender: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.signinNotification), name: NSNotification.Name(rawValue: k_PM_MOVE_SCREEN_NOTIFICATION), object: nil)
    }
    
    func signinNotification() {
        self.navigationController?.popToRootViewController(animated: true)
        
        let userDefaults = UserDefaults.standard
        let moveScreenType = userDefaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_LOGIN {
            userDefaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
            userDefaults.synchronize()
            
            self.signInButton.sendActions(for: .touchUpInside)
        }
    }
    
    // Button Action
    @IBAction func signInButtonClicked(_ sender: Any) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: k_PM_MOVE_SCREEN_NOTIFICATION), object: nil)
        
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: k_PM_IS_LOGINED) == nil) {
            performSegue(withIdentifier: "toSignin", sender: nil)
        } else if  (defaults.object(forKey: k_PM_IS_LOGINED) as! Bool) {
            let urlString = defaults.object(forKey: k_PM_URL_LAST_COOKIE)
            let url = NSURL(string: urlString as! String)
            let headerFields = defaults.object(forKey: k_PM_HEADER_FILEDS) as! [String : String]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url! as URL)
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: url! as URL, mainDocumentURL: nil)
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
            let application = UIApplication.shared
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
