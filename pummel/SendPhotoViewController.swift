//
//  SendPhotoViewController.swift
//  pummel
//
//  Created by Bear Daddy on 5/23/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import Mixpanel

class SendPhotoViewController: BaseViewController, FusumaDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var avatarIMV : UIImageView!
    @IBOutlet weak var commentPhotoTV : UITextView!
    @IBOutlet weak var imageSelected : UIImageView?
    @IBOutlet weak var imageScrolView : UIScrollView!
    
    var typeCoach : Bool = false
    var coachId: String!
    var userIdTarget: NSString!
    var messageId: NSString!
    var arrayChat: NSArray!
    var otherKeyboardView: UIView!
    var viewKeyboard: UIView!
    let imagePicker = UIImagePickerController()
    var selectFromLibrary : Bool = false
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kNavSendPhoto
        self.navigationController!.navigationBar.isTranslucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
         self.navigationItem.hidesBackButton = true;
        let image = UIImage(named: "close")!.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action:#selector(SendPhotoViewController.close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "POST", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SendPhotoViewController.post))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], for: .normal)
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.setAvatar()
        self.commentPhotoTV.text = addAComment
        self.commentPhotoTV.font = UIFont.pmmMonReg13()
        self.commentPhotoTV.keyboardAppearance = .dark
        self.commentPhotoTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
        self.commentPhotoTV.delegate = self
        self.commentPhotoTV.selectedTextRange = self.commentPhotoTV.textRange(from:   self.commentPhotoTV.beginningOfDocument, toPosition:self.commentPhotoTV.beginningOfDocument)
        self.navigationItem.hidesBackButton = true;
        self.imagePicker.delegate = self
        
        imageScrolView.delegate = self
        imageScrolView.minimumZoomScale = 1
        imageScrolView.maximumZoomScale = 4.0
        imageScrolView.zoomScale = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(SendPhotoViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SendPhotoViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        if  (self.viewKeyboard != nil) {
            self.viewKeyboard.removeFromSuperview()
        }
        viewKeyboard = UIView.init(frame:CGRect(x: 0, y: self.view.frame.height - keyboardHeight, width: self.view.frame.width, height: keyboardHeight))
        viewKeyboard.backgroundColor = UIColor.black
        viewKeyboard.isHidden = true
        self.view.addSubview(viewKeyboard)
        self.viewKeyboard.isHidden = false
        if  (self.otherKeyboardView != nil) {
            self.otherKeyboardView.removeFromSuperview()
        }
        self.otherKeyboardView = UIView.init(frame:CGRect(x: 0, y: self.commentPhotoTV.frame.origin.y, width: self.view.frame.width, height: self.view.frame.size.height - self.commentPhotoTV.frame.origin.y))
        self.otherKeyboardView.backgroundColor = UIColor.clear
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(SendPhotoViewController.handleTap(_:)))
        self.otherKeyboardView.addGestureRecognizer(recognizer)
        self.view.addSubview(self.otherKeyboardView)
        self.viewKeyboard.backgroundColor = UIColor.black
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        if viewKeyboard != nil && viewKeyboard.superview != nil {
            viewKeyboard.removeFromSuperview()
            otherKeyboardView.removeFromSuperview()
            self.commentPhotoTV.resignFirstResponder()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if viewKeyboard != nil && viewKeyboard.superview != nil {
            viewKeyboard.removeFromSuperview()
            otherKeyboardView.removeFromSuperview()
        }
    }
    
    func setAvatar() {
        ImageRouter.getCurrentUserAvatar(sizeString: widthHeight120) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.avatarIMV.image = imageRes
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0] as! UIImageView
    }
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func post() {
        self.view.makeToast(message: "Sending")
        if (self.messageId != nil) {
            self.addMessageToExistConverstation()
        } else {
            self.sendMessage()
        }
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Send A Photo"]
        mixpanel.track("IOS.ChatMessage.SendPhoto", properties: properties)
    }
    
    func sendMessage() {
        self.commentPhotoTV.resignFirstResponder()
        let values : [String]
        
        if (self.typeCoach == true) {
            values = [coachId]
        } else {
            values = [userIdTarget as String]
        }
        
        var prefix = kPMAPIUSER
        prefix.append(PMHelper.getCurrentID())
        prefix.append(kPM_PATH_CONVERSATION)
        prefix.append("/")
        
        let param = [kUserId : PMHelper.getCurrentID(),
                     kUserIds : values]
        
        Alamofire.request(.POST, prefix, parameters: param as? [String : AnyObject])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    let JSON = response.result.value
                    let conversationId = String(format:"%0.f",JSON!.object(forKey: kId)!.doubleValue)
                    
                    self.messageId = conversationId
                    self.addMessageToExistConverstation()
                } 
        }
        
    }
    
    func addMessageToExistConverstation(){
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        var prefix = kPMAPIUSER
        prefix.append(PMHelper.getCurrentID())
        prefix.append(kPM_PATH_CONVERSATION)
        prefix.append("/")
        prefix.append(self.messageId as String)
        prefix.append(kPM_PARTH_MESSAGE_V2)
        
        imageSelected?.image?.CGImage
        var imageData : NSData!
        let type : String!
        let filename : String!
        imageData = (self.imageSelected?.isHidden != true) ? UIImageJPEGRepresentation(imageSelected!.image!, 0.2) : UIImageJPEGRepresentation(self.cropAndSave(), 0.2)
        type = imageJpeg
        filename = jpgeFile
        let textPost = (commentPhotoTV.text == nil || commentPhotoTV.text == addAComment) ? "" : commentPhotoTV.text
        var parameters = [String:AnyObject]()
        parameters = [kConversationId:self.messageId as String, kText: textPost]
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
                 self.view.hideToastActivity()
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                    }
                    upload.validate()
                    upload.responseJSON { response in
                        
                        if response.result.error != nil {
                            activityView.stopAnimating()
                            activityView.removeFromSuperview()
                            let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                                // ...
                            }
                            alertController.addAction(OKAction)
                            self.present(alertController, animated: true) {
                                // ...
                            }
                        } else {
                            activityView.stopAnimating()
                            activityView.removeFromSuperview()
                            let dateFormatter = DateFormatter
                            dateFormatter.dateFormat = kFullDateFormat
                            dateFormatter.timeZone = NSTimeZone(name: "UTC")
                            let dayCurrent = dateFormatter.string(from: NSDate())
                            
                            var prefixT = kPMAPIUSER
                            prefixT.append(PMHelper.getCurrentID())
                            prefixT.append(kPM_PATH_CONVERSATION)
                            prefixT.append("/")
                            prefixT.append(self.messageId as String)
                            
                            let param = [kConversationId:self.messageId as String,
                                kLastOpenAt:dayCurrent,
                                kUserId: PMHelper.getCurrentID()]
                            
                            Alamofire.request(.PUT, prefixT, parameters: param)
                                .responseJSON { response in
                                    if response.response?.statusCode == 200 {
                                        print ("Set lastOpenAt to New")
                                    }
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                case .Failure(let encodingError):
                    print(encodingError)
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
                        // ...
                    }
                }
            }
        )
    }
    
    @IBAction func showPopupToSelectImageWithSender() {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Fusuma delegate
    func fusumaImageSelected(image: UIImage) {
        self.imageSelected!.image = image
        if (self.selectFromLibrary == true) {
            self.imageScrolView.isHidden = true
            self.imageSelected?.isHidden = false
        } else {
            for(subview) in self.imageScrolView.subviews {
                subview.removeFromSuperview()
            }
            let height =  self.view.frame.size.width*image.size.height/image.size.width
            let frameT = (height > self.view.frame.width) ? CGRectMake(0, 0, self.view.frame.size.width, height) : CGRectMake(0, (self.view.frame.size.width - height)/2, self.view.frame.size.width, height)
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = image
            self.imageScrolView.addSubview(imageViewScrollView)
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSize(x:self.view.frame.size.width, frameT.size.height) : CGSize(x:self.view.frame.size.width, self.view.frame.size.width)
            self.imageSelected?.isHidden = true
            self.imageScrolView?.isHidden = false
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
        let alert = UIAlertController(title: accessRequested, message: savingImageNeedsToAccessYourPhotoAlbum, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: kCancle, style: .Cancel, handler: { (action) -> Void in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        if updatedText.isEmpty {
            
            textView.text = addAComment
            textView.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
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
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
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
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSize(x:self.view.frame.size.width, frameT.size.height) : CGSize(x:self.view.frame.size.width, self.view.frame.size.width)
            self.imageSelected?.isHidden = true
            self.imageScrolView?.isHidden = false
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cropAndSave() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageScrolView.bounds.size, true, UIScreen.mainScreen().scale)
        let offset = imageScrolView.contentOffset
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext()!, -offset.x, -offset.y)
        imageScrolView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image!
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
