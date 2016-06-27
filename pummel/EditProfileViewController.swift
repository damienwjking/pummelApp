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
            var type : String
            var filename: String
            if assetPath.absoluteString.hasSuffix("JPG") {
                type = "image/jpg"
                filename = "file.jpg"
                imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
            } else {
                type = "image/png"
                filename = "file.png"
                imageData = UIImagePNGRepresentation(pickedImage)
            }
            
            var prefix = "http://api.pummel.fit/api/users/"
            let defaults = NSUserDefaults.standardUserDefaults()
            prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
            prefix.appendContentsOf("/photos")
            print(prefix)
            Alamofire.upload(
                .POST,
                prefix,
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: imageData, name: "imageFile",
                        fileName:filename, mimeType:type)
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
                                // failure
                                
                            } else {
                                self.imageViewProfile.image = pickedImage
                                
                            }
                            
                        }
                        
                    case .Failure(let encodingError):
                        print(encodingError)
                        //failure
                    }
                }
            )
            
        }
    
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}