//
//  NewCommentImageViewController.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class NewCommentImageViewController: BaseViewController, FusumaDelegate, UITextViewDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var avatarIMV : UIImageView!
    @IBOutlet var commentPhotoTV : UITextView!
    @IBOutlet var imageSelected : UIImageView?
    @IBOutlet weak var imageScrolView : UIScrollView!
    
    var otherKeyboardView: UIView!
    var viewKeyboard: UIView!
    
    var postId: String!
    var isPosting: Bool = false
    let imagePicker = UIImagePickerController()
    var isComment : Bool = false
    
    var selectFromLibrary : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "ADD A COMMENT"
        self.navigationController!.navigationBar.isTranslucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.hidesBackButton = true;
        let image = UIImage(named: "close")!.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action:#selector(SendPhotoViewController.close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "POST", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SendPhotoViewController.post))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], for: .normal)
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
        
        imagePicker.delegate = self
        
        imageScrolView.delegate = self
        imageScrolView.minimumZoomScale = 1
        imageScrolView.maximumZoomScale = 4.0
        imageScrolView.zoomScale = 1.0
        imageScrolView.autoresizingMask = [.FlexibleHeight , .FlexibleWidth]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(NewCommentImageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewCommentImageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        viewKeyboard.removeFromSuperview()
        otherKeyboardView.removeFromSuperview()
        self.commentPhotoTV.resignFirstResponder()
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        viewKeyboard.removeFromSuperview()
        otherKeyboardView.removeFromSuperview()
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
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func post() {
        if (isPosting == false) {
            self.isPosting = true
            self.commentPhotoTV.resignFirstResponder()
            var prefix = kPMAPI_POST
            prefix.append(postId)
            prefix.append("/comments")
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityView.center = self.view.center
            activityView.startAnimating()
            var imageData : NSData!
            let type : String!
            let filename : String!
            imageData = (self.imageSelected?.isHidden != true) ? UIImageJPEGRepresentation(imageSelected!.image!, 0.2) : UIImageJPEGRepresentation(self.cropAndSave(), 0.2)
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
//                                let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                            }
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
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                    case .Failure(_):
                        self.isPosting = false
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
    }
    
    
    @IBAction func showPopupToSelectImage(sender:UIButton!) {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.selectFromLibrary = true
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.showCameraRoll(sender)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.destructive, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    
    @IBAction func showCameraRoll(sender:UIButton!) {
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
    
    func cropAndSave() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageScrolView.bounds.size, true, UIScreen.mainScreen().scale)
        let offset = imageScrolView.contentOffset
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext()!, -offset.x, -offset.y)
        imageScrolView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image!
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
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
