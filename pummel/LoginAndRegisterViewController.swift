//
//  LoginAndRegisterViewController.swift
//  pummel
//
//  Created by Bear Daddy on 4/12/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import Mixpanel
import FBSDKCoreKit

class LoginAndRegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var loginVC : SigninViewController = SigninViewController(nibName: "SigninViewController", bundle: nil)
    var signupVC : SignupViewController = SignupViewController(nibName: "SignupViewController", bundle: nil)
    var isShowLogin : Bool!
    
    @IBOutlet var loginUnderLineV: UIView!
    @IBOutlet var resigterUnderLineV: UIView!
    @IBOutlet var loginRegisterUnderLineV: UIView!
    @IBOutlet var loginBT : UIButton!
    @IBOutlet var signupBT : UIButton!
    @IBOutlet var logoIMV: UIImageView!
    @IBOutlet var profileIMV: UIImageView!
    @IBOutlet var addProfileIMV : UIImageView!
    @IBOutlet var addProfileIconIMV : UIImageView!
    @IBOutlet var cameraProfileIconIMV : UIImageView!
    @IBOutlet var addProfilePhototLB : UILabel!
    var imageData : NSData!
    var type : String!
    var filename: String!
    let imagePicker = UIImagePickerController()
    let defaults = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hidden navigation bar
        self.navigationController?.navigationBar.hidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        loginBT.titleLabel?.font = .pmmMonReg13()
        signupBT.titleLabel?.font = .pmmMonReg13()
        addProfilePhototLB.font = .pmmMonReg10()
        
        // Add loginVC
        self.addChildViewController(loginVC)
        loginVC.didMoveToParentViewController(self)
        loginVC.view.frame = CGRectMake(0, 251, self.view.frame.size.width, loginVC.view.frame.size.height)
        loginVC.forgotPasswordBT.addTarget(self, action:#selector(LoginAndRegisterViewController.forgotAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        loginVC.signinBT.addTarget(self, action:#selector(LoginAndRegisterViewController.clickSigninAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginVC.view)

        // Add registerVC and hidden it for initial
        self.addChildViewController(signupVC)
        signupVC.didMoveToParentViewController(self)
        signupVC.view.frame = CGRectMake(0, 251, self.view.frame.size.width, signupVC.view.frame.size.height)
        signupVC.signupBT.addTarget(self, action:#selector(LoginAndRegisterViewController.clickSignupAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        self.view.addSubview(signupVC.view)
        
        self.updateUI()
        self.profileIMV.layer.cornerRadius = 45
        self.addProfileIMV.layer.cornerRadius = 15
        self.addProfileIMV.clipsToBounds = true
        profileIMV.clipsToBounds = true
        imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(LoginAndRegisterViewController.imageTapped)))
        self.addProfileIMV.userInteractionEnabled = true
        self.addProfileIMV.addGestureRecognizer(tapGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginAndRegisterViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginAndRegisterViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loginFacebookSuccess), name: "LOGINFACEBOOKSUCCESS", object: nil)
    }
    
    func loginFacebookSuccess() {
        self.performSegueWithIdentifier("showClientSegue", sender: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
   
    @IBAction func backAction(sender:UIButton!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func loginAction(sender:UIButton!) {
        self.isShowLogin = true
        self.updateUI()
    }
    
    @IBAction func signupAction(sender:UIButton!) {
        self.isShowLogin = false
        self.updateUI()
    }
    
    func updateUI() {
        if (self.isShowLogin == false) {
            loginVC.view.hidden = true
            signupVC.view.hidden = false
            self.loginUnderLineV.hidden = true
            self.resigterUnderLineV.hidden = false
            self.addProfilePhototLB.hidden = false
            self.profileIMV.hidden = true
            self.logoIMV.hidden = false
            self.profileIMV.hidden = false
            self.logoIMV.hidden = true
            self.addProfileIMV.hidden = false
            self.addProfileIconIMV.hidden = false
            self.cameraProfileIconIMV.hidden = false
        } else {
            signupVC.view.hidden = true
            loginVC.view.hidden = false
            self.resigterUnderLineV.hidden = true
            self.loginUnderLineV.hidden = false
            self.addProfilePhototLB.hidden = true
            self.profileIMV.hidden = true
            self.logoIMV.hidden = false
            self.addProfileIMV.hidden = true
            self.addProfileIconIMV.hidden = true
            self.cameraProfileIconIMV.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // forgotten Password
    @IBAction func forgotAction(sender:UIButton!) {
        performSegueWithIdentifier("forgottenPasswordSegue", sender: nil)
    }
    
    @IBAction func clickSigninAction(sender:UIButton!) {
        let userEmail = self.loginVC.emailTF.text!
        let userPassword = self.loginVC.passwordTF.text!
        self.view.makeToastActivity(message: "Loading")
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Login"]
        mixpanel.track("IOS.Login", properties: properties)
        
        Alamofire.request(.POST, kPMAPI_LOGIN, parameters: [kEmail:userEmail, kPassword:userPassword])
            .responseJSON { response in
                self.view.hideToastActivity()
                
                if response.response?.statusCode == 200 {
                    let JSON = response.result.value
        
                    UserRouter.saveCurrentUserInfo(response)
                    let currentId = String(format:"%0.f",JSON!.objectForKey(kUserId)!.doubleValue)
                    
                    let mixpanel = Mixpanel.sharedInstance()
                    if mixpanel.distinctId != "" {
                        mixpanel.identify(currentId)
                    } else {
                        mixpanel.createAlias(currentId, forDistinctID: mixpanel.distinctId)
                        mixpanel.identify(mixpanel.distinctId)
                    }
                    
                    if let userinfo = JSON!.objectForKey("user") as? NSDictionary {
                        if let nameUser = userinfo.objectForKey(kFirstname) as? String {
                            mixpanel.people.set("$name", to: nameUser)
                        }
                        
                        if let mailUser = userinfo[kEmail] as? String {
                            mixpanel.people.set("$email", to: mailUser)
                        }
                    }
                    
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                    self.performSegueWithIdentifier("showClientSegue", sender: nil)
                    FBSDKAppEvents.logEvent("Login")
                } else {
                    let alertController = UIAlertController(title: pmmNotice, message: signInNotice, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                }
        }
    }
    
    func updateCookies(response: Response<AnyObject, NSError>) {
        if let
            headerFields = response.response?.allHeaderFields as? [String: String],
            let URL = response.request?.URL {
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: URL)
                // Set the cookies back in our shared instance. They'll be sent back with each subsequent request.
                Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: URL, mainDocumentURL: nil)
                defaults.setObject(headerFields, forKey: k_PM_HEADER_FILEDS)
                defaults.setObject(URL.absoluteString, forKey: k_PM_URL_LAST_COOKIE)
        }
    }
    
    @IBAction func clickSignupAction(sender:UIButton!) {
        if !(self.checkRuleInputData()) {
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityView.center = self.view.center
            activityView.startAnimating()
            self.view.addSubview(activityView)
            
            let name = self.signupVC.nameTF.text
            let userEmail = self.signupVC.emailTF.text
            let userPassword = self.signupVC.passwordTF.text
            var gender = self.signupVC.genderTF.text
            
            let fullNameArr = name!.characters.split{$0 == " "}.map(String.init)
            var firstname = ""
            if (fullNameArr.count > 0) {
                firstname = fullNameArr[0]
            }

            if (gender == "") {
                gender = kDontCare
            }
            
            var para : [String: AnyObject]!
            para = [kEmail:userEmail!, kPassword:userPassword!, kFirstname:firstname, kGender:gender!]
            
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Navigation Click", "Label":"Register"]
            mixpanel.track("IOS.Register", properties: properties)
            
            self.view.makeToastActivity(message: "Loading")
            Alamofire.request(.POST, kPMAPI_REGISTER, parameters: para)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        //LOGIN
                        Alamofire.request(.POST, kPMAPI_LOGIN, parameters: [kEmail:userEmail!, kPassword:userPassword!])
                            .responseJSON { response in
                                if response.response?.statusCode == 200 {
                                    let JSON = response.result.value
                                    
                                    UserRouter.saveCurrentUserInfo(response)
                                    
                                    if (self.cameraProfileIconIMV.hidden) {
                                        var prefix = kPMAPIUSER
                                        prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
                                        prefix.appendContentsOf(kPM_PATH_PHOTO_PROFILE)
                                        var parameters = [String:AnyObject]()
                                        parameters = [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, kProfilePic: "1"]
                                        Alamofire.upload(
                                            .POST,
                                            prefix,
                                            multipartFormData: { multipartFormData in
                                                multipartFormData.appendBodyPart(data: self.imageData, name: "file",
                                                    fileName:self.filename, mimeType:self.type)
                                                for (key, value) in parameters {
                                                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                                                }
                                            },
                                            encodingCompletion: { encodingResult in
                                                switch encodingResult {
                                                case .Success(let upload, _, _):
                                                    upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                                                        dispatch_async(dispatch_get_main_queue()) {
                                                            //Print percent here
                                                        }
                                                    }
                                                    upload.validate()
                                                    upload.responseJSON { response in
                                                        if response.result.error != nil {
                                                            activityView.stopAnimating()
                                                            activityView.removeFromSuperview()
                                                            self.view.hideToastActivity()
                                                            let alertController = UIAlertController(title: pmmNotice, message: registerNoticeSuccessWithoutImage, preferredStyle: .Alert)
                                                            
                                                            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                                                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                                                                self.performSegueWithIdentifier("showClientSegue", sender: nil)
                                                            }
                                                            alertController.addAction(OKAction)
                                                            self.presentViewController(alertController, animated: true) {
                                                                // ...
                                                            }
                                                        } else {
                                                            activityView.stopAnimating()
                                                            activityView.removeFromSuperview()
                                                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                                                            self.performSegueWithIdentifier("showClientSegue", sender: nil)
                                                        }
                                                    }
                                                    
                                                case .Failure(let _):
                                                    activityView.stopAnimating()
                                                    activityView.removeFromSuperview()
                                                    self.view.hideToastActivity()
                                                    let alertController = UIAlertController(title: pmmNotice, message: registerNoticeSuccessWithoutImage, preferredStyle: .Alert)
                                                    
                                                    
                                                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                                                        // ...
                                                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                                                        self.performSegueWithIdentifier("showClientSegue", sender: nil)
                                                    }
                                                    alertController.addAction(OKAction)
                                                    self.presentViewController(alertController, animated: true) {
                                                        // ...
                                                    }
                                                }
                                            }
                                        )
                                    } else {
                                        // REGISTER OK, SIGNIN OK
                                        activityView.stopAnimating()
                                        activityView.removeFromSuperview()
                                        self.view.hideToastActivity()
                                        FBSDKAppEvents.logEvent("Register")
                                        
                                        self.updateCookies(response)
                                        let currentId = String(format:"%0.f",JSON!.objectForKey(kUserId)!.doubleValue)
                                        self.defaults.setObject(true, forKey: k_PM_IS_LOGINED)
                                        self.defaults.setObject(currentId, forKey: k_PM_CURRENT_ID)
                                        
                                        let mixpanel = Mixpanel.sharedInstance()
                                        if mixpanel.distinctId != "" {
                                            mixpanel.identify(currentId)
                                        } else {
                                            mixpanel.createAlias(currentId, forDistinctID: mixpanel.distinctId)
                                            mixpanel.identify(mixpanel.distinctId)
                                        }
                                        
                                        if let userinfo = JSON!.objectForKey("user") as? NSDictionary {
                                            if let nameUser = userinfo.objectForKey(kFirstname) as? String {
                                                mixpanel.people.set("$name", to: nameUser)
                                            }
                                            
                                            if let mailUser = userinfo[kEmail] as? String {
                                                mixpanel.people.set("$email", to: mailUser)
                                            }
                                        }
                                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                                        self.performSegueWithIdentifier("showClientSegue", sender: nil)
                                    }
                                }else {
                                    // REGISTER OK, BUT CAN'T SIGN IN
                                    let alertController = UIAlertController(title: pmmNotice, message:registerNoticeSuccessButCantSignAutomatic, preferredStyle: .Alert)
                                    self.view.hideToastActivity()
                                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                                        activityView.stopAnimating()
                                        activityView.removeFromSuperview()
                                        self.isShowLogin = true
                                        self.updateUI()
                                    }
                                    alertController.addAction(OKAction)
                                    self.presentViewController(alertController, animated: true) {
                                        // ...
                                    }
                                }
                        }
                       
                    } else if (response.response?.statusCode == 400) {
                        activityView.stopAnimating()
                        activityView.removeFromSuperview()
                        self.view.hideToastActivity()
                        let alertController = UIAlertController(title: pmmNotice, message: yourEmailIsNotValid, preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                    } else {
                        activityView.stopAnimating()
                        activityView.removeFromSuperview()
                        self.view.hideToastActivity()
                        let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                    }
            }
        }
    }
    
    func showPopupToSelectProfileAvatar() {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .Camera
            self.imagePicker.cameraDevice = .Front
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.Destructive, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.Destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func imageTapped()
    {
        showPopupToSelectProfileAvatar()
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Select Profile"]
        mixpanel.track("IOS.Register", properties: properties)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileIMV.contentMode = .ScaleAspectFill
            self.profileIMV.image = pickedImage
            type = imageJpeg
            filename = jpgeFile
            imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
            self.cameraProfileIconIMV.hidden = true
            self.addProfilePhototLB.textColor = UIColor(white: 225, alpha: 1.0)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()) != nil {
            if ( self.view.frame.origin.y == 0) {
                let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
                let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
                let SCREEN_MAX_LENGTH    = max(SCREEN_WIDTH, SCREEN_HEIGHT)
                if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 667.0) {
                    self.view.frame.origin.y = 10
                } else {
                    self.view.frame.origin.y = 0
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 0
        }
        if (self.isShowLogin == true && self.loginVC.emailTF.text != "" && self.loginVC.passwordTF.text != "") {
            self.clickSigninAction(self.loginBT)
        }
    }
    
    func checkRuleInputData() -> Bool {
        var returnValue  = false
        
        if !(self.isValidEmail(signupVC.emailTF.text!)) {
            returnValue = true
            signupVC.emailAttentionIM.hidden = false
            signupVC.emailTF.attributedText = NSAttributedString(string:signupVC.emailTF.text!,
                attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            signupVC.emailAttentionIM.hidden = true
            signupVC.emailTF.attributedText = NSAttributedString(string:signupVC.emailTF.text!,
                attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
        }
        
        if !(self.checkPassword(signupVC.passwordTF.text!)) {
            returnValue = true
            signupVC.passwordAttentionIM.hidden = false
            signupVC.passwordTF.attributedText = NSAttributedString(string:signupVC.passwordTF.text!,
                attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            signupVC.passwordAttentionIM.hidden = true
            signupVC.passwordTF.attributedText = NSAttributedString(string:signupVC.passwordTF.text!,
                attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
        }
        
        return returnValue
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", kEmailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func checkDateChanged(testStr:String) -> Bool {
        if (testStr == "") {
            return false
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            let dateDOB = dateFormatter.dateFromString(testStr)
            
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day , .Month , .Year], fromDate: date)
            let componentsDOB = calendar.components([.Day , .Month , .Year], fromDate:dateDOB!)
            let year =  components.year
            let yearDOB = componentsDOB.year
            
            if (12 < (year - yearDOB)) && ((year - yearDOB) < 101)  {
                return true
            } else {
                return false
            }
        }
    }
    
    func checkPassword(testStr:String) -> Bool {
        if (testStr.characters.count < 8) {
            return false
        } else {
            return true
        }
    }
}
