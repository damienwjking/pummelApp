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

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarIMW: UIImageView!
    @IBOutlet weak var changeAvatarIMW: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var nameContentTF: UITextField!
    @IBOutlet weak var aboutLB: UILabel!
    @IBOutlet weak var aboutContentTV: UITextView!
    @IBOutlet weak var aboutContentDT: NSLayoutConstraint!
    @IBOutlet weak var privateInformationLB: UILabel!
    @IBOutlet weak var emailLB: UILabel!
    @IBOutlet weak var emailContentTF: UITextField!
    @IBOutlet weak var genderLB: UILabel!
    @IBOutlet weak var genderContentTF: UITextField!
    @IBOutlet weak var dobLB: UILabel!
    @IBOutlet weak var dobContentTF: UITextField!
    @IBOutlet weak var mobileLB: UILabel!
    @IBOutlet weak var mobileContentTF: UITextField!
    @IBOutlet weak var aboutDT: NSLayoutConstraint!
    var userInfo: NSDictionary!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kNavEditProfile
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.translucent = false;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"DONE", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditProfileViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditProfileViewController.cancel))
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
        
        self.privateInformationLB.font = .pmmMonReg11()
        
        self.nameContentTF.font = .pmmMonLight13()
        self.aboutContentTV.font = .pmmMonLight13()
        self.emailContentTF.font = .pmmMonLight13()
        self.genderContentTF.font = .pmmMonLight13()
        self.dobContentTF.font = .pmmMonLight13()
        self.mobileContentTF.font = .pmmMonLight13()
        
        self.aboutContentTV.backgroundColor = UIColor.clearColor()
        self.aboutContentTV.scrollEnabled = false
        
        self.nameContentTF.delegate = self
        self.aboutContentTV.delegate = self
        self.emailContentTF.delegate = self
        self.genderContentTF.delegate = self
        self.dobContentTF.delegate = self
        self.mobileContentTF.delegate = self
        
        self.changeAvatarIMW.layer.cornerRadius = 15
        self.changeAvatarIMW.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(LoginAndRegisterViewController.imageTapped)))
        self.changeAvatarIMW.userInteractionEnabled = true
        self.changeAvatarIMW.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginAndRegisterViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginAndRegisterViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
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
                            self.aboutContentTV.text = thisIsYourBio
                        }
                        self.genderContentTF.text = self.userInfo[kGender] as? String
                        self.emailContentTF.text = self.userInfo[kEmail] as? String
                        let stringDob = self.userInfo[kDob] as! String
                        self.dobContentTF.text = stringDob.substringToIndex(stringDob.startIndex.advancedBy(10))
                        if !(self.userInfo[kMobile] is NSNull) {
                            self.mobileLB.text = self.userInfo[kMobile] as? String
                        } else {
                            self.mobileLB.text = thisIsYourMobile
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
                self.aboutContentTV.text = thisIsYourBio
            }
            self.genderContentTF.text = self.userInfo[kGender] as? String
            self.emailContentTF.text = self.userInfo[kEmail] as? String
            let stringDob = self.userInfo[kDob] as! String
            self.dobContentTF.text = stringDob.substringToIndex(stringDob.startIndex.advancedBy(10))
            if !(self.userInfo[kMobile] is NSNull) {
                self.mobileContentTF.text = self.userInfo[kMobile] as? String
            } else {
                self.mobileContentTF.text = thisIsYourMobile
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                if (self.view.frame.origin.y >= 0) {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 64
        }
    }
    
    func done() {
        if (self.checkRuleInputData() == false) {
            var prefix = kPMAPIUSER
            let defaults = NSUserDefaults.standardUserDefaults()
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            let fullNameArr = nameContentTF.text!.characters.split{$0 == " "}.map(String.init)
            var firstname = ""
            if (fullNameArr.count > 0) {
                firstname = fullNameArr[0]
            }
            var lastname = " "
            if fullNameArr.count >= 2 {
                for i in 1 ..< fullNameArr.count {
                    lastname.appendContentsOf(fullNameArr[i])
                    lastname.appendContentsOf(" ")
                }
            } else {
                lastname = " "
            }

            Alamofire.request(.PUT, prefix, parameters: [kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String, kFirstname:firstname, kLastName: lastname, kMobile: mobileContentTF.text!, kDob: dobContentTF.text!, kGender:(genderContentTF.text?.uppercaseString)!, kBio: aboutContentTV.text])
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        //TODO: Save access token here
                        self.navigationController?.popViewControllerAnimated(true)
                    }else {
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
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.Default, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.Default, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func imageTapped()
    {
        showPopupToSelectProfileAvatar()
    }
    
    func setAvatar() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.boolForKey(k_PM_IS_COACH) != true) {
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let userDetail = JSON as! NSDictionary
                    if !(userDetail[kImageUrl] is NSNull) {
                        var link = kPMAPI
                        link.appendContentsOf(userDetail[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight100)
                        
                        if (NSCache.sharedInstance.objectForKey(link) != nil) {
                            let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                            self.avatarIMW.image = imageRes
                        } else {
                            Alamofire.request(.GET, link)
                                .responseImage { response in
                                    let imageRes = response.result.value! as UIImage
                                    self.avatarIMW.image = imageRes
                                    NSCache.sharedInstance.setObject(imageRes, forKey: link)
                            }
                        }
                    } else {
                        self.avatarIMW.image = UIImage(named:"display-empty.jpg")
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }

        } else {
            var prefix = kPMAPICOACH
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let userDetailFull = JSON as! NSDictionary
                    let userDetail = userDetailFull[kUser] as! NSDictionary
                    if !(userDetail[kImageUrl] is NSNull) {
                        var link = kPMAPI
                        link.appendContentsOf(userDetail[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight100)
                        
                        if (NSCache.sharedInstance.objectForKey(link) != nil) {
                            let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                            self.avatarIMW.image = imageRes
                        } else {
                            Alamofire.request(.GET, link)
                                .responseImage { response in
                                    let imageRes = response.result.value! as UIImage
                                    self.avatarIMW.image = imageRes
                                    NSCache.sharedInstance.setObject(imageRes, forKey: link)
                            }
                        }
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
        }
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityView.center = self.view.center
            activityView.startAnimating()
            avatarIMW.addSubview(activityView)
            avatarIMW.contentMode = .ScaleAspectFill
            var imageData : NSData!
            let assetPath = info[UIImagePickerControllerReferenceURL] as! NSURL
            print(assetPath.absoluteString)
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
                prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
                prefix.appendContentsOf(kPM_PATH_PHOTO)
                var parameters = [String:AnyObject]()
                parameters = [kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String, kProfilePic: "1"]
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
                                                                 attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
        } else {
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
        }
        if !(self.checkDateChanged(dobContentTF.text!)) {
            returnValue = true
            dobContentTF.attributedText = NSAttributedString(string:dobContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
        } else {
            dobContentTF.attributedText = NSAttributedString(string:dobContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
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
            dateFormatter.dateFormat = kDateFormat
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
            self.emailContentTF.resignFirstResponder()
            self.nameContentTF.resignFirstResponder()
            self.mobileContentTF.resignFirstResponder()
            self.aboutContentTV.resignFirstResponder()
            self.showPopupToSelectGender()
            return false
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
                                                           attributes:[NSForegroundColorAttributeName:  UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(self.emailContentTF) == true {
            if (self.isValidEmail(self.emailContentTF.text!) == false) {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                 attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
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

