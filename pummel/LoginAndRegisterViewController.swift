//
//  LoginAndRegisterViewController.swift
//  pummel
//
//  Created by Bear Daddy on 4/12/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Mixpanel
import FBSDKCoreKit

class LoginAndRegisterViewController: UIViewController {
    
    var loginVC : SigninViewController = SigninViewController(nibName: "SigninViewController", bundle: nil)
    var signupVC : SignupViewController = SignupViewController(nibName: "SignupViewController", bundle: nil)
    var isShowLogin = true
    
    @IBOutlet weak var containtView: UIView!
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
    var imageData : NSData! = NSData()
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hidden navigation bar
        self.navigationController?.navigationBar.isHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Add loginVC
        self.addChildViewController(self.loginVC)
        self.loginVC.didMove(toParentViewController: self)
        self.loginVC.view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH,  height: SCREEN_HEIGHT - 251)
        self.loginVC.view.clipsToBounds = true
        self.containtView.addSubview(self.loginVC.view)
        self.addContentLayoutForView(view: self.loginVC.view)
        
        // Add registerVC and hidden it for initial
        self.addChildViewController(self.signupVC)
        self.signupVC.didMove(toParentViewController: self)
        self.signupVC.view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 251)
        self.containtView.addSubview(self.signupVC.view)
        self.addContentLayoutForView(view: self.signupVC.view)
        
        self.updateLoginScreen()
        self.profileIMV.layer.cornerRadius = 45
        self.addProfileIMV.layer.cornerRadius = 15
        self.addProfileIMV.clipsToBounds = true
        profileIMV.clipsToBounds = true
        imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(LoginAndRegisterViewController.imageTapped)))
        self.addProfileIMV.isUserInteractionEnabled = true
        self.addProfileIMV.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginSuccessAction), name: NSNotification.Name(rawValue: "LOGINSUCCESSNOTIFICATION"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.signupSuccessAction), name: NSNotification.Name(rawValue: "SIGNUPSUCCESSNOTIFICATION"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.forgotPasswordAction), name: NSNotification.Name(rawValue: "FORGOTPASSWORDNOTIFICATION"), object: nil)
    }
    
    func addContentLayoutForView(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self.containtView, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: self.containtView, attribute: .height, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self.containtView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self.containtView, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.containtView.addConstraints([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loginSuccessAction() {
        PMHelper.actionWithDelaytime(delayTime: 0.5) {
            self.performSegue(withIdentifier: "showClientSegue", sender: nil)
        }
    }
    
    func forgotPasswordAction() {
        performSegue(withIdentifier: "forgottenPasswordSegue", sender: nil)
    }
    
    func signupSuccessAction() {
        self.view.makeToastActivity()
        
//        if (self.imageData == nil) {
//            let noImage = UIImage(named: "display-empty.jpg")
//            self.imageData = UIImageJPEGRepresentation(noImage!, 0.5)! as NSData
//        }
        
        ImageVideoRouter.uploadPhoto(posfix: kPM_PATH_PHOTO_PROFILE, imageData: self.imageData as Data, textPost: "") { (result, error) in
            self.view.hideToastActivity()
            
            let isSuccess = result as! Bool
            if (isSuccess == true) {
                UserDefaults.standard.set(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                self.performSegue(withIdentifier: "showClientSegue", sender: nil)
            } else {
                let alertController = UIAlertController(title: pmmNotice, message: registerNoticeSuccessWithoutImage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                    UserDefaults.standard.set(true, forKey: "SHOW_SEARCH_AFTER_REGISTER")
                    self.performSegue(withIdentifier: "showClientSegue", sender: nil)
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true) {
                    // ...
                }
            }
        }.fetchdata()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        self.isShowLogin = true
        self.updateLoginScreen()
    }
    
    @IBAction func signupButtonClicked(_ sender: Any) {
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
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraDevice = .front
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
            let dateDOB = dateFormatter.date(from: testStr)
            
            let date = NSDate()
            let calendar = NSCalendar.current
            let components = calendar.dateComponents([.day , .month , .year], from: date as Date)
            let componentsDOB = calendar.dateComponents([.day , .month , .year], from: dateDOB!)
            let year =  components.year
            let yearDOB = componentsDOB.year
            
            if (12 < (year! - yearDOB!)) && ((year! - yearDOB!) < 101)  {
                return true
            } else {
                return false
            }
        }
    }
}

extension LoginAndRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileIMV.contentMode = .scaleAspectFill
            self.profileIMV.image = pickedImage
            self.imageData = UIImageJPEGRepresentation(pickedImage, 0.2)! as NSData
            self.cameraProfileIconIMV.isHidden = true
            self.addProfilePhototLB.textColor = UIColor(white: 225, alpha: 1.0)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
