//
//  BookSessionToUserViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class BookSessionToUserViewController: BaseViewController {
    
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var contentTV: UITextView!
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var avatarUserIMV: UIImageView!
    @IBOutlet weak var imageSelected : UIImageView!
    @IBOutlet weak var imageScrolView : UIScrollView!
    
    let defaults = UserDefaults.standard
    var coachDetail: NSDictionary!
    let imagePicker = UIImagePickerController()
    var selectFromLibrary : Bool = false
    var tag:TagModel?
    var userInfoSelect:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        datePickerView.backgroundColor = UIColor.black
        datePickerView.setValue(UIColor.white, forKey: "textColor")
        dateTF.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker(sender:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.tapView.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapView))
        self.tapView.addGestureRecognizer(tap)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.leftBarButtonClicked))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kSave.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.avatarUserIMV.layer.cornerRadius = 20
        self.avatarUserIMV.clipsToBounds = true
        
        self.setAvatar()
        
        self.dateTF.font = UIFont.pmmMonReg13()
        self.contentTV.font = UIFont.pmmMonReg13()
        self.contentTV.text = "ADD A COMMENT..."
        self.contentTV.keyboardAppearance = .dark
        self.contentTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
        self.contentTV.delegate = self
        self.contentTV.selectedTextRange = self.contentTV.textRange(from: self.contentTV.beginningOfDocument, to: self.contentTV.beginningOfDocument)
        imagePicker.delegate = self
        imageScrolView.delegate = self
        imageScrolView.minimumZoomScale = 1
        imageScrolView.maximumZoomScale = 4.0
        imageScrolView.zoomScale = 1.0
    }
    
    func didTapView() {
        self.contentTV.resignFirstResponder()
        self.dateTF.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tagTitle = self.tag!.tagTitle?.components(separatedBy: " ").joined(separator: "")
        self.title = String(format: "#%@", (tagTitle!.uppercased()))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = " "
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "MMM dd, YYYY hh:mm aaa"
        dateTF.text = timeFormatter.string(from: sender.date)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tapView.isHidden = false
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tapView.isHidden = true
    }
    
    func leftBarButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func done() {
        if (self.dateTF.text == "" || self.dateTF.text == "ADD A DATE") {
            PMHelper.showNoticeAlert(message: pleaseInputADate)
        } else {
            var imageData = Data()
            if self.imageSelected.image != nil {
                imageData = (self.imageSelected?.isHidden != true) ? UIImageJPEGRepresentation(imageSelected!.image!, 0.2)! as Data : UIImageJPEGRepresentation(self.cropAndSave(), 0.2)! as Data
            }
            
            var userIdSelected = ""
            if let val = self.userInfoSelect["userId"] as? Int {
                userIdSelected = "\(val)"
            }
            
            var textToPost = self.contentTV.text
            if (self.contentTV.text == "" || self.contentTV.text == "ADD A COMMENT..." ) {
                textToPost = "..."
            }
            
            let currentUserID = PMHelper.getCurrentID()
            let type = "#" + (self.tag?.tagTitle?.uppercased())!
            let selectedDate = self.convertLocalTimeToUTCTime(dateTimeString: self.dateTF.text!)
            
            self.view.makeToastActivity(message: "Saving")
            
            SessionRouter.postBookSession(userID: currentUserID, targetUserID: userIdSelected, message: textToPost!, type: type, dateTime: selectedDate, imageData: imageData, completed: { (result, error) in
                self.view.hideToastActivity()
                
                let isPostSuccess = result as! Bool
                if (isPostSuccess == true) {
                    self.navigationController?.popToRootViewController(animated: false)
                } else {
                    PMHelper.showDoAgainAlert()
                }
            }).fetchdata()
        }
    }
    
    func convertLocalTimeToUTCTime(dateTimeString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm aaa"
        
        dateFormatter.timeZone = NSTimeZone.local
        let date = dateFormatter.date(from: dateTimeString)
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMM dd, yyyy hh:mm aaa"
        newDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        let newDateString = newDateFormatter.string(from: date!)
        
        return newDateString
    }
    
    func setAvatar() {
        // Current user avatar
        ImageVideoRouter.getCurrentUserAvatar(sizeString: widthHeight320) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.avatarIMV.image = imageRes
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
        
        // user avatar
        var targetUserId = ""
        if let val = self.userInfoSelect["userId"] as? Int {
            targetUserId = "\(val)"
        }
        
        ImageVideoRouter.getUserAvatar(userID: targetUserId, sizeString: widthHeight160) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.avatarUserIMV.image = imageRes
            } else {
                print("Request failed with error: \(String(describing: error))")
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

// MARK: - FusumaDelegate
extension BookSessionToUserViewController : FusumaDelegate {
    func fusumaImageSelected(image: UIImage) {
        self.imageSelected.image = image
        if (self.selectFromLibrary == true) {
            self.imageScrolView.isHidden = true
            self.imageSelected?.isHidden = false
        } else {
            for(subview) in self.imageScrolView.subviews {
                subview.removeFromSuperview()
            }
            let height =  self.view.frame.size.width * image.size.height / image.size.width
            
            var frameT = CGRect(x: 0, y: (self.view.frame.size.width - height)/2, width: self.view.frame.size.width, height: height)
            if (height > self.view.frame.width) {
                frameT = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height)
            }
            
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = image
            self.imageScrolView.addSubview(imageViewScrollView)
            
            self.imageScrolView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
            if (height > self.view.frame.width) {
                self.imageScrolView.contentSize = CGSize(width: self.view.frame.size.width, height: frameT.size.height)
            }
            
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
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0] as! UIImageView
    }
}

// MARK: - UITextViewDelegate
extension BookSessionToUserViewController : UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
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
extension BookSessionToUserViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            for(subview) in self.imageScrolView.subviews {
                subview.removeFromSuperview()
            }
            self.imageSelected!.image = pickedImage
            let height =  self.view.frame.size.width*pickedImage.size.height/pickedImage.size.width
            let frameT = (height > self.view.frame.width) ? CGRect(x: 0, y: 0, width: self.view.frame.size.width, height:height) : CGRect(x: 0, y:(self.view.frame.size.width - height)/2, width:self.view.frame.size.width, height: height)
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
    
    func cropAndSave() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageScrolView.bounds.size, true, SCREEN_SCALE)
        let offset = imageScrolView.contentOffset
        
        UIGraphicsGetCurrentContext()!.translateBy(x: -offset.x, y: -offset.y)
        imageScrolView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image!
    }
}
