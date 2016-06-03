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

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageViewProfile: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewProfile.layer.cornerRadius = imageViewProfile.frame.height/2
        imageViewProfile.clipsToBounds = true
        imagePicker.delegate = self
        
        //Tap to edit profile avatar
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:("imageTapped"))
        imageViewProfile.userInteractionEnabled = true
        imageViewProfile.addGestureRecognizer(tapGestureRecognizer)
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
        alertController.addAction(UIAlertAction(title: "Select From Library", style: UIAlertActionStyle.Default, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func imageTapped()
    {
        showPopupToSelectProfileAvatar()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageViewProfile.contentMode = .ScaleAspectFill
            var imageData : NSData!
            let assetPath = info[UIImagePickerControllerReferenceURL] as! NSURL
            print(assetPath.absoluteString)
            if assetPath.absoluteString.hasSuffix("JPG") {
                imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
            } else {
                imageData = UIImagePNGRepresentation(pickedImage)
            }
            
            var prefix = "http://api.pummel.fit/api/users/"
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            prefix.appendContentsOf(appDelegate.currentUserId as String)
            prefix.appendContentsOf("/photos")
            print(prefix)
            Alamofire.request(.POST, prefix, parameters: ["userId":37,"file":imageData])
                .responseJSON { response in
                    if (response.response?.statusCode != 200) {
                        let alertController = UIAlertController(title: "Upload Issue", message: "The size of picture too big, please choose another image", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                    } else {
                         self.imageViewProfile.image = pickedImage
                    }
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}