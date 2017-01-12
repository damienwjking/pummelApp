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
import Mixpanel

class ChatMessageViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, RSKGrowingTextViewDelegate {
    var nameChatUser : String!
    
    @IBOutlet var textBox: RSKGrowingTextView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var chatTB: UITableView!
    @IBOutlet var cursorView: UIView!
    @IBOutlet var leftMarginLeftChatCT: NSLayoutConstraint!
    @IBOutlet var chatTBDistantCT: NSLayoutConstraint!
    @IBOutlet var avatarTextBox: UIImageView!
    
    var typeCoach : Bool = false
    var coachName: String!
    var coachId: String!
    var userIdTarget: String!
    var messageId: String!
    var arrayChat: NSArray!
    
    var preMessage: String = ""
    
    var isSending: Bool = false
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChatMessageViewController.cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.setNavigationTitle()
       
        self.textBox.font = .pmmMonReg13()
        self.textBox.delegate = self

        self.navigationItem.hidesBackButton = true;
        
        self.chatTB.delegate = self
        self.chatTB.dataSource = self
        self.chatTB.separatorStyle = UITableViewCellSeparatorStyle.None
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(ChatMessageViewController.handleTap(_:)))
        self.chatTB.addGestureRecognizer(recognizer)
        avatarTextBox.layer.cornerRadius = 20
        avatarTextBox.clipsToBounds = true
        avatarTextBox.hidden = true
        self.getImageAvatarTextBox()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.getArrayChat()
        
        self.textBox.text = self.preMessage
    }
    
    func getImageAvatarTextBox() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetail = JSON as! NSDictionary
                if !(userDetail[kImageUrl] is NSNull) {
                    var link = kPMAPI
                    link.appendContentsOf(userDetail[kImageUrl] as! String)
                    link.appendContentsOf(widthHeight80)
                    
                    if (NSCache.sharedInstance.objectForKey(link) != nil) {
                        let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                        self.avatarTextBox.image = imageRes
                    } else {
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                self.avatarTextBox.image = imageRes
                                NSCache.sharedInstance.setObject(imageRes, forKey: link)
                        }
                    }
                } else {
                    self.avatarTextBox.image = UIImage(named: "display-empty.jpg")
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.textBox.resignFirstResponder()
        self.view.frame.origin.y = 64
        self.cursorView.hidden = false
        self.avatarTextBox.hidden = true
        self.leftMarginLeftChatCT.constant = 15
    }

    func getArrayChat() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION)
        prefix.appendContentsOf("/")
        if (messageId != nil) {
            prefix.appendContentsOf(self.messageId as String)
            prefix.appendContentsOf(kPM_PARTH_MESSAGE)
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    self.arrayChat = JSON as! NSArray
                    if(self.arrayChat.count > 0) {
                        self.chatTB.reloadData({ 
                            let lastIndex = NSIndexPath(forRow: self.arrayChat.count, inSection: 0)
                            self.chatTB.scrollToRowAtIndexPath(lastIndex, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                        })
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    func setNavigationTitle() {
        if (self.typeCoach == true) {
            self.navigationItem.title = coachName
        } else {
            if (nameChatUser != nil) {
                self.navigationItem.title = nameChatUser
            } else {
                var prefixUser = kPMAPIUSER
                prefixUser.appendContentsOf(userIdTarget)
                Alamofire.request(.GET, prefixUser)
                    .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                        let userInfo = JSON as! NSDictionary
                        let name = userInfo.objectForKey(kFirstname) as! String
                        self.navigationItem.title = name.uppercaseString
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                    }
                }
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 64 - keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 64
        if (self.textBox.text == "") {
            self.cursorView.hidden = false
            self.avatarTextBox.hidden = true
            self.leftMarginLeftChatCT.constant = 15
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.sendMessage()
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.cursorView.hidden = true
        self.avatarTextBox.hidden = false
        self.leftMarginLeftChatCT.constant = 40
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
    
//    func moveToOld() {
//        let move = { (action:UIAlertAction!) -> Void in
//            self.view.makeToast(message: "Setting")
//            var prefix = kPMAPIUSER
//            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
//            prefix.appendContentsOf(kPMAPI_LEAD)
//            prefix.appendContentsOf("/")
//            Alamofire.request(.POST, prefix, parameters: [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, kCoachId:self.userIdTarget])
//                .responseJSON { response in
//                    self.view.hideToastActivity()
//                    if response.response?.statusCode == 200 {
//                    }
//            }
//        }
//        
//        let selectCancle = { (action:UIAlertAction!) -> Void in
//        }
//        
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        alertController.addAction(UIAlertAction(title: kMoveToOld, style: UIAlertActionStyle.Destructive, handler: move))
//        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: selectCancle))
//        
//        self.presentViewController(alertController, animated: true) { }
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kChatMessageHeaderTableViewCell, forIndexPath: indexPath) as! ChatMessageHeaderTableViewCell
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(userIdTarget as String)
            cell.avatarIMV.image = nil
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let userDetail = JSON as! NSDictionary
                    if !(userDetail[kImageUrl] is NSNull) {
                        var link = kPMAPI
                        link.appendContentsOf(userDetail[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight160)
                        
                        if (NSCache.sharedInstance.objectForKey(link) != nil) {
                            let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                            cell.avatarIMV.image = imageRes
                        } else {
                            Alamofire.request(.GET, link)
                                .responseImage { response in
                                    if (response.response?.statusCode == 200) {
                                        let imageRes = response.result.value! as UIImage
                                        NSCache.sharedInstance.setObject(imageRes, forKey: link)
                                        let updateCell = tableView .cellForRowAtIndexPath(indexPath)
                                        dispatch_async(dispatch_get_main_queue(),{
                                            if updateCell != nil {
                                                cell.avatarIMV.image = imageRes
                                            }
                                        })
                                        
                                    }
                            }
                        }
                    } else {
                        cell.avatarIMV.image = UIImage(named: "display-empty.jpg")
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            
            if (typeCoach == true) {
                cell.nameChatUserLB.text = coachName
            } else {
                if (nameChatUser != nil) {
                    cell.nameChatUserLB.text = nameChatUser
                } else {
                    var prefixUser = kPMAPIUSER
                    prefixUser.appendContentsOf(userIdTarget)
                    Alamofire.request(.GET, prefixUser)
                        .responseJSON { response in switch response.result {
                        case .Success(let JSON):
                            let userInfo = JSON as! NSDictionary
                            let name = userInfo.objectForKey(kFirstname) as! String
                            cell.nameChatUserLB.text = name.uppercaseString
                        case .Failure(let error):
                            print("Request failed with error: \(error)")
                        }
                    }
                }

            }
            
            cell.timeLB.hidden = true
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            let num = arrayChat.count
            let message = arrayChat[num-indexPath.row] as! NSDictionary
            if (message[kImageUrl] is NSNull) {
                let cell = tableView.dequeueReusableCellWithIdentifier(kChatMessageWithoutImageTableViewCell, forIndexPath: indexPath) as! ChatMessageWithoutImageTableViewCell
                var prefix = kPMAPIUSER
                prefix.appendContentsOf(String(format:"%0.f",message[kUserId]!.doubleValue))
                cell.avatarIMV.image = nil
                Alamofire.request(.GET, prefix)
                        .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                            let userInfo = JSON as! NSDictionary
                            let name = userInfo.objectForKey(kFirstname) as! String
                            cell.nameLB.text = name.uppercaseString
                            if !(userInfo[kImageUrl] is NSNull) {
                                var link = kPMAPI
                                link.appendContentsOf(userInfo[kImageUrl] as! String)
                                link.appendContentsOf(widthHeight160)
                                
                                if (NSCache.sharedInstance.objectForKey(link) != nil) {
                                    let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                                    cell.avatarIMV.image = imageRes
                                } else {
                                    Alamofire.request(.GET, link)
                                        .responseImage { response in
                                            if (response.response?.statusCode == 200) {
                                                let imageRes = response.result.value! as UIImage
                                                NSCache.sharedInstance.setObject(imageRes, forKey: link)
                                                let updateCell = tableView .cellForRowAtIndexPath(indexPath)
                                                dispatch_async(dispatch_get_main_queue(),{
                                                    if updateCell != nil {
                                                        cell.avatarIMV.image = imageRes
                                                    }
                                                })
                                                
                                            }
                                    }
                                }
                            } else {
                                cell.avatarIMV.image = UIImage(named: "display-empty.jpg")
                            }
                    case .Failure(let error):
                            print("Request failed with error: \(error)")
                    }
                }
                
                if (message.objectForKey(kText) == nil) {
                    cell.messageLB.text = ""
                } else {
                    cell.messageLB.text = message.objectForKey(kText) as? String
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(kChatMessageImageTableViewCell, forIndexPath: indexPath) as! ChatMessageImageTableViewCell
                var link = kPMAPI
                link.appendContentsOf(message.objectForKey(kImageUrl) as! String)
                link.appendContentsOf(widthHeight320)
                Alamofire.request(.GET, link)
                    .responseImage { response in
                        let imageRes = response.result.value! as UIImage
                       cell.photoIMW.image = imageRes
                }
                var prefix = kPMAPIUSER
                prefix.appendContentsOf(String(format:"%0.f",message[kUserId]!.doubleValue))
                Alamofire.request(.GET, prefix)
                    .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                        let userInfo = JSON as! NSDictionary
                        let name = userInfo.objectForKey(kFirstname) as! String
                        cell.nameLB.text = name.uppercaseString
                        if !(userInfo[kImageUrl] is NSNull) {
                            var link = kPMAPI
                            link.appendContentsOf(userInfo[kImageUrl] as! String)
                            link.appendContentsOf(widthHeight80)
                            
                            if (NSCache.sharedInstance.objectForKey(link) != nil) {
                                let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                                cell.avatarIMV.image = imageRes
                            } else {
                                Alamofire.request(.GET, link)
                                    .responseImage { response in
                                        let imageRes = response.result.value! as UIImage
                                        cell.avatarIMV.image = imageRes
                                        NSCache.sharedInstance.setObject(imageRes, forKey: link)
                                }
                            }
                        }
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                    }
                }
                
                cell.messageLB.text = (message.objectForKey(kText) == nil) ? "" :  message.objectForKey(kText) as? String
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.messageId == nil) {
            chatTBDistantCT.constant = self.view.frame.size.height/2 - 64 - 49
            tableView.userInteractionEnabled = false
            return 1
        } else {
            if (self.arrayChat != nil) {
                chatTBDistantCT.constant = 0
                tableView.userInteractionEnabled = true
                return self.arrayChat.count + 1
            } else {
                chatTBDistantCT.constant = self.view.frame.size.height/2 - 64 - 49
                tableView.userInteractionEnabled = false
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
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Category": "IOS.ChatMessage", "Name": "Navigation Click", "Label":"Go Send Picture Message"]
        mixpanel.track("Event", properties: properties)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "sendPhoto")
        {
            self.textBox.resignFirstResponder()
            let destinationVC = segue.destinationViewController as! SendPhotoViewController
            destinationVC.messageId = self.messageId
            destinationVC.typeCoach = self.typeCoach
            destinationVC.coachId = self.coachId
            destinationVC.userIdTarget = self.userIdTarget
        }
    }
    
    func sendMessage() {
        let values : [String]
        
        values = (self.typeCoach == true) ? [coachId] : [userIdTarget as String]
        
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION)
        prefix.appendContentsOf("/")
        Alamofire.request(.POST, prefix, parameters: [kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String, kUserIds:values])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    let JSON = response.result.value
                    let conversationId = String(format:"%0.f",JSON!.objectForKey(kId)!.doubleValue)
                    //Add message to converstaton
                    self.messageId = conversationId
                    self.addMessageToExistConverstation()
                }
        }
        
    }
    
    func addMessageToExistConverstation(){
        var prefix = kPMAPIUSER
        
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION)
        prefix.appendContentsOf("/")
        prefix.appendContentsOf(self.messageId as String)
        prefix.appendContentsOf(kPM_PARTH_MESSAGE)
        Alamofire.request(.POST, prefix, parameters: [kConversationId:self.messageId, kText:textBox.text, "file":"nodata".dataUsingEncoding(NSUTF8StringEncoding)!])
            .responseJSON { response in
                self.isSending = false
                if response.response?.statusCode == 200 {
                    self.getArrayChat()
                    self.textBox.text = ""
                    self.textBox.resignFirstResponder()
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = kFullDateFormat
                    dateFormatter.timeZone = NSTimeZone(name: "UTC")
                    let dayCurrent = dateFormatter.stringFromDate(NSDate())
                    var prefixT = kPMAPIUSER
                    prefixT.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
                    prefixT.appendContentsOf(kPM_PATH_CONVERSATION)
                    prefixT.appendContentsOf("/")
                    prefixT.appendContentsOf(self.messageId as String)
                    
                    Alamofire.request(.PUT, prefixT, parameters: [kConversationId:self.messageId as String, kLastOpenAt:dayCurrent, kUserId: self.defaults.objectForKey(k_PM_CURRENT_ID) as! String])
                        .responseJSON { response in
                            if response.response?.statusCode == 200 {
                                print("updated lastOpenAt")
                            }
                    }
                }
        }
    }
    
    @IBAction func clickOnSendButton() {
        if !(self.textBox.text == "" && self.isSending == false) {
            self.isSending = true
            if (self.messageId != nil) {
                self.addMessageToExistConverstation()
            } else {
                self.sendMessage()
            }
            
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Category": "IOS.ChatMessage", "Name": "Navigation Click", "Label":"Send Message"]
            mixpanel.track("Event", properties: properties)
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
        }
        return data
    }
}

