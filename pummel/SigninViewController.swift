//
//  SigninViewController.swift
//  pummel
//
//  Created by Bear Daddy on 4/12/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Mixpanel
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
    
    @IBOutlet weak var spaceViewHeightConstraint: NSLayoutConstraint!
    
    var FBButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var fbButtonFrame = self.signinBT.frame
        fbButtonFrame.origin.y = self.signinBT.frame.origin.y + self.signinBT.frame.size.height + 20
        
        self.FBButton.frame = fbButtonFrame
        self.FBButton.delegate = self
        self.FBButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.FBButton.loginBehavior = .systemAccount
        self.scrollView.addSubview(self.FBButton)
    }
    
    func setupUI() {
        self.setNeedsStatusBarAppearanceUpdate()
        self.emailTF.autocorrectionType = UITextAutocorrectionType.no
        
        self.emailTF.attributedPlaceholder = NSAttributedString(string:"EMAIL",
                                                                attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.passwordTF.attributedPlaceholder = NSAttributedString(string:"PASSWORD",
                                                                   attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        
        self.forgotPasswordBT.titleLabel?.font = .pmmMonReg13()
        self.signinBT.layer.cornerRadius = 2
        self.signinBT.layer.borderWidth = 0.5
        self.signinBT.layer.borderColor = UIColor.white.cgColor
        self.signinBT.titleLabel?.font = .pmmMonReg13()
        self.emailTF.keyboardAppearance = .dark
        self.passwordTF.keyboardAppearance = .dark
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard(sender:)))
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func dissmissKeyboard(sender: Any) {
        self.emailTF.resignFirstResponder()
        self.passwordTF.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            self.spaceViewHeightConstraint.constant = keyboardSize.height
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        self.spaceViewHeightConstraint.constant = 0
    }
    
    @IBAction func forgotPasswordButtonClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FORGOTPASSWORDNOTIFICATION"), object: nil)
    }
    
    @IBAction func signinButtonClicked(_ sender: Any) {
        let userEmail = self.emailTF.text!
        let userPassword = self.passwordTF.text!
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Login"]
        mixpanel?.track("IOS.Login", properties: properties)
        
        self.view.makeToastActivity(message: "Loading")
        UserRouter.login(email: userEmail, password: userPassword) { (result, error) in
            self.view.hideToastActivity()
            
            let loginSuccess = result as! Bool
            if (loginSuccess == true) {
                self.emailTF.text = ""
                self.passwordTF.text = ""
                
                UserDefaults.standard.set(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LOGINSUCCESSNOTIFICATION"), object: nil)
                FBSDKAppEvents.logEvent("Login")
            } else {
                PMHelper.showNoticeAlert(message: signInNotice)
            }
        }.fetchdata()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.emailTF) {
            self.passwordTF.becomeFirstResponder()
        } else if (textField == self.passwordTF) {
            self.signinBT.sendActions(for: .touchUpInside)
        }
        
        return true
    }
}


extension SigninViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
            print("error: ", error)
        } else if result.isCancelled {
            print("login facebook cancel")
        } else {
            print("login success")
            
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,email,gender,birthday,cover,picture.type(large)"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET")
            
            // For warning
            let _ = req?.start(completionHandler: { (connection, result, error) in
                if(error == nil) {
                    let fbData = result as! NSDictionary
                    
                    let fbID = fbData["id"] as? String
                    let email = fbData["email"] as? String
                    let firstName = fbData["first_name"] as? String
                    let lastName = fbData["last_name"] as? String
                    
                    var gender = fbData["gender"] as? String
                    if (gender != nil) {
                        gender = gender?.capitalized
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
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LOGINSUCCESSNOTIFICATION"), object: nil)
                            }
                        } else {
                            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                            loginManager.logOut()
                            
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }).fetchdata()
                } else {
                    print("error \(String(describing: error))")
                }
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}
