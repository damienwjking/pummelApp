//
//  SigninViewController.swift
//  pummel
//
//  Created by Bear Daddy on 4/12/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class SigninViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet var emailTF : UITextField!
    @IBOutlet var passwordTF : UITextField!
    @IBOutlet var forgotPasswordBT : UIButton!
    @IBOutlet var signinBT : UIButton!
    @IBOutlet var signinDistantCT: NSLayoutConstraint!
    
    var FBButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        self.emailTF.font = .pmmMonReg13()
        self.emailTF.autocorrectionType = UITextAutocorrectionType.No

        self.passwordTF.font = .pmmMonReg13()
        self.emailTF.attributedPlaceholder = NSAttributedString(string:"EMAIL",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.passwordTF.attributedPlaceholder = NSAttributedString(string:"PASSWORD",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        
        self.forgotPasswordBT.titleLabel?.font = .pmmMonReg13()
        self.signinBT.layer.cornerRadius = 2
        self.signinBT.layer.borderWidth = 0.5
        self.signinBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.signinBT.titleLabel?.font = .pmmMonReg13()
        self.emailTF.keyboardAppearance = .Dark
        self.passwordTF.keyboardAppearance = .Dark
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var fbButtonFrame = self.signinBT.frame
        fbButtonFrame.origin.y = self.signinBT.frame.origin.y + self.signinBT.frame.size.height + 30
        
        self.FBButton.frame = fbButtonFrame
        self.FBButton.delegate = self
        self.FBButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.FBButton.loginBehavior = .SystemAccount
        self.scrollView.addSubview(self.FBButton)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}


extension SigninViewController: FBSDKLoginButtonDelegate {
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("declined: \(result.declinedPermissions)")
        print("granted:  \(result.grantedPermissions)")
        print("isCan:    \(result.isCancelled)")
        print("token:    \(result.token)")
        
        if ((error) != nil) {
            print("error: ", error)
        } else if result.isCancelled {
            print("login facebook cancel")
        } else {
            print("login success")
            
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,email,gender,birthday,cover,picture.type(large)"], tokenString: FBSDKAccessToken.currentAccessToken().tokenString, version: nil, HTTPMethod: "GET")
            req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
                if(error == nil) {
                    let fbData = result as! NSDictionary
                    
                    let fbID = fbData["id"] as? String
                    let email = fbData["email"] as? String
                    let firstName = fbData["first_name"] as? String
                    let lastName = fbData["last_name"] as? String
                    
                    var gender = fbData["gender"] as? String
                    if (gender != nil) {
                        gender = gender?.capitalizedString
                    }
                    
                    var pictureURL = ""
                    let picture = fbData["picture"] as? NSDictionary
                    if (picture != nil) {
                        let pictureData = picture!["data"] as! NSDictionary
                        pictureURL = pictureData["url"] as! String
                    }
                    
                    UserRouter.authenticateFacebook(fbID: fbID, email: email, firstName: firstName, lastName: lastName, avatarURL: pictureURL, gender: gender, completed: { (result, error) in
                        if (error == nil) {
                            let successLogin = result as! Bool
                            
                            if (successLogin == true) {
                                NSNotificationCenter.defaultCenter().postNotificationName("LOGINFACEBOOKSUCCESS", object: nil)
                            }
                        } else {
                            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                            loginManager.logOut()
                            
                            print("Request failed with error: \(error)")
                        }
                    }).fetchdata()
                } else {
                    print("error \(error)")
                }
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
}
