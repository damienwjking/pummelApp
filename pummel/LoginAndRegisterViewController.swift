//
//  LoginAndRegisterViewController.swift
//  pummel
//
//  Created by Bear Daddy on 4/12/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

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
    
       let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Hidden navigation bar
        self.navigationController?.navigationBar.hidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        loginBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 13)
        signupBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 13)
        addProfilePhototLB.font = UIFont(name: "Montserrat-Regular", size: 10)
        
        // Add loginVC
        self.addChildViewController(loginVC)
        loginVC.didMoveToParentViewController(self)
        loginVC.view.frame = CGRectMake(0, 251, self.view.frame.size.width, loginVC.view.frame.size.height)
        loginVC.forgotPasswordBT.addTarget(self, action:"forgotAction:", forControlEvents:UIControlEvents.TouchUpInside)
        loginVC.signinBT.addTarget(self, action:"clickSigninAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginVC.view)

        // Add registerVC and hidden it for initial
        self.addChildViewController(signupVC)
        signupVC.didMoveToParentViewController(self)
        signupVC.view.frame = CGRectMake(0, 251, self.view.frame.size.width, signupVC.view.frame.size.height)
        signupVC.signupBT.addTarget(self, action:"clickSignupAction:", forControlEvents:UIControlEvents.TouchUpInside)
        self.view.addSubview(signupVC.view)
        
        self.updateUI()
        
        self.profileIMV.layer.cornerRadius = 45
        self.addProfileIMV.layer.cornerRadius = 15
        self.addProfileIMV.clipsToBounds = true
        profileIMV.clipsToBounds = true
        imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:("imageTapped"))
        self.addProfileIMV.userInteractionEnabled = true
        self.addProfileIMV.addGestureRecognizer(tapGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
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
        let userEmail = self.loginVC.emailTF.text
        let userPassword = self.loginVC.passwordTF.text
        
        Alamofire.request(.POST, "http://52.8.5.161:3000/api/login", parameters: ["email":userEmail!, "password":userPassword!])
            .responseJSON { response in
                print("REQUEST-- \(response.request)")  // original URL request
                print("RESPONSE-- \(response.response)") // URL response
                print("DATA-- \(response.data)")     // server data
                print("RESULT-- \(response.result)")   // result of response serialization
                
                if response.response?.statusCode == 200 {
                    //TODO: Save access token here
                    let JSON = response.result.value
                    print("JSON: \(JSON)")
                    let type = response.result.value?.objectForKey("user")?.objectForKey("type")
                    if ((type?.isEqual("USER")) == true) {
                        self.performSegueWithIdentifier("showClientSegue", sender: nil)
                    }
                    
                }else {
                    let alertController = UIAlertController(title: "Sign In Issues", message: "Please check email and password", preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                }
        }
    }
    
    @IBAction func clickSignupAction(sender:UIButton!) {
        let name = self.signupVC.nameTF.text
        let userEmail = self.signupVC.emailTF.text
        let userPassword = self.signupVC.passwordTF.text
        let dob = self.signupVC.dobTF.text
        let gender = self.signupVC.genderTF.text

        let fullNameArr = name!.characters.split{$0 == " "}.map(String.init)
        let firstname = fullNameArr[0]
        var lastname = ""
        if fullNameArr.count >= 2 {
            for var i = 1; i < fullNameArr.count; i++ {
                lastname.appendContentsOf(fullNameArr[i])
                lastname.appendContentsOf(" ")
            }
        }
        
        print(firstname)
        print(lastname)
        
        Alamofire.request(.POST, "http://52.8.5.161:3000/api/register", parameters: ["type":"USER", "email":userEmail!, "password":userPassword!, "firstname":firstname, "lastname":lastname, "dob":dob!, "gender":gender!])
            .responseJSON { response in
                print("REQUEST-- \(response.request)")  // original URL request
                print("RESPONSE-- \(response.response)") // URL response
                print("DATA-- \(response.data)")     // server data
                print("RESULT-- \(response.result)")   // result of response serialization
                print("RESULT CODE -- \(response.response?.statusCode)")
                if response.response?.statusCode == 200 {
                    let JSON = response.result.value
                    print("JSON: \(JSON)")
                    let alertController = UIAlertController(title: "Register status", message: "Resgister sucessfully", preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                } else {
                    let alertController = UIAlertController(title: "Register Issues", message: "Please do it again", preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
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
        alertController.addAction(UIAlertAction(title: "Select From Library", style: UIAlertActionStyle.Default, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func imageTapped()
    {
        showPopupToSelectProfileAvatar()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileIMV.contentMode = .ScaleAspectFill
            self.profileIMV.image = pickedImage
            self.cameraProfileIconIMV.hidden = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if ( self.view.frame.origin.y == 0 && self.isShowLogin == false) {
                let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
                let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
                let SCREEN_MAX_LENGTH    = max(SCREEN_WIDTH, SCREEN_HEIGHT)
                if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 667.0) {
                    self.view.frame.origin.y -= keyboardSize.height - 10
                } else {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 0
        }
    }
}