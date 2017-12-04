//
//  NewPostViewController.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class NewPostViewController: BaseViewController {

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
    var isPosting : Bool = false
    let imagePicker = UIImagePickerController()
    
    var selectFromLibrary : Bool = false
    
    // MARK: - Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "NEW POST"
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
        self.commentPhotoTV.selectedTextRange = self.commentPhotoTV.textRange(from: self.commentPhotoTV.beginningOfDocument, to:self.commentPhotoTV.beginningOfDocument)
        self.navigationItem.hidesBackButton = true;
        imagePicker.delegate = self
        
        imageScrolView.delegate = self
        imageScrolView.minimumZoomScale = 1
        imageScrolView.maximumZoomScale = 4.0
        imageScrolView.zoomScale = 1.0
        imageScrolView.autoresizingMask = [.flexibleHeight , .flexibleWidth]
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
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.otherKeyBoardViewTapped(recognizer:)))
        self.otherKeyboardView.addGestureRecognizer(recognizer)
        self.view.addSubview(self.otherKeyboardView)
        self.viewKeyboard.backgroundColor = UIColor.black
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (self.viewKeyboard != nil) {
            viewKeyboard.removeFromSuperview()
            otherKeyboardView.removeFromSuperview()
        }
    }
    
    func otherKeyBoardViewTapped(recognizer: UITapGestureRecognizer) {
        if (self.viewKeyboard != nil) {
            viewKeyboard.removeFromSuperview()
            otherKeyboardView.removeFromSuperview()
            self.commentPhotoTV.resignFirstResponder()
        }
    }
    
    func setAvatar() {
        ImageVideoRouter.getCurrentUserAvatar(sizeString: widthHeight200) { (result, error) in
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
        if (self.isPosting == true) {
            return
        }
        
        if (self.imageSelected!.image != nil) {
            self.commentPhotoTV.resignFirstResponder()
            
            var imageData : NSData!
            imageData = (self.imageSelected?.isHidden != true) ? UIImageJPEGRepresentation(imageSelected!.image!, 0.2)! as NSData : UIImageJPEGRepresentation(self.cropAndSave(), 0.2)! as NSData
            
            let textPost = (commentPhotoTV.text == nil || commentPhotoTV.text == addAComment) ? "..." : commentPhotoTV.text
            
            self.isPosting = true
            self.view.makeToastActivity(message: "Posting")
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
            ImageVideoRouter.uploadPhoto(posfix: "/posts/", imageData: imageData as Data, textPost: textPost!, completed: { (result, error) in
                self.isPosting = false
                self.view.hideToastActivity()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addNewPostNotification"), object: nil)
                
                let isUploadSuccess = result as! Bool
                if (isUploadSuccess == true) {
                   self.navigationController?.popViewController(animated: true)
                } else {
                    PMHelper.showDoAgainAlert()
                }
            }).fetchdata()
        }
    }
    
    
    @IBAction func showPopupToSelectImage(_ sender: Any) {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.selectFromLibrary = true
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
           self.showCameraRoll(sender: sender)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.destructive, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if scrollView is UITextView {
            return nil
        }
        return scrollView.subviews[0] as! UIImageView
    }

    
    @IBAction func showCameraRoll(_ sender: Any) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.defaultMode = .Camera
        fusuma.modeOrder = .CameraFirst
        self.present(fusuma, animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate
extension NewPostViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText = textView.text! as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = addAComment
            textView.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate
extension NewPostViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            for subview in self.imageScrolView.subviews {
                subview.removeFromSuperview()
            }
            self.imageSelected!.image = pickedImage
            let height =  self.view.frame.size.width*pickedImage.size.height/pickedImage.size.width
            let frameT = (height > self.view.frame.width) ? CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height) : CGRect(x: 0, y: (self.view.frame.size.width - height)/2, width: self.view.frame.size.width, height: height)
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = pickedImage
            self.imageScrolView.addSubview(imageViewScrollView)
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSize(width:self.view.frame.size.width, height: frameT.size.height) : CGSize(width:self.view.frame.size.width, height:self.view.frame.size.width)
            
            self.imageSelected?.isHidden = true
            self.imageScrolView?.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - FusumaDelegate
extension NewPostViewController : FusumaDelegate, UIScrollViewDelegate {
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
            let frameT = (height > self.view.frame.width) ? CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height) : CGRect(x: 0, y: (self.view.frame.size.width - height)/2, width: self.view.frame.size.width, height: height)
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = image
            self.imageScrolView.addSubview(imageViewScrollView)
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSize(width:self.view.frame.size.width, height: frameT.size.height) : CGSize(width:self.view.frame.size.width, height: self.view.frame.size.width)
            self.imageSelected?.isHidden = true
            self.imageScrolView?.isHidden = false
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
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
