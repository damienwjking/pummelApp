//
//  SignupViewController.swift
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

class SignupViewController: UIViewController {
    
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
    
    @IBOutlet weak var spaceViewHeightConstraint: NSLayoutConstraint!
    
    var FBButton = FBSDKLoginButton()
    let defaults = UserDefaults.standard
    
    @IBAction func termOfService(_ sender: Any) {
        let termOfServiceURL = NSURL(string: "http://pummel.fit/terms/")
        UIApplication.shared.openURL(termOfServiceURL! as URL)
    }
    
    @IBAction func privacyPolicy(_ sender: Any) {
        let privacyPolicyURL = NSURL(string: "http://pummel.fit/privacy/")
        UIApplication.shared.openURL(privacyPolicyURL! as URL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var fbButtonFrame = self.signupBT.frame
        fbButtonFrame.origin.y = self.signupBT.frame.origin.y + self.signupBT.frame.size.height + 20
        
        self.FBButton.frame = fbButtonFrame
        self.FBButton.delegate = self
        self.FBButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.FBButton.loginBehavior = .systemAccount
        self.scrollView.addSubview(self.FBButton)
    }
    
    func setupUI() {
        self.nameTF.autocorrectionType = UITextAutocorrectionType.no
        self.emailTF.autocorrectionType = UITextAutocorrectionType.no
        
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
        self.signupBT.layer.borderColor = UIColor.white.cgColor
        self.signupBT.titleLabel?.font = .pmmMonReg13()
        
        self.passwordAttentionIM.isHidden = true
        self.emailAttentionIM.isHidden = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard(sender:)))
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        self.nameTF.keyboardAppearance = .dark
        self.passwordTF.keyboardAppearance = .dark
        self.emailTF.keyboardAppearance = .dark
    }
    
    func dissmissKeyboard(sender: Any) {
        self.nameTF.resignFirstResponder()
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
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        if (self.checkRuleInputData() == false) {
            let name = self.nameTF.text
            let userEmail = self.emailTF.text
            let userPassword = self.passwordTF.text
            var gender = self.genderTF.text
            
            let fullNameArr = name!.characters.split{$0 == " "}.map(String.init)
            var firstname = ""
            if (fullNameArr.count > 0) {
                firstname = fullNameArr[0]
            }
            
            if (gender == "") {
                gender = kDontCare
            }
            
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Navigation Click", "Label":"Register"]
            mixpanel?.track("IOS.Register", properties: properties)
            
            
            self.view.makeToastActivity(message: "Loading")
            
            UserRouter.signup(firstName: firstname, email: userEmail!, password: userPassword!, gender: gender!, completed: { (result, error) in
                self.view.hideToastActivity()
                
                if (error == nil) {
                    let isSigninSuccess = result as! Bool
                    
                    if (isSigninSuccess == true) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SIGNUPSUCCESSNOTIFICATION"), object: nil)
                    }
                } else {
                    if (error?.code == 400) {
                        let alertController = UIAlertController(title: pmmNotice, message: yourEmailIsNotValid, preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                            self.emailTF.becomeFirstResponder()
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true) {
                            // ...
                        }
                    } else {
                        PMHelper.showDoAgainAlert()
                    }
                }
            }).fetchdata()
        }
    }
    
    func checkRuleInputData() -> Bool {
        var returnValue  = false
        
        if (self.emailTF.text?.isValidEmail() == false) {
            returnValue = true
            self.emailAttentionIM.isHidden = false
            self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            self.emailAttentionIM.isHidden = true
            self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                                                                 attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
        }
        
        if !(self.checkPassword(testStr: self.passwordTF.text!)) {
            returnValue = true
            self.passwordAttentionIM.isHidden = false
            self.passwordTF.attributedText = NSAttributedString(string:self.passwordTF.text!,
                                                                    attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            self.passwordAttentionIM.isHidden = true
            self.passwordTF.attributedText = NSAttributedString(string:self.passwordTF.text!,
                                                                    attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
        }
        
        return returnValue
    }
    
    func checkPassword(testStr:String) -> Bool {
        if (testStr.characters.count < 8) {
            return false
        } else {
            return true
        }
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
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kMALEU, style: .default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: kFemaleU, style: .default, handler: selectFemale))
        
        self.present(alertController, animated: true) { }
    }
}

// MARK: - UITextFieldDelegate
extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let _ = self.checkRuleInputData() // dissmiss warning
        
        if (textField == self.nameTF) {
            self.emailTF.becomeFirstResponder()
        } else if (textField == self.emailTF) {
            self.passwordTF.becomeFirstResponder()
        } else if (textField == self.passwordTF) {
            if ((self.passwordTF.text?.characters.count)! < 8) {
                let alertController = UIAlertController(title: pmmNotice, message: passwordNotice, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true) {
                    // ...
                }
                
            } else {
                self.genderTF.becomeFirstResponder()
            }
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.genderTF) == true {
            self.showPopupToSelectGender()
            return false
        } else {
            return true
        }
    }
}

// MARK: - FBSDKLoginButtonDelegate
extension SignupViewController : FBSDKLoginButtonDelegate {
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
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
