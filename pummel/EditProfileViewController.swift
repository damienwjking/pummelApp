//
//  EditProfileViewController.swift
//  pummel
//
//  Created by ThongNguyen on 4/8/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation
import UIKit

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
            imageViewProfile.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}