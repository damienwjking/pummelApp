//
//  LoginAndRegisterViewController.swift
//  pummel
//
//  Created by Bear Daddy on 4/12/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Mixpanel
import Alamofire
import FBSDKCoreKit

class LoginAndRegisterViewController: UIViewController {
    
    var loginVC : SigninViewController = SigninViewController(nibName: "SigninViewController", bundle: nil)
    var signupVC : SignupViewController = SignupViewController(nibName: "SignupViewController", bundle: nil)
    var isShowLogin : Bool!
    
    @IBOutlet var underLineView: UIView!
    @IBOutlet weak var underLineViewLeadingContraint: NSLayoutConstraint!
    @IBOutlet var loginButton : UIButton!
    @IBOutlet var signupButton : UIButton!
    @IBOutlet var logoIMV: UIImageView!
    @IBOutlet var profileIMV: UIImageView!
    @IBOutlet var addProfileIMV : UIImageView!
    @IBOutlet var addProfileIconIMV : UIImageView!
    @IBOutlet var cameraProfileIconIMV : UIImageView!
    @IBOutlet var addProfilePhototLB : UILabel!
    var imageData : NSData!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hidden navigation bar
        self.navigationController?.navigationBar.hidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Add loginVC
        self.addChildViewController(loginVC)
        loginVC.didMoveToParentViewController(self)
        loginVC.view.frame = CGRectMake(0, 251, self.view.frame.size.width,  self.view.frame.size.height - 251)
        self.view.addSubview(loginVC.view)
        
        // Add registerVC and hidden it for initial
        self.addChildViewController(signupVC)
        signupVC.didMoveToParentViewController(self)
        signupVC.view.frame = CGRectMake(0, 251, self.view.frame.size.width, self.view.frame.size.height - 251)
        self.view.addSubview(signupVC.view)
        
        self.updateLoginScreen()
        self.profileIMV.layer.cornerRadius = 45
        self.addProfileIMV.layer.cornerRadius = 15
        self.addProfileIMV.clipsToBounds = true
        profileIMV.clipsToBounds = true
        imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(LoginAndRegisterViewController.imageTapped)))
        self.addProfileIMV.userInteractionEnabled = true
        self.addProfileIMV.addGestureRecognizer(tapGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loginSuccessAction), name: "LOGINSUCCESSNOTIFICATION", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.signupSuccessAction), name: "SIGNUPSUCCESSNOTIFICATION", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.forgotPasswordAction), name: "FORGOTPASSWORDNOTIFICATION", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func loginSuccessAction() {
        self.performSegueWithIdentifier("showClientSegue", sender: nil)
    }
    
    func forgotPasswordAction() {
        performSegueWithIdentifier("forgottenPasswordSegue", sender: nil)
    }
    
    func signupSuccessAction() {
        self.view.makeToastActivity()
        
        if (self.imageData == nil) {
            let noImage = UIImage(named: "display-empty.jpg")
            self.imageData = UIImageJPEGRepresentation(noImage!, 0.5)
        }
        
        ImageRouter.currentUserUploadAvatar(imageData: self.imageData) { (result, error) in
            self.view.hideToastActivity()
            
            let isSuccess = result as! Bool
            if (isSuccess == true) {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                self.performSegueWithIdentifier("showClientSegue", sender: nil)
            } else {
                let alertController = UIAlertController(title: pmmNotice, message: registerNoticeSuccessWithoutImage, preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                    self.performSegueWithIdentifier("showClientSegue", sender: nil)
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
            }
        }.fetchdata()
    }
    
    @IBAction func backButtonClicked(sender:UIButton!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func loginAction(sender:UIButton!) {
        self.isShowLogin = true
        self.updateLoginScreen()
    }
    
    @IBAction func signupAction(sender:UIButton!) {
        self.isShowLogin = false
        self.updateLoginScreen()
    }
    
    func updateLoginScreen() {
        if (self.isShowLogin == false) {
            loginVC.view.hidden = true
            signupVC.view.hidden = false
            self.underLineViewLeadingContraint.constant = self.view.frame.size.width/2
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
            self.underLineViewLeadingContraint.constant = 0
            self.addProfilePhototLB.hidden = true
            self.profileIMV.hidden = true
            self.logoIMV.hidden = false
            self.addProfileIMV.hidden = true
            self.addProfileIconIMV.hidden = true
            self.cameraProfileIconIMV.hidden = true
        }
        
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
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
    
    func imageTapped() {
        showPopupToSelectProfileAvatar()
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Select Profile"]
        mixpanel.track("IOS.Register", properties: properties)
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
}

extension LoginAndRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileIMV.contentMode = .ScaleAspectFill
            self.profileIMV.image = pickedImage
            self.imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
            self.cameraProfileIconIMV.hidden = true
            self.addProfilePhototLB.textColor = UIColor(white: 225, alpha: 1.0)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
