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
    var numberOfKeyboard : Int = 0
    
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getArrayChat()
    }
    
    func getImageAvatarTextBox() {
        var prefix = kPMAPIUSER
        let defaults = NSUserDefaults.standardUserDefaults()
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
    }
    
    func getArrayChat() {
        var prefix = kPMAPIUSER
        let defaults = NSUserDefaults.standardUserDefaults()
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
                        self.chatTB.reloadData()
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 64 - keyboardSize.height
            numberOfKeyboard += 1
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (numberOfKeyboard == 1) {
            self.view.frame.origin.y = 64
        }
        numberOfKeyboard -= 1
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kChatMessageHeaderTableViewCell, forIndexPath: indexPath) as! ChatMessageHeaderTableViewCell
            
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(userIdTarget as String)
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
                                    let imageRes = response.result.value! as UIImage
                                    cell.avatarIMV.image = imageRes
                                    NSCache.sharedInstance.setObject(imageRes, forKey: link)
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
        let defaults = NSUserDefaults.standardUserDefaults()
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
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION)
        prefix.appendContentsOf("/")
        prefix.appendContentsOf(self.messageId as String)
        prefix.appendContentsOf(kPM_PARTH_MESSAGE)
        Alamofire.request(.POST, prefix, parameters: [kConversationId:self.messageId, kText:textBox.text, "file":"nodata".dataUsingEncoding(NSUTF8StringEncoding)!])
            .responseJSON { response in
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
        }
        return data
    }
}

