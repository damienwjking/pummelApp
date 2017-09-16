//
//  SignupViewController.swift
//  pummel
//
//  Created by Bear Daddy on 4/12/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var nameTF : UITextField!
    @IBOutlet var emailTF : UITextField!
    @IBOutlet var passwordTF : UITextField!
    @IBOutlet var genderTF : UITextField!
    @IBOutlet var signupBT : UIButton!
    @IBOutlet var continuingLB : UILabel!
    @IBOutlet var signinDistantCT: NSLayoutConstraint!
//    @IBOutlet var scrollViewHeightCT: NSLayoutConstraint!
    @IBOutlet var passwordAttentionIM: UIImageView!
    @IBOutlet var emailAttentionIM: UIImageView!
    @IBOutlet weak var termOfServiceBT: UIButton!
    @IBOutlet weak var andLB: UILabel!
    @IBOutlet weak var privacyPolicyBT: UIButton!
    
    var FBButton = FBSDKLoginButton()
    
    @IBAction func termOfService(sender: AnyObject) {
        let termOfServiceURL = NSURL(string: "http://pummel.fit/terms/")
        UIApplication.sharedApplication().openURL(termOfServiceURL!)
    }
    
    @IBAction func privacyPolicy(sender: AnyObject) {
        let privacyPolicyURL = NSURL(string: "http://pummel.fit/privacy/")
        UIApplication.sharedApplication().openURL(privacyPolicyURL!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTF.font = .pmmMonReg13()
        self.nameTF.autocorrectionType = UITextAutocorrectionType.No
        self.emailTF.font = .pmmMonReg13()
        self.emailTF.autocorrectionType = UITextAutocorrectionType.No
        self.passwordTF.font = .pmmMonReg13()
        self.genderTF.font = .pmmMonReg13()
        self.continuingLB.font = .pmmMonReg9()
        self.termOfServiceBT.titleLabel!.font = .pmmMonReg9()
        self.andLB.font = .pmmMonReg9()
        self.privacyPolicyBT.titleLabel!.font = .pmmMonReg9()
        
        self.termOfServiceBT.setTitleColor(UIColor.pmmBrightOrangeColor(), forState: .Normal)
        self.privacyPolicyBT.setTitleColor(UIColor.pmmBrightOrangeColor(), forState: .Normal)
        
       
        self.nameTF.attributedPlaceholder = NSAttributedString(string:"NAME",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.emailTF.attributedPlaceholder = NSAttributedString(string:"EMAIL",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.passwordTF.attributedPlaceholder = NSAttributedString(string:"PASSWORD",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.genderTF.attributedPlaceholder = NSAttributedString(string:"GENDER",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        
        self.signupBT.layer.cornerRadius = 2
        self.signupBT.layer.borderWidth = 0.5
        self.signupBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.signupBT.titleLabel?.font = .pmmMonReg13()
        
        self.passwordAttentionIM.hidden = true
        self.emailAttentionIM.hidden = true

        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(SignupViewController.dismissKeyboard)))
        self.scrollView.userInteractionEnabled = true
        self.scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        self.nameTF.keyboardAppearance = .Dark
        self.passwordTF.keyboardAppearance = .Dark
        self.emailTF.keyboardAppearance = .Dark
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var fbButtonFrame = self.signupBT.frame
        fbButtonFrame.origin.y = self.signupBT.frame.origin.y + self.signupBT.frame.size.height + 30
        
        self.FBButton.frame = fbButtonFrame
        self.FBButton.delegate = self
        self.FBButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.FBButton.loginBehavior = .SystemAccount
        self.scrollView.addSubview(self.FBButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(self.emailTF) == true {
            if (self.isValidEmail(self.emailTF.text!) == false) {
                self.emailAttentionIM.hidden = false
                self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
            } else {
                self.emailAttentionIM.hidden = true
                self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
            }
        }
        if textField.isEqual(self.passwordTF) == true {
            // TODO: Show left icon
            if (self.passwordTF.text?.characters.count < 8) {
                self.passwordAttentionIM.hidden = false
                self.passwordTF.attributedText = NSAttributedString(string:self.passwordTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
                let alertController = UIAlertController(title: pmmNotice, message: passwordNotice, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
                
            } else {
                self.passwordAttentionIM.hidden = true
                self.passwordTF.attributedText = NSAttributedString(string:self.passwordTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.isEqual(self.genderTF) == true {
            self.showPopupToSelectGender()
            return false
        } else {
            return true
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", kEmailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func showPopupToSelectGender() {
        self.emailTF.resignFirstResponder()
        self.passwordTF.resignFirstResponder()
        self.nameTF.resignFirstResponder()
        let selectMale = { (action:UIAlertAction!) -> Void in
            self.genderTF.text = kMALEU
        }
        let selectFemale = { (action:UIAlertAction!) -> Void in
            self.genderTF.text = kFemaleU
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kMALEU, style: UIAlertActionStyle.Default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: kFemaleU, style: UIAlertActionStyle.Default, handler: selectFemale))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func dismissKeyboard() {
        
    }
}

extension SignupViewController : FBSDKLoginButtonDelegate {
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
