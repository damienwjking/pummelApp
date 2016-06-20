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
    @IBOutlet var imageSelected : UIImageView?
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
        self.commentPhotoTF.attributedPlaceholder = NSAttributedString(string:"ADD A COMMENT...",
            attributes:([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]))
        self.commentPhotoTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.commentPhotoTF.delegate = self
        self.commentPhotoTF.keyboardAppearance = .Dark
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.navigationItem.hidesBackButton = true;
        viewKeyboard = UIView.init(frame:CGRect(x: 0, y: self.view.frame.height - 300, width: self.view.frame.width, height: 300))
        viewKeyboard.backgroundColor = UIColor.blackColor()
        viewKeyboard.hidden = true
        self.view.addSubview(viewKeyboard)
    }
    
    func keyboardWillShow(notification: NSNotification) {
            self.viewKeyboard.hidden = false
    }
    
    func keyboardWillHide(notification: NSNotification) {
          self.viewKeyboard.hidden = true
    }
    
    func setAvatar() {
        var prefix = "http://api.pummel.fit/api/users/" as String
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
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
}
