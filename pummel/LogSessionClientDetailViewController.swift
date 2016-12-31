//
//  LogSessionClientDetailViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

class LogSessionClientDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, FusumaDelegate, UITextFieldDelegate {
    var tag: Tag = Tag()
    
    @IBOutlet weak var tappedV: UIView!
    
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var contentTV: UITextView!
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var imageSelected : UIImageView!
    @IBOutlet weak var imageScrolView : UIScrollView!
    
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var hourLB: UILabel!
    @IBOutlet weak var minuteLB: UILabel!
    
    @IBOutlet weak var distanceTF: UITextField!
    @IBOutlet weak var distanceLB: UILabel!
    let distancePickerView = UIPickerView()
    
    @IBOutlet weak var intensityTF: UITextField!
    @IBOutlet weak var intensityLB: UILabel!
    let intensityPickerView = UIPickerView()
    
    @IBOutlet weak var caloriesTF: UITextField!
    
    @IBOutlet weak var hoursTextLB: UILabel!
    @IBOutlet weak var minuteTextLB: UILabel!
    @IBOutlet weak var distanceTextLB: UILabel!
    @IBOutlet weak var mileTextLB: UILabel!
    
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let titleButton = UIButton()
    var coachDetail: NSDictionary!
    let imagePicker = UIImagePickerController()
    var selectFromLibrary : Bool = false
    var intensityTitleArray = [String]()
    var intensitySelected: String = "Light"
    var distanceSelected: String = "0"
    var longtimeSelected: String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initNavigationBar()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LogSessionClientDetailViewController.tappedViewClicked))
        self.tappedV.addGestureRecognizer(tapGesture)
        
        self.timeTF.delegate = self
        self.distanceTF.delegate = self
        self.intensityTF.delegate = self
        self.caloriesTF.delegate = self
        self.timeTF.font = UIFont.pmmMonReg13()
        self.distanceTF.font = UIFont.pmmMonReg13()
        self.intensityTF.font = UIFont.pmmMonReg13()
        self.caloriesTF.font = UIFont.pmmMonReg13()
        self.hourLB.font = UIFont.pmmMonReg13()
        self.minuteLB.font = UIFont.pmmMonReg13()
        self.distanceLB.font = UIFont.pmmMonReg13()
        self.intensityLB.font = UIFont.pmmMonReg13()
        let attributes = [
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName : UIFont.pmmMonReg13()
        ]
        self.hoursTextLB.font =  UIFont.pmmMonReg13()
        self.minuteTextLB.font =  UIFont.pmmMonReg13()
        self.distanceTextLB.font =  UIFont.pmmMonReg13()
        self.mileTextLB.font =  UIFont.pmmMonReg13()
        
        self.caloriesTF.attributedPlaceholder = NSAttributedString(string: "Calories", attributes:attributes)
        self.initInformation()
        self.initTime()
        self.initDistance()
        self.initIntensity()
        
        self.tappedV.userInteractionEnabled = false
        
        self.caloriesTF.keyboardAppearance = .Dark
        self.imagePicker.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hourLB.text = "0"
        self.minuteLB.text = "0"
        self.titleButton.titleLabel?.font = UIFont.pmmMonReg13()
        self.titleButton.setTitleColor(UIColor(white: 32.0 / 255.0, alpha: 1.0), forState: .Normal)
        self.titleButton.setTitle(String(format: "#%@", (self.tag.name?.uppercaseString)!), forState: .Normal)
        self.titleButton.sizeToFit()
        self.titleButton.addTarget(self, action: #selector(self.titleButtonClicked), forControlEvents: .TouchUpInside)
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar!.addSubview(self.titleButton)
        
        self.titleButton.frame = CGRectMake(((navigationBar?.frame.width)! - self.titleButton.frame.width) / 2,
                                            0,
                                            self.titleButton.frame.width,
                                            (navigationBar?.frame.height)!)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.titleButton.removeFromSuperview()
    }
    
    // MARK: Init
    func initNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(LogSessionClientDetailViewController.backClicked))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kSave.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.saveClicked))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
    }
    
    func initInformation() {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        datePickerView.backgroundColor = UIColor.blackColor()
        datePickerView.setValue(UIColor.whiteColor(), forKey: "textColor")
        dateTF.inputView = datePickerView
        dateTF.font = UIFont.pmmMonReg13()
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.getDetail()
        
        self.contentTV.text = "ADD A COMMENT..."
        self.contentTV.font = UIFont.pmmMonReg13()
        self.contentTV.keyboardAppearance = .Dark
        self.contentTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
        self.contentTV.delegate = self
        self.contentTV.selectedTextRange = self.contentTV.textRangeFromPosition(  self.contentTV.beginningOfDocument, toPosition:self.contentTV.beginningOfDocument)
    }
    
    func initTime() {
        let timePickerView  : UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = .Time
        timePickerView.backgroundColor = UIColor.blackColor()
        timePickerView.setValue(UIColor.whiteColor(), forKey: "textColor")
        timePickerView.locale = NSLocale(localeIdentifier: "en_GB")
        timeTF.inputView = timePickerView
        timePickerView.addTarget(self, action: #selector(self.handleTimePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.setTimeLBWithDate(NSDate())
    }
    
    func initDistance() {
        self.distancePickerView.delegate = self
        self.distancePickerView.dataSource = self
        self.distancePickerView.backgroundColor = UIColor.blackColor()
        distanceTF.inputView = self.distancePickerView
    }
    
    func initIntensity() {
        self.intensityPickerView.delegate = self
        self.intensityPickerView.dataSource = self
        self.intensityPickerView.backgroundColor = UIColor.blackColor()
        intensityTF.inputView = self.intensityPickerView
        
        self.intensityTitleArray.append("Light")
        self.intensityTitleArray.append("Moderate")
        self.intensityTitleArray.append("Vigorous")
    }
    
    
    // MARK: Private function
    func tappedViewClicked() {
        self.timeTF.resignFirstResponder()
        self.contentTV.resignFirstResponder()
        self.caloriesTF.resignFirstResponder()
        self.distanceTF.resignFirstResponder()
        self.intensityTF.resignFirstResponder()
        self.tappedV.userInteractionEnabled = false
    }
    
    func convertLocalTimeToUTCTime(dateTimeString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm aaa"
        
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "MMM dd, yyyy hh:mm aaa"
        newDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let newDateString = newDateFormatter.stringFromDate(date!)
        
        return newDateString
    }
    
    func backClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func titleButtonClicked() {
        
    }
    
    func saveClicked() {
        if (self.dateTF.text == "" || self.dateTF.text == "ADD A DATE") {
            
            let alertController = UIAlertController(title: pmmNotice, message: pleaseInputADate, preferredStyle: .Alert)
            
            
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        } else {
            self.view.makeToastActivity(message: "Saving")
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPM_PATH_ACTIVITIES_USER)
            
            var imageData : NSData!
            let type : String! = imageJpeg
            let filename : String! = jpgeFile
            
            let calorieSelected : String = String((self.caloriesTF.text != "") ? Int(self.caloriesTF.text!)! : 0)
            let selectedDate = self.convertLocalTimeToUTCTime(self.dateTF.text!)
            let parameters = [
                kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String,
                "text" : (self.contentTV.text != "ADD A COMMENT...") ? self.contentTV.text : "...",
                "type" :String(format: "#%@", (self.tag.name?.uppercaseString)!),
                "intensity": self.intensitySelected,
                "distance" : self.distanceSelected,
                "longtime" : self.longtimeSelected,
                "calorie" :  calorieSelected,
                "datetime":  selectedDate
            ]

            
            if (self.imageSelected.image != nil) {
                imageData = (self.imageSelected?.hidden != true) ? UIImageJPEGRepresentation(imageSelected!.image!, 0.2) : UIImageJPEGRepresentation(self.cropAndSave(), 0.2)
            }
            
            
            Alamofire.upload(
                .POST,
                prefix,
                multipartFormData: { multipartFormData in
                    if (self.imageSelected.image != nil) {
                        multipartFormData.appendBodyPart(data: imageData, name: "file",
                            fileName:filename, mimeType:type)
                    }

                    for (key, value) in parameters {
                        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key )
                    }
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        
                        upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                            dispatch_async(dispatch_get_main_queue()) {
                                //                            let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                            }
                        }
                        upload.validate()
                        upload.responseJSON { response in
                            self.view.hideToastActivity()
                            if response.result.error != nil {
                                let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .Alert)
                                
                                
                                let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                                    // ...
                                }
                                alertController.addAction(OKAction)
                                self.presentViewController(alertController, animated: true) {
                                    // ...
                                }
                            } else {
                                self.navigationController?.popToRootViewControllerAnimated(false)
                            }
                        }
                        
                    case .Failure( _):
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
            )
        }
    }
    
    func cropAndSave() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageScrolView.bounds.size, true, UIScreen.mainScreen().scale)
        let offset = imageScrolView.contentOffset
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext()!, -offset.x, -offset.y)
        imageScrolView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image!
    }

    func setTimeLBWithDate(date: NSDate) {
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH"
        hourLB.text = timeFormatter.stringFromDate(date)
        
        timeFormatter.dateFormat = "mm"
        minuteLB.text = timeFormatter.stringFromDate(date)
        let total = Int(hourLB.text!)!*60 + Int(minuteLB.text!)!
        self.longtimeSelected = String(total)
    }
    
    func getDetail() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    if (response.result.value == nil) {return}
                    self.coachDetail = response.result.value as! NSDictionary
                    self.setAvatar()
                } else if response.response?.statusCode == 401 {
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
    }
    
    func setAvatar() {
        if !(coachDetail[kImageUrl] is NSNull) {
            let imageLink = coachDetail[kImageUrl] as! String
            var prefix = kPMAPI
            prefix.appendContentsOf(imageLink)
            let postfix = widthEqual.stringByAppendingString(avatarIMV.frame.size.width.description).stringByAppendingString(heighEqual).stringByAppendingString(avatarIMV.frame.size.width.description)
            prefix.appendContentsOf(postfix)
            if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                self.avatarIMV.image = imageRes
            } else {
                Alamofire.request(.GET, prefix)
                    .responseImage { response in
                        if (response.response?.statusCode == 200) {
                            let imageRes = response.result.value! as UIImage
                            self.avatarIMV.image = imageRes
                            NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                        }
                }
            }
        }
    }
    
    @IBAction func showPopupToSelectImage(sender: AnyObject) {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.showCameraRoll()
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.Default, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.Default, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "MMM dd, YYYY hh:mm aaa"
        dateTF.text = timeFormatter.stringFromDate(sender.date)
    }
    
    func handleTimePicker(sender: UIDatePicker) {
        self.setTimeLBWithDate(sender.date)
    }
    
    func showCameraRoll() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.defaultMode = .Camera
        fusuma.modeOrder = .CameraFirst
        self.presentViewController(fusuma, animated: true, completion: nil)
    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.distancePickerView {
            return 100;
        }
        
        if pickerView == self.intensityPickerView {
            return 3;
        }
        
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        
        if pickerView == self.distancePickerView {
            title = String(format: "%ld", row)
            self.distanceSelected = title
        }
        
        if pickerView == self.intensityPickerView {
            title = self.intensityTitleArray[row]
            self.intensitySelected = title
        }
        
        let attString = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        return attString;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.distancePickerView {
            return String(format: "%ld", row)
        }
        
        if pickerView == self.intensityPickerView {
            return self.intensityTitleArray[row]
        }
        
        return "";
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.distancePickerView {
            self.distanceLB.text = String(format: "%ld", row)
        }
        
        if pickerView == self.intensityPickerView {
            self.intensityLB.text = self.intensityTitleArray[row]
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.tappedV.userInteractionEnabled = true
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.intensityPickerView.reloadAllComponents()
        
    }
    
    // MARK: UITextViewDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.tappedV.userInteractionEnabled = true
        
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        if updatedText.isEmpty {
            
            textView.text = addAComment
            textView.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
        else if textView.textColor == UIColor(white:204.0/255.0, alpha: 1.0) && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.pmmWarmGreyTwoColor()
        }
        
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor ==  UIColor(white:204.0/255.0, alpha: 1.0) {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
    }
    
    // MARK: Fusuma delegate
    func fusumaImageSelected(image: UIImage) {
        self.imageSelected.image = image
        if (self.selectFromLibrary == true) {
            self.imageScrolView.hidden = true
            self.imageSelected?.hidden = false
        } else {
            for(subview) in self.imageScrolView.subviews {
                subview.removeFromSuperview()
            }
            let height =  self.view.frame.size.width*image.size.height/image.size.width
            let frameT = (height > self.view.frame.width) ? CGRectMake(0, 0, self.view.frame.size.width, height) : CGRectMake(0, (self.view.frame.size.width - height)/2, self.view.frame.size.width, height)
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = image
            self.imageScrolView.addSubview(imageViewScrollView)
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSizeMake(self.view.frame.size.width, frameT.size.height) : CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)
            self.imageSelected?.hidden = true
            self.imageScrolView?.hidden = false
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
        let alert = UIAlertController(title: accessRequested, message: savingImageNeedsToAccessYourPhotoAlbum, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: kCancle, style: .Cancel, handler: { (action) -> Void in
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            for(subview) in self.imageScrolView.subviews {
                subview.removeFromSuperview()
            }
            self.imageSelected!.image = pickedImage
            let height =  self.view.frame.size.width*pickedImage.size.height/pickedImage.size.width
            let frameT = (height > self.view.frame.width) ? CGRectMake(0, 0, self.view.frame.size.width, height) : CGRectMake(0, (self.view.frame.size.width - height)/2, self.view.frame.size.width, height)
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = pickedImage
            self.imageScrolView.addSubview(imageViewScrollView)
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSizeMake(self.view.frame.size.width, frameT.size.height) : CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)
            self.imageSelected?.hidden = true
            self.imageScrolView?.hidden = false
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
