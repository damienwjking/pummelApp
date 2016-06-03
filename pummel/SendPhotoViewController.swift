//
//  SendPhotoViewController.swift
//  pummel
//
//  Created by Bear Daddy on 5/23/16.
//  Copyright © 2016 pummel. All rights reserved.
//
import UIKit
import Alamofire

class SendPhotoViewController: UIViewController, FusumaDelegate, UITextFieldDelegate {
    
    @IBOutlet var avatarIMV : UIImageView!
    @IBOutlet var commentPhotoTF : UITextField!
    @IBOutlet var imageSelected : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.title = "SEND PHOTO"
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
         self.navigationItem.hidesBackButton = true;
        let image = UIImage(named: "close")!.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action:"close")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "POST", style: UIBarButtonItemStyle.Plain, target: self, action: "post")
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.setAvatar()
        
        self.commentPhotoTF.attributedPlaceholder = NSAttributedString(string:"ADD A COMMENT...",
            attributes:([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]))
        self.commentPhotoTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.commentPhotoTF.delegate = self
        self.commentPhotoTF.keyboardAppearance = .Dark
    }
    
    func setAvatar() {
        var prefix = "http://api.pummel.fit/api/users/" as String
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        prefix.appendContentsOf(appDelegate.currentUserId)
        prefix.appendContentsOf("/photos")
        print(prefix)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                print(JSON)
                let listPhoto = JSON as! NSArray
                if (listPhoto.count >= 1) {
                    let photo = listPhoto[0] as! NSDictionary
                    var link = photo.objectForKey("url") as! String
                    link.appendContentsOf("?width=80&height=80")
                    print(link)
                    Alamofire.request(.GET, link)
                        .responseImage { response in
                            let imageRes = response.result.value! as UIImage
                            self.avatarIMV.image = imageRes
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
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func showCameraRoll(sender:UIButton!) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.defaultMode = .Camera
        fusuma.modeOrder = .CameraFirst
        self.presentViewController(fusuma, animated: true, completion: nil)
    }
    
    // Fusuma delegate
    func fusumaImageSelected(image: UIImage) {
        
        print("Image selected")
        self.imageSelected.image = image
    }
    
    func fusumaDismissedWithImage(image: UIImage) {
        
        print("Called just after dismissed FusumaViewController")
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
    
    func fusumaClosed() {
        
        print("Called when the close button is pressed")
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
