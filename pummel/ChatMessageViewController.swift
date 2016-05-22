//
//  ChatMessageViewController.swift
//  pummel
//
//  Created by Bear Daddy on 5/15/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit


class ChatMessageViewController : UIViewController, UITextFieldDelegate, FusumaDelegate, UITableViewDataSource, UITableViewDelegate {
    var nameChatUser : NSString!
    
    @IBOutlet var textBox: UITextField!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var chatTB: UITableView!
    @IBOutlet var chatTBDistantCT: NSLayoutConstraint!
    var user1: Bool!
    var user2: Bool!
    var user3: Bool!
    var user4: Bool!
    var message: Message!
    var arrayChat: NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel")
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        self.navigationItem.title = nameChatUser as String
        
        self.textBox.attributedPlaceholder = NSAttributedString(string:"START A CONVERSATION",
            attributes:([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor.blackColor()]))
        self.textBox.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.textBox.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        self.navigationItem.hidesBackButton = true;
        
        self.chatTB.delegate = self
        self.chatTB.dataSource = self
        self.chatTB.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    
    // Table Delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 197
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 197
        } else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageHeaderTableViewCell", forIndexPath: indexPath) as! ChatMessageHeaderTableViewCell
            cell.avatarIMV.image = UIImage(named: "Kate.jpg")
            if (user1 == true) {
                cell.timeLB.hidden = true
                chatTBDistantCT.constant = self.view.frame.size.height/2 - 64 - 49
            }
            return cell
        } else {
            if indexPath.row == 1 {
                 let cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageWithoutImageTableViewCell", forIndexPath: indexPath) as! ChatMessageWithoutImageTableViewCell
                if (user4 == true)
                {
                    cell.avatarIMV.image = UIImage(named: "kate.jpg")
                    cell.nameLB.text = message.user.name as String
                    cell.messageLB.text = message.message as String
                } else {
                    cell.avatarIMV.image = UIImage(named: "kate.jpg")
                    cell.nameLB.text = "KATE" as String
                    cell.messageLB.text = "A lorum is a male genital piercing, placed horizontally on the underside of the penis at its base, where the penis meets the scrotum.Are your height constraints for the cell(s) setup correctly, i have not seen any issues with this in the wild using the Xcode 6.3 version. Even have a sample project on github with this working." as String
                }
                return cell
            } else {
                let cellImage = tableView.dequeueReusableCellWithIdentifier("ChatMessageImageTableViewCell", forIndexPath: indexPath) as! ChatMessageImageTableViewCell
                cellImage.avatarIMV.image = UIImage(named: "kate.jpg")
                cellImage.nameLB.text = "KATE" as String
                cellImage.messageLB.text = "Hey Adam, Thanks for connecting with me! If you could please let me know what you’re looking to improve with a personal trainer and I can get to helping you out." as String
                cellImage.photoIMW.image = UIImage(named: "kate.jpg")
                return cellImage
            }
            
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (user1 == true) {
            return 1
        } else if (user2 == true || user4 == true) {
            return 2
        } else {
            return 3
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as! MessageTableViewCell
        //performSegueWithIdentifier("chatMessage", sender: cell.nameLB.text)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "chatMessage")
        {
            let destinationVC = segue.destinationViewController as! ChatMessageViewController
            destinationVC.nameChatUser = sender as! NSString
        }
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }

}

