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
            var type : String!
            var filename: String!
            if assetPath.absoluteString.hasSuffix("JPG") {
                type = "image/jpeg"
                filename = "imagefile.jpeg"
                imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
            } else if assetPath.absoluteString.hasSuffix("PNG") {
                type = "image/png"
                filename = "imagefile.png"
                imageData = UIImagePNGRepresentation(pickedImage)
            }
            
            if (imageData == nil) {
                dispatch_async(dispatch_get_main_queue(),{
                    //Your main thread code goes in here
                    let alertController = UIAlertController(title: "Upload message issue", message: "Please choose jpeg or png file", preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                })

            } else {
                var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
                let defaults = NSUserDefaults.standardUserDefaults()
                prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
                prefix.appendContentsOf("/photos")
                var parameters = [String:AnyObject]()
                parameters = ["userId":defaults.objectForKey("currentId") as! String, "profilePic": "0"]
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
                                    // failure
                                    print(response.result.error)
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
            
        }
    
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}