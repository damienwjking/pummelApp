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
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.translucent = false;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kDone, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditProfileViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:kCancle.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditProfileViewController.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
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
        self.changeAvatarIMW.userInteractionEnabled = true
        self.changeAvatarIMW.addGestureRecognizer(tapGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.didTapView))
        self.tapView.addGestureRecognizer(tap)
        self.tapView.hidden = true
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
        
        let numberFormat = NSNumberFormatter()
        numberFormat.numberStyle = .DecimalStyle
        
        var weightText = self.weightContentTF.text
        if weightText?.isEmpty == false {
            if isNumber(weightText!) {
                weightText = numberFormat.stringFromNumber(Int(weightText!)!)
                self.weightContentTF.text = weightText! + " kgs"
            }
        }
        
        var heightText = self.heightContentTF.text
        if heightText?.isEmpty == false {
            if isNumber(heightText!) {
                heightText = numberFormat.stringFromNumber(Int(heightText!)!)
                self.heightContentTF.text = heightText! + " cms"
            }
        }
    }
    
    
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setAvatar()
        self.updateUI()
        self.aboutDT.constant = self.view.frame.size.width - 30
    }
    
    func updateUI() {
        if (self.userInfo == nil) {
            var prefix = kPMAPIUSER
            let defaults = NSUserDefaults.standardUserDefaults()
            prefix.appendContentsOf(PMHeler.getCurrentID())
            
            Alamofire.request(.GET, prefix)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        if (response.result.value == nil) {return}
                        self.userInfo = response.result.value as! NSDictionary
                        if !(self.userInfo[kLastName] is NSNull) {
                            self.nameContentTF.text = ((self.userInfo[kFirstname] as! String).stringByAppendingString(" ")).stringByAppendingString((self.userInfo[kLastName] as! String))
                        } else {
                            self.nameContentTF.text = self.userInfo[kFirstname] as? String
                        }
                        if !(self.userInfo[kBio] is NSNull) {
                            self.aboutContentTV.text = self.userInfo[kBio] as! String
                        } else {
                            self.aboutContentTV.text = ""
                        }
                        
                        let sizeAboutTV = self.aboutContentTV.sizeThatFits(self.aboutContentTV.frame.size)
                        self.aboutContentDT.constant = sizeAboutTV.height + 20
                        
                        self.genderContentTF.text = self.userInfo[kGender] as? String
                        
                        self.emailContentTF.text = self.userInfo[kEmail] as? String
                        
                        if !(self.userInfo[kMobile] is NSNull) {
                            self.mobileContentTF.text = self.userInfo[kMobile] as? String
                        } else {
                            self.mobileContentTF.text = ""
                        }
                        
                        if !(self.userInfo[kDob] is NSNull) {
                            let stringDob = self.userInfo[kDob] as! String
                            self.dobContentTF.text = stringDob.substringToIndex(stringDob.startIndex.advancedBy(10))
                        } else {
                            self.dobContentTF.text = ""
                        }
                        
                        if !(self.userInfo[kWeight] is NSNull) {
                            let weightNumber = self.userInfo[kWeight] as! NSNumber
                            var weightString = String(format: "%ld", weightNumber.intValue)
                            weightString = weightString.stringByAppendingString(" kgs")
                            self.weightContentTF.text = weightString
                        } else {
                            self.weightContentTF.text = ""
                        }
                        
                        if !(self.userInfo[kHeight] is NSNull) {
                            let heightNumber = self.userInfo[kHeight] as! NSNumber
                            var heightString = String(format: "%ld", heightNumber.intValue)
                            heightString = heightString.stringByAppendingString(" cms")
                            self.heightContentTF.text = heightString
                        } else {
                            self.heightContentTF.text = ""
                        }
                        
                        if !(self.userInfo[kFacebookUrl] is NSNull) {
                            self.facebookUrlTF.text = self.userInfo[kFacebookUrl] as? String
                        }
                        
                        if !(self.userInfo[kInstagramUrl] is NSNull) {
                            self.instagramUrlTF.text = self.userInfo[kInstagramUrl] as? String
                        }
                        
                        if !(self.userInfo[kTwitterUrl] is NSNull) {
                            self.twitterUrlTF.text = self.userInfo[kTwitterUrl] as? String
                        }
                        
                        if !(self.userInfo[kEmergencyName] is NSNull) {
                            self.emergencyNameTF.text = self.userInfo[kEmergencyName] as? String
                        }
                        
                        if !(self.userInfo[kEmergencyMobile] is NSNull) {
                            self.emergencyMobileTF.text = self.userInfo[kEmergencyMobile] as? String
                        }

                    }else if response.response?.statusCode == 401 {
                        let alertController = UIAlertController(title: pmmNotice, message: cookieExpiredNotice, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                            // TODO: LOGOUT
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                        
                    }
            }
        } else {
            if !(self.userInfo[kLastName] is NSNull) {
                self.nameContentTF.text = ((self.userInfo[kFirstname] as! String).stringByAppendingString(" ")).stringByAppendingString((self.userInfo[kLastName] as! String))
            } else {
                self.nameContentTF.text = self.userInfo[kFirstname] as? String
            }
            
            if !(self.userInfo[kBio] is NSNull) {
                self.aboutContentTV.text = self.userInfo[kBio] as! String
            } else {
                self.aboutContentTV.text = ""
            }
            
            self.genderContentTF.text = self.userInfo[kGender] as? String
            
            self.emailContentTF.text = self.userInfo[kEmail] as? String
            
            if !(self.userInfo[kMobile] is NSNull) {
                self.mobileContentTF.text = self.userInfo[kMobile] as? String
            } else {
                self.mobileContentTF.text = ""
            }
            
            if !(self.userInfo[kDob] is NSNull) {
                let stringDob = self.userInfo[kDob] as! String
                self.dobContentTF.text = stringDob.substringToIndex(stringDob.startIndex.advancedBy(10))
            } else {
                self.dobContentTF.text = ""
            }
            
            if !(self.userInfo[kWeight] is NSNull) {
                let weightNumber = self.userInfo[kWeight] as! NSNumber
                var weightString = String(format: "%ld", weightNumber.intValue)
                weightString = weightString.stringByAppendingString(" kgs")
                self.weightContentTF.text = weightString
            } else {
                self.weightContentTF.text = ""
            }
            
            if !(self.userInfo[kHeight] is NSNull) {
                let heightNumber = self.userInfo[kHeight] as! NSNumber
                var heightString = String(format: "%ld", heightNumber.intValue)
                heightString = heightString.stringByAppendingString(" cms")
                self.heightContentTF.text = heightString
            } else {
                self.heightContentTF.text = ""
            }
            
            if !(self.userInfo[kFacebookUrl] is NSNull) {
                self.facebookUrlTF.text = self.userInfo[kFacebookUrl] as? String
            }
            
            if !(self.userInfo[kInstagramUrl] is NSNull) {
                self.instagramUrlTF.text = self.userInfo[kInstagramUrl] as? String
            }
            
            if !(self.userInfo[kTwitterUrl] is NSNull) {
                self.twitterUrlTF.text = self.userInfo[kTwitterUrl] as? String
            }
            
            if !(self.userInfo[kEmergencyName] is NSNull) {
                self.emergencyNameTF.text = self.userInfo[kEmergencyName] as? String
            }
            
            if !(self.userInfo[kEmergencyMobile] is NSNull) {
                self.emergencyMobileTF.text = self.userInfo[kEmergencyMobile] as? String
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tapView.hidden = false
        if (self.isFirstTVS) {return}
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            if (self.scrollView.contentOffset.y >= 0) {
                self.scrollView.contentOffset.y += keyboardSize.height
            }
            
            self.scrollViewBottomDT.constant = keyboardSize.height + 21
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tapView.hidden = true
        self.isFirstTVS = false
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 64
            
            self.scrollViewBottomDT.constant = 21;
        }
    }
    
    func done() {
        if (self.checkRuleInputData() == false) {
            var prefix = kPMAPIUSER
            let defaults = NSUserDefaults.standardUserDefaults()
            prefix.appendContentsOf(PMHeler.getCurrentID())
            
            let fullNameArr = nameContentTF.text!.characters.split{$0 == " "}.map(String.init)
            var firstname = ""
            if (fullNameArr.count > 0) {
                firstname = fullNameArr[0]
            }
            var lastname = ""
            if fullNameArr.count >= 2 {
                for i in 1 ..< fullNameArr.count {
                    lastname.appendContentsOf(fullNameArr[i])
                    lastname.appendContentsOf(" ")
                }
            } 

            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Navigation Click", "Label":"Save Profile"]
            mixpanel.track("IOS.Profile.EditProfile", properties: properties)
            
            self.view.makeToastActivity(message: "Saving")
            
            let weightString = weightContentTF.text?.stringByReplacingOccurrencesOfString(" kgs", withString: "")
            let heightString = heightContentTF.text?.stringByReplacingOccurrencesOfString(" cms", withString: "")
            
            let param = (dobContentTF.text! == "") ?
                    [kUserId:PMHeler.getCurrentID(),
                     kFirstname:firstname,
                     kLastName: lastname,
                     kMobile: mobileContentTF.text!,
                     kDob: dobContentTF.text!,
                     kGender:(genderContentTF.text?.uppercaseString)!,
                     kBio: aboutContentTV.text,
                     kWeight: weightString,
                     kHeight: heightString,
                     kFacebookUrl:facebookUrlTF.text!,
                     kTwitterUrl:twitterUrlTF.text!,
                     kInstagramUrl:instagramUrlTF.text!,
                     kEmergencyName:emergencyNameTF.text!,
                     kEmergencyMobile:emergencyMobileTF.text!] :
                    
                    [kUserId:PMHeler.getCurrentID(),
                     kFirstname:firstname,
                     kLastName: lastname,
                     kMobile: mobileContentTF.text!,
                     kGender:(genderContentTF.text?.uppercaseString)!,
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
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        self.view.hideToastActivity()
                        let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                    }
            }

        } else {
            let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showPopupToSelectProfileAvatar() {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.showCameraRoll()
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.Destructive, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.Destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func showCameraRoll() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.defaultMode = .Camera
        fusuma.modeOrder = .CameraFirst
        self.presentViewController(fusuma, animated: true, completion: nil)
    }
    
    // Fusuma delegate
    func fusumaImageSelected(image: UIImage) {
        
        let pickedImage = image
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        avatarIMW.addSubview(activityView)
        avatarIMW.contentMode = .ScaleAspectFill
        var imageData : NSData!
        let type = imageJpeg
        let filename = jpgeFile
        imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
        
            if (imageData == nil) {
                dispatch_async(dispatch_get_main_queue(),{
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    //Your main thread code goes in here
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseChoosePngOrJpeg, preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                })
            }  else {
                var prefix = kPMAPIUSER
                let defaults = NSUserDefaults.standardUserDefaults()
                prefix.appendContentsOf(PMHeler.getCurrentID())
                prefix.appendContentsOf(kPM_PATH_PHOTO_PROFILE)
                
                var parameters = [kUserId:PMHeler.getCurrentID(),
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
                            
                        case .Failure(let encodingError):
                            activityView.stopAnimating()
                            activityView.removeFromSuperview()
                        }
                    }
                )
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: kCancle, style: .Cancel, handler: { (action) -> Void in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func imageTapped()
    {
        showPopupToSelectProfileAvatar()
    }
    
    func setAvatar() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.boolForKey(k_PM_IS_COACH) == false) {
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
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
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
                dispatch_async(dispatch_get_main_queue(),{
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    //Your main thread code goes in here
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseChoosePngOrJpeg, preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                })

            } else {
                var prefix = kPMAPIUSER
                let defaults = NSUserDefaults.standardUserDefaults()
                prefix.appendContentsOf(PMHeler.getCurrentID())
                prefix.appendContentsOf(kPM_PATH_PHOTO_PROFILE)
                
                var parameters = [kUserId:PMHeler.getCurrentID(),
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
                            
                        case .Failure(let encodingError):
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
                                                               attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
        }
               
        // check number weight height
        let weightString = self.weightContentTF.text!.stringByReplacingOccurrencesOfString(" kgs", withString: "")
        if !(self.isNumber(weightString)) {
            returnValue = true
            weightContentTF.attributedText = NSAttributedString(string:weightContentTF.text!,
                                                                attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            weightContentTF.attributedText = NSAttributedString(string:weightContentTF.text!,
                                                             attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
        }
        
        let heightString = self.heightContentTF.text!.stringByReplacingOccurrencesOfString(" cms", withString: "")
        if !(self.isNumber(heightString)) {
            returnValue = true
            heightContentTF.attributedText = NSAttributedString(string:heightContentTF.text!,
                                                                attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            heightContentTF.attributedText = NSAttributedString(string:heightContentTF.text!,
                                                                attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
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
        let alertController = UIAlertController(title: pmmNotice, message: linkInvalid, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true) {
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", kEmailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func isNumber(testStr:String) -> Bool {
        do {
            let numberRegex = try NSRegularExpression(pattern: "[0-9]", options:.CaseInsensitive)
            let weightString = testStr as NSString
            let results = numberRegex.matchesInString(testStr, options: [], range: NSMakeRange(0, weightString.length))
            
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
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "YYYY-mm-dd"
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
            let weightString = weightContentTF.text?.stringByReplacingOccurrencesOfString(" kgs", withString: "")
            self.weightContentTF.text = weightString
            
            return true
        } else if (textField.isEqual(self.heightContentTF)){
            let heightString = heightContentTF.text?.stringByReplacingOccurrencesOfString(" cms", withString: "")
            self.heightContentTF.text = heightString
            
            return true
        } else {
            return true
        }
    }
    
    @IBAction func textFieldEditingWithSender(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.backgroundColor = UIColor.blackColor()
        datePickerView.setValue(UIColor.whiteColor(), forKey: "textColor")
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action:#selector(EditProfileViewController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.dobContentTF.text = dateFormatter.stringFromDate(sender.date)
        let dateDOB = dateFormatter.dateFromString(self.dobContentTF.text!)
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        let componentsDOB = calendar.components([.Day , .Month , .Year], fromDate:dateDOB!)
        let year =  components.year
        let yearDOB = componentsDOB.year
        
        if (12 < (year - yearDOB)) && ((year - yearDOB) < 1001)  {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                           attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
        } else {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                           attributes:[NSForegroundColorAttributeName:  UIColor.pmmRougeColor()])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(self.emailContentTF) == true {
            if (self.isValidEmail(self.emailContentTF.text!) == false) {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
            } else {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
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
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kMALEU, style: UIAlertActionStyle.Default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: kFemaleU, style: UIAlertActionStyle.Default, handler: selectFemale))
        
        self.presentViewController(alertController, animated: true) { }
    }
}

