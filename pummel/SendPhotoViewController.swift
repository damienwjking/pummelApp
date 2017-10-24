//
//  SendPhotoViewController.swift
//  pummel
//
//  Created by Bear Daddy on 5/23/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Mixpanel

class SendPhotoViewController: BaseViewController {
    
    @IBOutlet weak var avatarIMV : UIImageView!
    @IBOutlet weak var commentPhotoTV : UITextView!
    @IBOutlet weak var imageSelected : UIImageView?
    @IBOutlet weak var imageScrolView : UIScrollView!
    
    var typeCoach : Bool = false
    var coachId: String!
    var userIdTarget: NSString!
    var messageId: String!
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "POST", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.post))
        self.navigationItem.rightBarButtonItem?.setAttributeForAllStage()
        
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.setAvatar()
        self.commentPhotoTV.text = addAComment
        self.commentPhotoTV.font = UIFont.pmmMonReg13()
        self.commentPhotoTV.keyboardAppearance = .dark
        self.commentPhotoTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
        self.commentPhotoTV.delegate = self
        self.commentPhotoTV.selectedTextRange = self.commentPhotoTV.textRange(from:   self.commentPhotoTV.beginningOfDocument, to:self.commentPhotoTV.beginningOfDocument)
        self.navigationItem.hidesBackButton = true;
        self.imagePicker.delegate = self
        
        imageScrolView.delegate = self
        imageScrolView.minimumZoomScale = 1
        imageScrolView.maximumZoomScale = 4.0
        imageScrolView.zoomScale = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
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
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.handleTap(recognizer:)))
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
        ImageVideoRouter.getCurrentUserAvatar(sizeString: widthHeight120) { (result, error) in
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
        mixpanel?.track("IOS.ChatMessage.SendPhoto", properties: properties)
    }
    
    func sendMessage() {
        self.commentPhotoTV.resignFirstResponder()
        let values : String
        
        if (self.typeCoach == true) {
            values = self.coachId
        } else {
            values = self.userIdTarget as String
        }
        
        MessageRouter.createConversationWithUser(userID: values) { (result, error) in
            if (error == nil) {
                let JSON = result as! NSDictionary
                let conversationId = String(format:"%0.f", (JSON.object(forKey: kId)! as AnyObject).doubleValue)
                
                self.messageId = conversationId
                self.addMessageToExistConverstation()
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func addMessageToExistConverstation() {
        var imageData : Data!
        imageData = (self.imageSelected?.isHidden != true) ? UIImageJPEGRepresentation(imageSelected!.image!, 0.2) : UIImageJPEGRepresentation(self.cropAndSave(), 0.2)
        
        let textPost = (commentPhotoTV.text == nil || commentPhotoTV.text == addAComment) ? "" : commentPhotoTV.text
        
        let messageID = "\(self.messageId!)"
        MessageRouter.sendMessage(conversationID: messageID, text: textPost!, imageData: imageData) { (result, error) in
            self.view.hideToastActivity()
            
            if (error == nil) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = kFullDateFormat
                dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
                let dayCurrent = dateFormatter.string(from: Date())
                
                let param = [kConversationId:self.messageId as String,
                             kLastOpenAt:dayCurrent,
                             kUserId: PMHelper.getCurrentID()]
                
                MessageRouter.updateMessageDetail(messageID: self.messageId as String, param: param, completed: { (result, error) in
                    self.navigationController?.popViewController(animated: true)
                }).fetchdata()
            } else {
                print("Request failed with error: \(String(describing: error))")
                
                PMHelper.showDoAgainAlert()
            }
        }.fetchdata()
    }
    
    @IBAction func showPopupToSelectImageWithSender() {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
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
}

// MARK: - UITextViewDelegate
extension SendPhotoViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:NSString = textView.text! as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        if updatedText.isEmpty {
            
            textView.text = addAComment
            textView.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
        else if textView.textColor == UIColor(white:204.0/255.0, alpha: 1.0) && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.pmmWarmGreyTwoColor()
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor ==  UIColor(white:204.0/255.0, alpha: 1.0) {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension SendPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            for(subview) in self.imageScrolView.subviews {
                subview.removeFromSuperview()
            }
            self.imageSelected!.image = pickedImage
            let height =  self.view.frame.size.width*pickedImage.size.height/pickedImage.size.width
            let frameT = (height > self.view.frame.width) ? CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height) : CGRect(x: 0, y: (self.view.frame.size.width - height)/2, width: self.view.frame.size.width, height: height)
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = pickedImage
            self.imageScrolView.addSubview(imageViewScrollView)
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSize(width: self.view.frame.size.width, height: frameT.size.height) : CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
            self.imageSelected?.isHidden = true
            self.imageScrolView?.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - FusumaDelegate
extension SendPhotoViewController: FusumaDelegate, UIScrollViewDelegate {
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
            let frameT = (height > self.view.frame.width) ? CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height) : CGRect(x: 0, y: (self.view.frame.size.width - height)/2, width: self.view.frame.size.width, height: height)
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = image
            self.imageScrolView.addSubview(imageViewScrollView)
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSize(width: self.view.frame.size.width, height: frameT.size.height) : CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
            self.imageSelected?.isHidden = true
            self.imageScrolView?.isHidden = false
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
        let alert = UIAlertController(title: accessRequested, message: savingImageNeedsToAccessYourPhotoAlbum, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: kCancle, style: .cancel, handler: { (action) -> Void in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func cropAndSave() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageScrolView.bounds.size, true, UIScreen.main.scale)
        let offset = imageScrolView.contentOffset
        
        UIGraphicsGetCurrentContext()!.translateBy(x: -offset.x, y: -offset.y)
        imageScrolView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image!
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
}
