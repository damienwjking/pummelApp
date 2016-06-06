//
//  ChatMessageViewController.swift
//  pummel
//
//  Created by Bear Daddy on 5/15/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import RSKGrowingTextView
import Alamofire

class ChatMessageViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, RSKGrowingTextViewDelegate {
    var nameChatUser : NSString!
    
    @IBOutlet var textBox: RSKGrowingTextView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var chatTB: UITableView!
    @IBOutlet var chatTBDistantCT: NSLayoutConstraint!
    var userIdTarget: NSString!
    var messageId: NSString!
    var arrayChat: NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel")
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        self.setNavigationTitle()
      // self.textBox.attributedPlaceholder = NSAttributedString(string:"START A CONVERSATION",           attributes:([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor.blackColor()]))
       // self.textBox.delegate = self
        self.textBox.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        self.navigationItem.hidesBackButton = true;
        
        self.chatTB.delegate = self
        self.chatTB.dataSource = self
        self.chatTB.separatorStyle = UITableViewCellSeparatorStyle.None
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
        self.chatTB.addGestureRecognizer(recognizer)
        self.getArrayChat()
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.textBox.resignFirstResponder()
    }
    
    func getArrayChat() {
        var prefix = "http://api.pummel.fit/api/user/conversations/" as String
        if (messageId != nil) {
            prefix.appendContentsOf(self.messageId as String)
            prefix.appendContentsOf("/messages")
            print(prefix)
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    self.arrayChat = JSON as! NSArray
                    if(self.arrayChat.count > 0) {
                        self.chatTB.reloadData()
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    func setNavigationTitle() {
        var prefix = "http://api.pummel.fit/api/users/" as String
        prefix.appendContentsOf(self.userIdTarget as String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                print(JSON)
                let userInfo = JSON as! NSDictionary
                var name = userInfo.objectForKey("firstname") as! String
                name.appendContentsOf(" ")
                name.appendContentsOf(userInfo.objectForKey("lastname") as! String)
                self.navigationItem.title = name.uppercaseString
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
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
        self.sendMessage()
        return true
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
                var prefix = "http://api.pummel.fit/api/users/" as String
                prefix.appendContentsOf(userIdTarget as String)
                prefix.appendContentsOf("/photos")
                Alamofire.request(.GET, prefix)
                    .responseJSON { response in switch response.result {
                        case .Success(let JSON):
                            let listPhoto = JSON as! NSArray
                            if (listPhoto.count >= 1) {
                                let photo = listPhoto[0] as! NSDictionary
                                var link = photo.objectForKey("url") as! String
                                link.appendContentsOf("?width=80&height=80")
                                print(link)
                                Alamofire.request(.GET, link)
                                    .responseImage { response in
                                        let imageRes = response.result.value! as UIImage
                                        cell.avatarIMV.image = imageRes
                                }
                        }
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                    }
            }
            var prefixName = "http://api.pummel.fit/api/users/" as String
            prefixName.appendContentsOf(self.userIdTarget as String)
            Alamofire.request(.GET, prefixName)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    print(JSON)
                    let userInfo = JSON as! NSDictionary
                    let name = userInfo.objectForKey("firstname") as! String
                    cell.nameChatUserLB.text = name.uppercaseString
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            cell.timeLB.hidden = true
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
//            if indexPath.row == 1 {
//                 let cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageWithoutImageTableViewCell", forIndexPath: indexPath) as! ChatMessageWithoutImageTableViewCell
//                if (user4 == true)
//                {
//                    cell.avatarIMV.image = UIImage(named: "kate.jpg")
//                    cell.nameLB.text = message.user.name as String
//                    cell.messageLB.text = message.message as String
//                } else {
//                    cell.avatarIMV.image = UIImage(named: "kate.jpg")
//                    cell.nameLB.text = "KATE" as String
//                    cell.messageLB.text = "A lorum is a male genital piercing, placed horizontally on the underside of the penis at its base, where the penis meets the scrotum.Are your height constraints for the cell(s) setup correctly, i have not seen any issues with this in the wild using the Xcode 6.3 version. Even have a sample project on github with this working." as String
//                }
//                return cell
//            } else {
//                let cellImage = tableView.dequeueReusableCellWithIdentifier("ChatMessageImageTableViewCell", forIndexPath: indexPath) as! ChatMessageImageTableViewCell
//                cellImage.avatarIMV.image = UIImage(named: "kate.jpg")
//                cellImage.nameLB.text = "KATE" as String
//                cellImage.messageLB.text = "Hey Adam, Thanks for connecting with me! If you could please let me know what you’re looking to improve with a personal trainer and I can get to helping you out." as String
//                cellImage.photoIMW.image = UIImage(named: "kate.jpg")
//                return cellImage
//            }
//            
           let cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageWithoutImageTableViewCell", forIndexPath: indexPath) as! ChatMessageWithoutImageTableViewCell
            let num = arrayChat.count
            let message = arrayChat[num-indexPath.row] as! NSDictionary
            let userId =  String(format:"%0.f",message.objectForKey("userId")!.doubleValue)
            var prefix = "http://api.pummel.fit/api/users/" as String
            prefix.appendContentsOf(userId)
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    print(prefix)
                    
                    print(JSON)
                    let userInfo = JSON as! NSDictionary
                    let name = userInfo.objectForKey("firstname") as! String
                    cell.nameLB.text = name
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            prefix.appendContentsOf("/photos")
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let listPhoto = JSON as! NSArray
                    if (listPhoto.count >= 1) {
                        let photo = listPhoto[0] as! NSDictionary
                        var link = photo["url"] as! String
                        link.appendContentsOf("?width=80&height=80")
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                cell.avatarIMV.image = imageRes
                        }
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            if (message.objectForKey("text") == nil) {
                cell.messageLB.text = ""
            } else {
                cell.messageLB.text = message.objectForKey("text") as? String
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.messageId == nil) {
            chatTBDistantCT.constant = self.view.frame.size.height/2 - 64 - 49
            tableView.userInteractionEnabled = false
            return 1
        } else {
            if (self.arrayChat != nil) {
                return self.arrayChat.count + 1
            } else {
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func goPhoto(sender:UIButton!) {
        performSegueWithIdentifier("sendPhoto", sender: nil)
    }
    
    func sendMessage() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let values = [userIdTarget as String, appDelegate.currentUserId]
        Alamofire.request(.POST, "http://api.pummel.fit/api/user/conversations/", parameters: ["userIds":values])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    let JSON = response.result.value
                    print("JSON: \(JSON)")
                    let conversationId = String(format:"%0.f",JSON!.objectForKey("id")!.doubleValue)

                    //Add message to converstaton
                    self.messageId = conversationId
                    self.addMessageToExistConverstation()
                }
        }
    }
    
    func addMessageToExistConverstation(){
        var prefix = "http://api.pummel.fit/api/user/conversations/" as String
        prefix.appendContentsOf(self.messageId as String)
        prefix.appendContentsOf("/messages")
        print(prefix)
        Alamofire.request(.POST, prefix, parameters: ["conversationId":self.messageId, "text":textBox.text])
            .responseJSON { response in
                print(response.response?.statusCode)
                if response.response?.statusCode == 200 {
                    self.getArrayChat()
                    self.textBox.text = ""
                    self.textBox.resignFirstResponder()
                }
        }
    }
    
    @IBAction func clickOnSendButton() {
        if (self.messageId != nil) {
            self.addMessageToExistConverstation()
        } else {
            self.sendMessage()
        }
    }

    func stringArrayToNSData(array: [String]) -> NSData {
        let data = NSMutableData()
        let terminator = [0]
        for string in array {
            if let encodedString = string.dataUsingEncoding(NSUTF8StringEncoding) {
                data.appendData(encodedString)
                data.appendBytes(terminator, length: 1)
            }
            else {
                NSLog("Cannot encode string \"\(string)\"")
            }
        }
        return data
    }

}

