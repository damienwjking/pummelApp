//
//  SendPhotoViewController.swift
//  pummel
//
//  Created by Bear Daddy on 5/23/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class SendPhotoViewController: UIViewController, FusumaDelegate, UITextViewDelegate {
    
    @IBOutlet var avatarIMV : UIImageView!
    @IBOutlet var commentPhotoTV : UITextView!
    @IBOutlet var imageSelected : UIImageView?
    var typeCoach : Bool = false
    var coachId: String!
    var userIdTarget: NSString!
    var messageId: NSString!
    var arrayChat: NSArray!
    var otherKeyboardView: UIView!
    var viewKeyboard: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.title = "SEND PHOTO"
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
         self.navigationItem.hidesBackButton = true;
        let image = UIImage(named: "close")!.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action:#selector(SendPhotoViewController.close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "POST", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SendPhotoViewController.post))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.setAvatar()
        self.commentPhotoTV.text = "ADD A COMMENT..."
        self.commentPhotoTV.keyboardAppearance = .Dark
        self.commentPhotoTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
        self.commentPhotoTV.delegate = self
        self.commentPhotoTV.selectedTextRange = self.commentPhotoTV.textRangeFromPosition(  self.commentPhotoTV.beginningOfDocument, toPosition:self.commentPhotoTV.beginningOfDocument)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.navigationItem.hidesBackButton = true;
       
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
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.commentPhotoTV.resignFirstResponder()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        viewKeyboard.removeFromSuperview()
        otherKeyboardView.removeFromSuperview()
    }
    
    func setAvatar() {
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        prefix.appendContentsOf("/photos")
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                print(JSON)
                let listPhoto = JSON as! NSArray
                if (listPhoto.count >= 1) {
                    let photo = listPhoto[0] as! NSDictionary
                    var link = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
                    link.appendContentsOf(photo.objectForKey("imageUrl") as! String)
                    link.appendContentsOf("?width=80&height=80")
                    
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
        if (self.messageId != nil) {
            self.addMessageToExistConverstation()
        } else {
            self.sendMessage()
        }
    }
    
    func sendMessage() {
        self.commentPhotoTV.resignFirstResponder()
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let values : [String]
//        
//        if (self.typeCoach == true) {
//            values = [coachId]
//        } else {
//            values = [userIdTarget as String]
//        }
//        
//        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
//        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
//        prefix.appendContentsOf("/conversations/")
//        Alamofire.request(.POST, prefix, parameters: ["userId":defaults.objectForKey("currentId") as! String, "userIds":values])
//            .responseJSON { response in
//                if response.response?.statusCode == 200 {
//                    let JSON = response.result.value
//                    print("JSON: \(JSON)")
//                    let conversationId = String(format:"%0.f",JSON!.objectForKey("id")!.doubleValue)
//                    
//                    //Add message to converstaton
//                    self.messageId = conversationId
//                    self.addMessageToExistConverstation()
//                } else {
//                    print(response.response?.statusCode)
//                }
//        }
        
    }
    
    func addMessageToExistConverstation(){
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        prefix.appendContentsOf("/conversations/")
        prefix.appendContentsOf(self.messageId as String)
        prefix.appendContentsOf("/messages")
        
        imageSelected?.image?.CGImage
        var imageData : NSData!
        let type : String!
        let filename : String!
        imageData = UIImageJPEGRepresentation(imageSelected!.image!, 0.2)
        type = "image/jpeg"
        filename = "imagefile.jpeg"
       

        let textPost = (commentPhotoTV.text == nil) ? "" : commentPhotoTV.text
        
        var parameters = [String:AnyObject]()
        parameters = ["conversationId":self.messageId as String, "text": textPost]
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
                        dispatch_async(dispatch_get_main_queue()) {
                            let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                            //progress(percent: percent)
                            print(percent)
                        }
                    }
                    upload.validate()
                    upload.responseJSON { response in
                        
                        if response.result.error != nil {
                            activityView.stopAnimating()
                            activityView.removeFromSuperview()
                            let alertController = UIAlertController(title: "Send Photo Issues", message: "Please do it again", preferredStyle: .Alert)
                            
                            
                            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
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
                    print(encodingError)
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()

                    let alertController = UIAlertController(title: "Send Photo Issues", message: "Please do it again", preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
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
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "ADD A COMMENT..."
            textView.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor(white:204.0/255.0, alpha: 1.0) && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor(white: 151.0 / 255.0, alpha: 1.0)
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
    
}

extension NSData {
    var dataType: String? {
        
        // Ensure data length is at least 1 byte
        guard self.length > 0 else { return nil }
        
        // Get first byte
        var c = [UInt8](count: 1, repeatedValue: 0)
        c.withUnsafeMutableBufferPointer { buffer in
            getBytes(buffer.baseAddress, length: 1)
        }
        
        // Identify data type
        switch (c[0]) {
        case 0xFF:
            return "jpg"
        case 0x89:
            return "png"
        case 0x47:
            return "gif"
        case 0x49, 0x4D:
            return "tiff"
        default:
            return nil //unknown
        }
    }
}
