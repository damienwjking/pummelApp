//
//  EditProfileViewController.swift
//  pummel
//
//  Created by ThongNguyen on 4/8/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Mixpanel

class EditProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, FusumaDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomDT: NSLayoutConstraint!
    @IBOutlet weak var avatarIMW: UIImageView!
    @IBOutlet weak var changeAvatarIMW: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var nameContentTF: UITextField!
    @IBOutlet weak var aboutLB: UILabel!
    @IBOutlet weak var aboutContentTV: TextViewAutoHeight!
    @IBOutlet weak var aboutContentDT: NSLayoutConstraint!
    
    @IBOutlet weak var privateInformationLB: UILabel!
    @IBOutlet weak var emailLB: UILabel!
    @IBOutlet weak var emailContentTF: UITextField!
    @IBOutlet weak var mobileLB: UILabel!
    @IBOutlet weak var mobileContentTF: UITextField!
    
    @IBOutlet weak var healthDataLB: UILabel!
    @IBOutlet weak var genderLB: UILabel!
    @IBOutlet weak var genderContentTF: UITextField!
    @IBOutlet weak var dobLB: UILabel!
    @IBOutlet weak var dobContentTF: UITextField!
    @IBOutlet weak var weightLB: UILabel!
    @IBOutlet weak var weightContentTF: UITextField!
    @IBOutlet weak var heightLB: UILabel!
    @IBOutlet weak var heightContentTF: UITextField!
    
    @IBOutlet weak var socialLB: UILabel!
    @IBOutlet weak var facebookLB: UILabel!
    @IBOutlet weak var facebookUrlTF: UITextField!
    @IBOutlet weak var instagramLB: UILabel!
    @IBOutlet weak var instagramUrlTF: UITextField!
    @IBOutlet weak var twitterLB: UILabel!
    @IBOutlet weak var twitterUrlTF: UITextField!
    @IBOutlet weak var aboutDT: NSLayoutConstraint!
    @IBOutlet weak var tapView: UIView!
    
    @IBOutlet weak var emergencyInformationLB: UILabel!
    @IBOutlet weak var emergencyNameLB: UILabel!
    @IBOutlet weak var emergencyNameTF: UITextField!
    @IBOutlet weak var emergencyMobileLB: UILabel!
    @IBOutlet weak var emergencyMobileTF: UITextField!
    
    var isFirstTVS : Bool = false
     var userInfo: NSDictionary!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kNavEditProfile
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.isTranslucent = false;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kDone, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditProfileViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:kCancle.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditProfileViewController.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        

        avatarIMW.layer.cornerRadius = 50
        avatarIMW.clipsToBounds = true
        imagePicker.delegate = self
        
        changeAvatarIMW.layer.cornerRadius = changeAvatarIMW.frame.height/2
        changeAvatarIMW.clipsToBounds = true
        
        self.nameLB.font = .pmmMonLight11()
        self.aboutLB.font = .pmmMonLight11()
        self.emailLB.font = .pmmMonLight11()
        self.genderLB.font = .pmmMonLight11()
        self.mobileLB.font = .pmmMonLight11()
        self.facebookLB.font = .pmmMonLight11()
        self.instagramLB.font = .pmmMonLight11()
        self.twitterLB.font = .pmmMonLight11()
        self.emergencyNameLB.font = .pmmMonLight11()
        self.emergencyMobileLB.font = .pmmMonLight11()
        
        self.privateInformationLB.font = .pmmMonReg11()
        emergencyInformationLB.font = .pmmMonReg11()
        self.healthDataLB.font = .pmmMonReg11()
        self.socialLB.font = .pmmMonReg11()
        
        self.nameContentTF.font = .pmmMonLight13()
        self.aboutContentTV.font = .pmmMonLight13()
        self.emailContentTF.font = .pmmMonLight13()
        self.genderContentTF.font = .pmmMonLight13()
        self.dobContentTF.font = .pmmMonLight13()
        self.dobContentTF.placeholder = "YYYY-MM-DD"
        self.weightContentTF.font = .pmmMonLight13()
        self.heightContentTF.font = .pmmMonLight13()
        self.mobileContentTF.font = .pmmMonLight13()
        self.facebookUrlTF.font = .pmmMonLight13()
        self.facebookUrlTF.placeholder = "http://facebook.com"
        self.instagramUrlTF.font = .pmmMonLight13()
        self.instagramUrlTF.placeholder = "http://instagram.com"
        self.twitterUrlTF.font = .pmmMonLight13()
        self.twitterUrlTF.placeholder = "http:/twitter.com"
        self.emergencyNameTF.font = .pmmMonLight13()
        self.emergencyMobileTF.font = .pmmMonLight13()
        
        self.nameContentTF.delegate = self
        self.emailContentTF.delegate = self
        self.genderContentTF.delegate = self
        self.dobContentTF.delegate = self
        self.weightContentTF.delegate = self
        self.heightContentTF.delegate = self
        self.mobileContentTF.delegate = self
        self.facebookUrlTF.delegate = self
        self.instagramUrlTF.delegate = self
        self.twitterUrlTF.delegate = self
        self.emergencyNameTF.delegate = self
        self.emergencyMobileTF.delegate = self
        self.aboutContentTV.maxHeight = 100
        
        self.changeAvatarIMW.layer.cornerRadius = 15
        self.changeAvatarIMW.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(LoginAndRegisterViewController.imageTapped)))
        self.changeAvatarIMW.isUserInteractionEnabled = true
        self.changeAvatarIMW.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.didTapView))
        self.tapView.addGestureRecognizer(tap)
        self.tapView.isHidden = true
    }
    
    func didTapView() {
        self.aboutContentTV.resignFirstResponder()
        self.emailContentTF.resignFirstResponder()
        self.mobileContentTF.resignFirstResponder()
        self.nameContentTF.resignFirstResponder()
        self.dobContentTF.resignFirstResponder()
        self.weightContentTF.resignFirstResponder()
        self.heightContentTF.resignFirstResponder()
        self.facebookUrlTF.resignFirstResponder()
        self.twitterUrlTF.resignFirstResponder()
        self.instagramUrlTF.resignFirstResponder()
        self.emergencyNameTF.resignFirstResponder()
        self.emergencyMobileTF.resignFirstResponder()
        
        let numberFormat = NumberFormatter()
        numberFormat.numberStyle = .decimal
        
        var weightText = self.weightContentTF.text
        if weightText?.isEmpty == false {
            if isNumber(testStr: weightText!) {
                weightText = numberFormat.string(from: NSNumber(value: Int(weightText!)!))
                self.weightContentTF.text = weightText! + " kgs"
            }
        }
        
        var heightText = self.heightContentTF.text
        if heightText?.isEmpty == false {
            if isNumber(testStr: heightText!) {
                heightText = numberFormat.string(from: NSNumber(value: Int(heightText!)!))
                self.heightContentTF.text = heightText! + " cms"
            }
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setAvatar()
        self.updateUI()
        self.aboutDT.constant = self.view.frame.size.width - 30
    }
    
    func updateUI() {
        if (self.userInfo == nil) {
            var prefix = kPMAPIUSER
            prefix.append(PMHelper.getCurrentID())
            
            UserRouter.getCurrentUserInfo(completed: { (result, error) in
                if (error == nil) {
                    self.userInfo = result as! NSDictionary
                    
                    self.fillDataForUserLayout()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        } else {
            self.fillDataForUserLayout()
        }
    }
    
    func fillDataForUserLayout() {
        if (self.userInfo[kLastName] is NSNull == false) {
            let firstName = self.userInfo[kFirstname] as! String
            let lastName = self.userInfo[kLastName] as! String
            
            self.nameContentTF.text = firstName + " " + lastName
        } else {
            self.nameContentTF.text = self.userInfo[kFirstname] as? String
        }
        
        if (self.userInfo[kBio] is NSNull == false) {
            self.aboutContentTV.text = self.userInfo[kBio] as! String
        } else {
            self.aboutContentTV.text = ""
        }
        
        if (self.userInfo[kMobile] is NSNull == false) {
            self.mobileContentTF.text = self.userInfo[kMobile] as? String
        } else {
            self.mobileContentTF.text = ""
        }
        
        if (self.userInfo[kDob] is NSNull == false) {
            let stringDob = self.userInfo[kDob] as! String
//            self.dobContentTF.text = stringDob.substringToIndex(stringDob.startIndex.advancedBy(10))
            self.dobContentTF.text = stringDob.substring(to: stringDob.index(0, offsetBy: 10))
        } else {
            self.dobContentTF.text = ""
        }
        
        if (self.userInfo[kWeight] is NSNull == false) {
            let weightNumber = self.userInfo[kWeight] as! NSNumber
            self.weightContentTF.text = String(format: "%ld kgs", weightNumber.intValue)
        } else {
            self.weightContentTF.text = ""
        }
        
        if (self.userInfo[kHeight] is NSNull == false) {
            let heightNumber = self.userInfo[kHeight] as! NSNumber
            self.heightContentTF.text = String(format: "%ld cms", heightNumber.intValue)
        } else {
            self.heightContentTF.text = ""
        }
        
        if (self.userInfo[kFacebookUrl] is NSNull == false) {
            self.facebookUrlTF.text = self.userInfo[kFacebookUrl] as? String
        }
        
        if (self.userInfo[kInstagramUrl] is NSNull == false) {
            self.instagramUrlTF.text = self.userInfo[kInstagramUrl] as? String
        }
        
        if (self.userInfo[kTwitterUrl] is NSNull == false) {
            self.twitterUrlTF.text = self.userInfo[kTwitterUrl] as? String
        }
        
        if (self.userInfo[kEmergencyName] is NSNull == false) {
            self.emergencyNameTF.text = self.userInfo[kEmergencyName] as? String
        }
        
        if (self.userInfo[kEmergencyMobile] is NSNull == false) {
            self.emergencyMobileTF.text = self.userInfo[kEmergencyMobile] as? String
        }
        
        let sizeAboutTV = self.aboutContentTV.sizeThatFits(self.aboutContentTV.frame.size)
        self.aboutContentDT.constant = sizeAboutTV.height + 20
        
        self.genderContentTF.text = self.userInfo[kGender] as? String
        
        self.emailContentTF.text = self.userInfo[kEmail] as? String
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tapView.isHidden = false
        if (self.isFirstTVS) {return}
        if let keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            if (self.scrollView.contentOffset.y >= 0) {
                self.scrollView.contentOffset.y += keyboardSize.height
            }
            
            self.scrollViewBottomDT.constant = keyboardSize.height + 21
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tapView.isHidden = true
        self.isFirstTVS = false
        if let _ = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            self.view.frame.origin.y = 64
            
            self.scrollViewBottomDT.constant = 21;
        }
    }
    
    func done() {
        if (self.checkRuleInputData() == false) {
            var prefix = kPMAPIUSER
            prefix.append(PMHelper.getCurrentID())
            
            let fullNameArr = nameContentTF.text!.characters.split{$0 == " "}.map(String.init)
            var firstname = ""
            if (fullNameArr.count > 0) {
                firstname = fullNameArr[0]
            }
            var lastname = ""
            if fullNameArr.count >= 2 {
                for i in 1 ..< fullNameArr.count {
                    lastname.append(fullNameArr[i])
                    lastname.append(" ")
                }
            } 

            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Navigation Click", "Label":"Save Profile"]
            mixpanel.track("IOS.Profile.EditProfile", properties: properties)
            
            self.view.makeToastActivity(message: "Saving")
            
            let weightString = weightContentTF.text?.replacingOccurrences(of: " kgs", with: "")
            let heightString = heightContentTF.text?.replacingOccurrences(of: " cms", with: "")
            
            let param = (dobContentTF.text! == "") ?
                    [kUserId:PMHelper.getCurrentID(),
                     kFirstname:firstname,
                     kLastName: lastname,
                     kMobile: mobileContentTF.text!,
                     kDob: dobContentTF.text!,
                     kGender:(genderContentTF.text?.uppercased())!,
                     kBio: aboutContentTV.text,
                     kWeight: weightString,
                     kHeight: heightString,
                     kFacebookUrl:facebookUrlTF.text!,
                     kTwitterUrl:twitterUrlTF.text!,
                     kInstagramUrl:instagramUrlTF.text!,
                     kEmergencyName:emergencyNameTF.text!,
                     kEmergencyMobile:emergencyMobileTF.text!] :
                    
                    [kUserId:PMHelper.getCurrentID(),
                     kFirstname:firstname,
                     kLastName: lastname,
                     kMobile: mobileContentTF.text!,
                     kGender:(genderContentTF.text?.uppercased())!,
                     kBio: aboutContentTV.text,
                     kWeight: weightString,
                     kHeight: heightString,
                     kFacebookUrl:facebookUrlTF.text!,
                     kTwitterUrl:twitterUrlTF.text!,
                     kInstagramUrl:instagramUrlTF.text!,
                     kEmergencyName:emergencyNameTF.text!,
                     kEmergencyMobile:emergencyMobileTF.text!]
            
            
            // update weight height
            Alamofire.request(.PUT, prefix, parameters: param)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        //TODO: Save access token here
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.view.hideToastActivity()
                        let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true) {
                            // ...
                        }
                    }
            }

        } else {
            let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true) {
                // ...
            }
        }
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showPopupToSelectProfileAvatar() {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .PhotoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.showCameraRoll()
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.destructive, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    func showCameraRoll() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.defaultMode = .Camera
        fusuma.modeOrder = .CameraFirst
        self.present(fusuma, animated: true, completion: nil)
    }
    
    // Fusuma delegate
    func fusumaImageSelected(image: UIImage) {
        
        let pickedImage = image
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        avatarIMW.addSubview(activityView)
        avatarIMW.contentMode = .ScaleAspectFill
        var imageData : NSData!
        let type = imageJpeg
        let filename = jpgeFile
        imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
        
            if (imageData == nil) {
                DispatchQueue.main.async(execute: {
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    //Your main thread code goes in here
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseChoosePngOrJpeg, preferredStyle: .alert)
                    
                    
                    let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
                        // ...
                    }
                })
            }  else {
                var prefix = kPMAPIUSER
                prefix.append(PMHelper.getCurrentID())
                prefix.append(kPM_PATH_PHOTO_PROFILE)
                
                let parameters = [kUserId:PMHelper.getCurrentID(),
                                  kProfilePic: "1"]
                
                Alamofire.upload(
                    .POST,
                    prefix,
                    multipartFormData: { multipartFormData in
                        multipartFormData.appendBodyPart(data: imageData, name: "file",
                            fileName:filename, mimeType:type)
                        for (key, value) in parameters {
                            multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                        }
                    },
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                            
                        case .Success(let upload, _, _):
                            upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                            }
                            upload.validate()
                            upload.responseJSON { response in
                                if response.result.error != nil {
                                    // failure
                                    activityView.stopAnimating()
                                    activityView.removeFromSuperview()
                                } else {
                                    activityView.stopAnimating()
                                    activityView.removeFromSuperview()
                                    self.avatarIMW.image = pickedImage
                                }
                            }
                            
                        case .Failure( _):
                            activityView.stopAnimating()
                            activityView.removeFromSuperview()
                        }
                    }
                )
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: kCancle, style: .Cancel, handler: { (action) -> Void in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imageTapped()
    {
        showPopupToSelectProfileAvatar()
    }
    
    func setAvatar() {
        let defaults = UserDefaults.standard
        
        if (defaults.bool(forKey: k_PM_IS_COACH) == false) {
            ImageRouter.getCurrentUserAvatar(sizeString: widthHeight250, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.avatarIMW.image = imageRes
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        } else {
            ImageRouter.getCurrentUserAvatar(sizeString: widthHeight250, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.avatarIMW.image = imageRes
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityView.center = self.view.center
            activityView.startAnimating()
            avatarIMW.addSubview(activityView)
            avatarIMW.contentMode = .ScaleAspectFill
            var imageData : NSData!
            let assetPath = info[UIImagePickerControllerReferenceURL] as! NSURL
            var type : String!
            var filename: String!
            if assetPath.absoluteString!.hasSuffix("JPG") {
                type = imageJpeg
                filename = jpgeFile
                imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
            } else if assetPath.absoluteString!.hasSuffix("PNG") {
                type = imagePng
                filename = pngFile
                imageData = UIImagePNGRepresentation(pickedImage)
            }
            
            if (imageData == nil) {
                DispatchQueue.main.async(execute: {
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    //Your main thread code goes in here
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseChoosePngOrJpeg, preferredStyle: .alert)
                    
                    
                    let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
                        // ...
                    }
                })

            } else {
                var prefix = kPMAPIUSER
                prefix.append(PMHelper.getCurrentID())
                prefix.append(kPM_PATH_PHOTO_PROFILE)
                
                let parameters = [kUserId:PMHelper.getCurrentID(),
                                  kProfilePic: "1"]
                
                Alamofire.upload(
                    .POST,
                    prefix,
                    multipartFormData: { multipartFormData in
                        multipartFormData.appendBodyPart(data: imageData, name: "file",
                            fileName:filename, mimeType:type)
                        for (key, value) in parameters {
                            multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                        }
                    },
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                            
                        case .Success(let upload, _, _):
                            upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                            }
                            upload.validate()
                            upload.responseJSON { response in
                                if response.result.error != nil {
                                    // failure
                                    activityView.stopAnimating()
                                    activityView.removeFromSuperview()
                                } else {
                                    activityView.stopAnimating()
                                    activityView.removeFromSuperview()
                                    self.avatarIMW.image = pickedImage
                                }
                            }
                            
                        case .Failure( _):
                            activityView.stopAnimating()
                            activityView.removeFromSuperview()
                        }
                    }
                )
            }
            
        }
    
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func checkRuleInputData() -> Bool {
        var returnValue  = false
        if !(self.isValidEmail(emailContentTF.text!)) {
            returnValue = true
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.black])
        }
               
        // check number weight height
        let weightString = self.weightContentTF.text!.replacingOccurrences(of: " kgs", with: "")
        if !(self.isNumber(testStr: weightString)) {
            returnValue = true
            weightContentTF.attributedText = NSAttributedString(string:weightContentTF.text!,
                                                                attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            weightContentTF.attributedText = NSAttributedString(string:weightContentTF.text!,
                                                             attributes:[NSForegroundColorAttributeName: UIColor.black])
        }
        
        let heightString = self.heightContentTF.text!.replacingOccurrences(of: " cms", with: "")
        if !(self.isNumber(testStr: heightString)) {
            returnValue = true
            heightContentTF.attributedText = NSAttributedString(string:heightContentTF.text!,
                                                                attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            heightContentTF.attributedText = NSAttributedString(string:heightContentTF.text!,
                                                                attributes:[NSForegroundColorAttributeName: UIColor.black])
        }
        
        if self.facebookUrlTF.text != "" && !self.facebookUrlTF.text!.containsIgnoringCase("facebook.com") {
            self.showMsgLinkInValid()
            return true
        }
        
        if self.twitterUrlTF.text != "" && !self.twitterUrlTF.text!.containsIgnoringCase("twitter.com") {
            self.showMsgLinkInValid()
            return true
        }
        
        if self.instagramUrlTF.text != "" && !self.instagramUrlTF.text!.containsIgnoringCase("instagram.com") {
            self.showMsgLinkInValid()
            return true
        }

        return returnValue
    }
    
    func showMsgLinkInValid() {
        let alertController = UIAlertController(title: pmmNotice, message: linkInvalid, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", kEmailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isNumber(testStr:String) -> Bool {
        do {
            let numberRegex = try NSRegularExpression(pattern: "[0-9]", options:.caseInsensitive)
            let weightString = testStr as NSString
            let results = numberRegex.matches(in: testStr, options: [], range: NSMakeRange(0, weightString.length))
            
            if results.count == weightString.length {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func checkDateChanged(testStr:String) -> Bool {
        if (testStr == "") {
            return true
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-mm-dd"
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
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.isEqual(self.genderContentTF) == true {
            self.dobContentTF.resignFirstResponder()
            self.weightContentTF.resignFirstResponder()
            self.heightContentTF.resignFirstResponder()
            self.emailContentTF.resignFirstResponder()
            self.nameContentTF.resignFirstResponder()
            self.mobileContentTF.resignFirstResponder()
            self.aboutContentTV.resignFirstResponder()
            self.showPopupToSelectGender()
            return false
        } else if (textField.isEqual(self.nameContentTF)){
            isFirstTVS = true
            return true
        } else if (textField.isEqual(self.weightContentTF)){
            let weightString = weightContentTF.text?.replacingOccurrences(of: " kgs", with: "")
            self.weightContentTF.text = weightString
            
            return true
        } else if (textField.isEqual(self.heightContentTF)){
            let heightString = heightContentTF.text?.replacingOccurrences(of: " cms", with: "")
            self.heightContentTF.text = heightString
            
            return true
        } else {
            return true
        }
    }
    
    @IBAction func textFieldEditingWithSender(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.backgroundColor = UIColor.black
        datePickerView.setValue(UIColor.white, forKey: "textColor")
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action:#selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.dobContentTF.text = dateFormatter.string(from: sender.date)
        let dateDOB = dateFormatter.date(from: self.dobContentTF.text!)
        
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        let componentsDOB = calendar.components([.Day , .Month , .Year], fromDate:dateDOB!)
        let year =  components.year
        let yearDOB = componentsDOB.year
        
        if (12 < (year - yearDOB)) && ((year - yearDOB) < 1001)  {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                           attributes:[NSForegroundColorAttributeName: UIColor.black])
        } else {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                           attributes:[NSForegroundColorAttributeName:  UIColor.pmmRougeColor()])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(self.emailContentTF) == true {
            if (self.isValidEmail(testStr: self.emailContentTF.text!) == false) {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
            } else {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.black])
            }
        }
        return true
    }

    @IBAction func showPopupToSelectGender() {
        let selectMale = { (action:UIAlertAction!) -> Void in
            self.genderContentTF.text = kMale
        }
        let selectFemale = { (action:UIAlertAction!) -> Void in
            self.genderContentTF.text = kFemale
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kMALEU, style: .default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: kFemaleU, style: .default, handler: selectFemale))
        
        self.present(alertController, animated: true) { }
    }
}

