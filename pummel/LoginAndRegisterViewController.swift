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
        self.navigationController?.navigationBar.isHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Add loginVC
        self.addChildViewController(loginVC)
        loginVC.didMove(toParentViewController: self)
        loginVC.view.frame = CGRect(x: 0, 251, self.view.frame.size.width,  self.view.frame.size.height - 251)
        self.view.addSubview(loginVC.view)
        
        // Add registerVC and hidden it for initial
        self.addChildViewController(signupVC)
        signupVC.didMove(toParentViewController: self)
        signupVC.view.frame = CGRect(x: 0, 251, self.view.frame.size.width, self.view.frame.size.height - 251)
        self.view.addSubview(signupVC.view)
        
        self.updateLoginScreen()
        self.profileIMV.layer.cornerRadius = 45
        self.addProfileIMV.layer.cornerRadius = 15
        self.addProfileIMV.clipsToBounds = true
        profileIMV.clipsToBounds = true
        imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(LoginAndRegisterViewController.imageTapped)))
        self.addProfileIMV.isUserInteractionEnabled = true
        self.addProfileIMV.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginSuccessAction), name: "LOGINSUCCESSNOTIFICATION", object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.signupSuccessAction), name: "SIGNUPSUCCESSNOTIFICATION", object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.forgotPasswordAction), name: "FORGOTPASSWORDNOTIFICATION", object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loginSuccessAction() {
        self.performSegue(withIdentifier: "showClientSegue", sender: nil)
    }
    
    func forgotPasswordAction() {
        performSegue(withIdentifier: "forgottenPasswordSegue", sender: nil)
    }
    
    func signupSuccessAction() {
        self.view.makeToastActivity()
        
        if (self.imageData == nil) {
            let noImage = UIImage(named: "display-empty.jpg")
            self.imageData = UIImageJPEGRepresentation(noImage!, 0.5)
        }
        
        ImageVideoRouter.currentUserUploadAvatar(imageData: self.imageData) { (result, error) in
            self.view.hideToastActivity()
            
            let isSuccess = result as! Bool
            if (isSuccess == true) {
                UserDefaults.standard.setBool(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                self.performSegue(withIdentifier: "showClientSegue", sender: nil)
            } else {
                let alertController = UIAlertController(title: pmmNotice, message: registerNoticeSuccessWithoutImage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                    UserDefaults.standard.setBool(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                    self.performSegue(withIdentifier: "showClientSegue", sender: nil)
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true) {
                    // ...
                }
            }
        }.fetchdata()
    }
    
    @IBAction func backButtonClicked(sender:UIButton!) {
        self.navigationController?.popViewController(animated: true)
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
            loginVC.view.isHidden = true
            signupVC.view.isHidden = false
            self.underLineViewLeadingContraint.constant = self.view.frame.size.width/2
            self.addProfilePhototLB.isHidden = false
            self.profileIMV.isHidden = true
            self.logoIMV.isHidden = false
            self.profileIMV.isHidden = false
            self.logoIMV.isHidden = true
            self.addProfileIMV.isHidden = false
            self.addProfileIconIMV.isHidden = false
            self.cameraProfileIconIMV.isHidden = false
        } else {
            signupVC.view.isHidden = true
            loginVC.view.isHidden = false
            self.underLineViewLeadingContraint.constant = 0
            self.addProfilePhototLB.isHidden = true
            self.profileIMV.isHidden = true
            self.logoIMV.isHidden = false
            self.addProfileIMV.isHidden = true
            self.addProfileIconIMV.isHidden = true
            self.cameraProfileIconIMV.isHidden = true
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showPopupToSelectProfileAvatar() {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .Camera
            self.imagePicker.cameraDevice = .Front
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.destructive, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    func imageTapped() {
        showPopupToSelectProfileAvatar()
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Select Profile"]
        mixpanel?.track("IOS.Register", properties: properties)
    }
    
    func checkDateChanged(testStr:String) -> Bool {
        if (testStr == "") {
            return false
        } else {
            let dateFormatter = DateFormatter
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            let dateDOB = dateFormatter.date(from: testStr)
            
            let date = NSDate()
            let calendar = NSCalendar.current
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
            self.cameraProfileIconIMV.isHidden = true
            self.addProfilePhototLB.textColor = UIColor(white: 225, alpha: 1.0)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
