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
    @IBOutlet var connectToLB : UILabel!
    @IBOutlet var nameChatUserLB : UILabel!
    @IBOutlet var startConversation : UILabel!
    @IBOutlet var justNowLB : UILabel!
    @IBOutlet var avatarIMV : UIImageView!
    @IBOutlet var textBox: UITextField!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var chatTB: UITableView!
    
    @IBOutlet weak var chatTBToTop: NSLayoutConstraint!
    @IBOutlet weak var avatarToTop: NSLayoutConstraint!
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
        self.connectToLB.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.nameChatUserLB.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.startConversation.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.avatarIMV.layer.cornerRadius = 40
        self.avatarIMV.clipsToBounds = true
        self.textBox.attributedPlaceholder = NSAttributedString(string:"START A CONVERSATION",
            attributes:([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor.blackColor()]))
        self.textBox.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.textBox.delegate = self
        self.avatarIMV.image = UIImage(named: "kate.jpg")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        self.navigationItem.hidesBackButton = true;
        
        self.chatTB.delegate = self
        self.chatTB.dataSource = self
        self.chatTB.separatorStyle = UITableViewCellSeparatorStyle.None
        if (user1 == true) {
           self.chatTB.hidden = true
           self.justNowLB.hidden = true
        } else {
           self.updateUI()
        }
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
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageTableViewCell", forIndexPath: indexPath) as! ChatMessageTableViewCell
        if indexPath.row == 0 {
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
        } else {
            cell.avatarIMV.image = UIImage(named: "kate.jpg")
            cell.nameLB.text = "KATE" as String
            cell.messageLB.text = "Hey Adam, Thanks for connecting with me! If you could please let me know what you’re looking to improve with a personal trainer and I can get to helping you out." as String
        }
       
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (user1 == true) {
            return 0
        } else if (user2 == true || user4 == true) {
            return 1
        } else {
            return 2
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
    
    func updateUI() {
        self.avatarToTop.constant -= self.avatarIMV.frame.origin.y - 15
        self.chatTBToTop.constant += self.avatarIMV.frame.origin.y -  self.avatarIMV.frame.size.height
    }
    
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }

}

