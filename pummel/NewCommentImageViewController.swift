//
//  NewCommentImageViewController.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class NewCommentImageViewController: UIViewController, FusumaDelegate, UITextViewDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var avatarIMV : UIImageView!
    @IBOutlet var commentPhotoTV : UITextView!
    @IBOutlet var imageSelected : UIImageView?
    var otherKeyboardView: UIView!
    var viewKeyboard: UIView!
    
    var postId: String!
    var isPosting: Bool = false
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "NEW POST"
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.hidesBackButton = true;
        let image = UIImage(named: "close")!.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action:#selector(SendPhotoViewController.close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "POST", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SendPhotoViewController.post))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.setAvatar()
        self.commentPhotoTV.text = addAComment
        self.commentPhotoTV.keyboardAppearance = .Dark
        self.commentPhotoTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
        self.commentPhotoTV.delegate = self
        self.commentPhotoTV.selectedTextRange = self.commentPhotoTV.textRangeFromPosition(  self.commentPhotoTV.beginningOfDocument, toPosition:self.commentPhotoTV.beginningOfDocument)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewCommentImageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewCommentImageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.navigationItem.hidesBackButton = true;
        
        imagePicker.delegate = self
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        viewKeyboard = UIView.init(frame:CGRect(x: 0, y: self.view.frame.height - keyboardHeight, width: self.view.frame.width, height: keyboardHeight))
        viewKeyboard.backgroundColor = UIColor.blackColor()
        viewKeyboard.hidden = true
        self.view.addSubview(viewKeyboard)
        self.viewKeyboard.hidden = false
        self.otherKeyboardView = UIView.init(frame:CGRect(x: 0, y: self.commentPhotoTV.frame.origin.y, width: self.view.frame.width, height: self.view.frame.size.height - self.commentPhotoTV.frame.origin.y))
        self.otherKeyboardView.backgroundColor = UIColor.clearColor()
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(SendPhotoViewController.handleTap(_:)))
        self.otherKeyboardView.addGestureRecognizer(recognizer)
        self.view.addSubview(self.otherKeyboardView)
        self.viewKeyboard.backgroundColor = UIColor.blackColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.commentPhotoTV.resignFirstResponder()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        viewKeyboard.removeFromSuperview()
        otherKeyboardView.removeFromSuperview()
    }
    
    func setAvatar() {
        var prefix = kPMAPIUSER
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetail = JSON as! NSDictionary
                if !(userDetail[kImageUrl] is NSNull) {
                    var link = kPMAPI
                    link.appendContentsOf(userDetail[kImageUrl] as! String)
                    link.appendContentsOf(widthHeight80)
                    
                    if (NSCache.sharedInstance.objectForKey(link) != nil) {
                        let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                        self.avatarIMV.image = imageRes
                    } else {
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                self.avatarIMV.image = imageRes
                                NSCache.sharedInstance.setObject(imageRes, forKey: link)
                        }
                    }
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func close() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func post() {
        if (isPosting == false) {
            self.isPosting = true
            self.commentPhotoTV.resignFirstResponder()
            var prefix = kPMAPI_POST
            prefix.appendContentsOf(postId)
            prefix.appendContentsOf("/comments")
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityView.center = self.view.center
            activityView.startAnimating()
            var imageData : NSData!
            let type : String!
            let filename : String!
            imageData = UIImageJPEGRepresentation(imageSelected!.image!, 0.2)
            type = imageJpeg
            filename = jpgeFile
            let textPost = (commentPhotoTV.text == nil || commentPhotoTV.text == addAComment) ? "..." : commentPhotoTV.text
            var parameters = [String:AnyObject]()
            parameters = [kPostId:postId, kText: textPost]
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
                        self.isPosting = false
                        upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                            dispatch_async(dispatch_get_main_queue()) {
                                let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                                print(percent)
                            }
                        }
                        upload.validate()
                        upload.responseJSON { response in
                            
                            if response.result.error != nil {
                                activityView.stopAnimating()
                                activityView.removeFromSuperview()
                                let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .Alert)
                                
                                
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
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        }
                        
                    case .Failure(let encodingError):
                        self.isPosting = false
                        print(encodingError)
                        activityView.stopAnimating()
                        activityView.removeFromSuperview()
                        
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
    
    
    @IBAction func showPopupToSelectImage(sender:UIButton!) {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.showCameraRoll(sender)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.Default, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.Default, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    
    @IBAction func showCameraRoll(sender:UIButton!) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.defaultMode = .Camera
        fusuma.modeOrder = .CameraFirst
        self.presentViewController(fusuma, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Fusuma delegate
    func fusumaImageSelected(image: UIImage) {
        print("Image selected")
        self.imageSelected!.image = image
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.imageSelected?.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
