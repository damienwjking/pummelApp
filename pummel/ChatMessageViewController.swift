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

class ChatMessageViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate, RSKGrowingTextViewDelegate {
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
    var targerUser: NSDictionary!
    var messageId: String!
    var arrayChat: NSArray!
    
    var preMessage: String = ""
    
    var isSending: Bool = false
    var isSendMessage = false
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: Controller Life Circle
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
        self.avatarTextBox.layer.cornerRadius = 20
        self.avatarTextBox.clipsToBounds = true
        self.avatarTextBox.hidden = true
        self.getImageAvatarTextBox()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.getArrayChat()
        
        self.textBox.text = self.preMessage
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getImageAvatarTextBox() {
        ImageRouter.getCurrentUserAvatar(sizeString: widthHeight120, completed: { (result, error) in
            if (error == nil) {
                let textBoxImage = result as! UIImage
                
                self.avatarTextBox.image = textBoxImage
            } else {
                print("Request failed with error: \(error)")
            }
        }).fetchdata()
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
        } else {
            self.sendMessage(false)
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
        self.sendMessage(true)
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.cursorView.hidden = true
        self.avatarTextBox.hidden = false
        self.leftMarginLeftChatCT.constant = 40
    }
    
    // MARK: UITableViewDelegate
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
            
            let avatarGesture = UITapGestureRecognizer(target: self, action:#selector(self.avatarClicked))
            cell.avatarIMV.addGestureRecognizer(avatarGesture)
            cell.avatarIMV.userInteractionEnabled = true
            cell.avatarIMV.image = UIImage(named: "display-empty.jpg")
            
            ImageRouter.getUserAvatar(userID: self.userIdTarget, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    
                    let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                    if visibleCell == true {
                        dispatch_async(dispatch_get_main_queue(),{
                            cell.avatarIMV.image = imageRes
                        })
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
            
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
                
                let userID = String(format:"%0.f",message[kUserId]!.doubleValue)
                cell.avatarIMV.image = nil
                
                UserRouter.getUserInfo(userID: userID, completed: { (result, error) in
                    if (error == nil) {
                        let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                        if visibleCell == true {
                            let userInfo = result as! NSDictionary
                            
                            let name = userInfo.objectForKey(kFirstname) as! String
                            cell.nameLB.text = name.uppercaseString
                            if (userInfo[kImageUrl] != nil) {
                                let userImageURL = userInfo[kImageUrl] as! String
                                
                                ImageRouter.getImage(posString: userImageURL, sizeString: widthHeight160, completed: { (result, error) in
                                    if (error == nil) {
                                        let imageRes = result as! UIImage
                                        
                                        let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                                        if visibleCell == true {
                                            dispatch_async(dispatch_get_main_queue(),{
                                                cell.avatarIMV.image = imageRes
                                            })
                                        }
                                    } else {
                                        print("Request failed with error: \(error)")
                                    }
                                }).fetchdata()
                                
                            } else {
                                cell.avatarIMV.image = UIImage(named: "display-empty.jpg")
                            }
                        }
                    } else {
                        print("Request failed with error: \(error)")
                    }
                }).fetchdata()
                
                if (message.objectForKey(kText) == nil) {
                    cell.messageLB.text = ""
                } else {
                    cell.messageLB.text = message.objectForKey(kText) as? String
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(kChatMessageImageTableViewCell, forIndexPath: indexPath) as! ChatMessageImageTableViewCell
                
                let imageURLString = message.objectForKey(kImageUrl) as! String
                ImageRouter.getImage(posString: imageURLString, sizeString: widthHeight640, completed: { (result, error) in
                    if (error == nil) {
                        let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                        if visibleCell == true {
                            let imageRes = result as! UIImage
                            cell.photoIMW.image = imageRes
                        }
                    } else {
                        print("Request failed with error: \(error)")
                    }
                }).fetchdata()
                
                let userID = String(format:"%0.f",message[kUserId]!.doubleValue)
                
                UserRouter.getUserInfo(userID: userID, completed: { (result, error) in
                    if (error == nil) {
                        let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                        if visibleCell == true {
                            let userInfo = result as! NSDictionary
                            
                            let name = userInfo.objectForKey(kFirstname) as! String
                            cell.nameLB.text = name.uppercaseString
                            
                            let imageURLString = userInfo[kImageUrl] as! String
                            ImageRouter.getImage(posString: imageURLString, sizeString: widthHeight120, completed: { (result, error) in
                                if (error == nil) {
                                    let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                                    if visibleCell == true {
                                        let imageRes = result as! UIImage
                                        cell.avatarIMV.image = imageRes
                                    }
                                } else {
                                    print("Request failed with error: \(error)")
                                }
                            }).fetchdata()
                        }
                    } else {
                        print("Request failed with error: \(error)")
                    }
                }).fetchdata()
                
                cell.messageLB.text = (message.objectForKey(kText) == nil) ? "" :  message.objectForKey(kText) as? String
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.messageId == nil) {
            chatTBDistantCT.constant = self.view.frame.size.height/2 - 64 - 49
            tableView.scrollEnabled = false
            
            return 1
        } else {
            if (self.arrayChat != nil) {
                chatTBDistantCT.constant = 0
                tableView.scrollEnabled = true
                return self.arrayChat.count + 1
            } else {
                chatTBDistantCT.constant = self.view.frame.size.height/2 - 64 - 49
                tableView.scrollEnabled = false
                return 1
            }
        }
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: Outlet function
    func cancel() {
        if self.isSendMessage {
            NSNotificationCenter.defaultCenter().postNotificationName("SEND_CHAT_MESSAGE", object: nil)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func avatarClicked() {
        var coachLink  = kPMAPICOACH
        let coachId = String(format:"%0.f", self.targerUser[kId]!.doubleValue)
        coachLink.appendContentsOf(coachId)
        Alamofire.request(.GET, coachLink)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.performSegueWithIdentifier(kGoProfile, sender: nil)
                } else {
                    self.performSegueWithIdentifier(kGoUserProfile, sender: nil)
                }
        }
    }
    
    @IBAction func goPhoto(sender:UIButton!) {
        performSegueWithIdentifier("sendPhoto", sender: nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Go Send Picture Message"]
        mixpanel.track("IOS.ChatMessage", properties: properties)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "sendPhoto") {
            self.textBox.resignFirstResponder()
            let destinationVC = segue.destinationViewController as! SendPhotoViewController
            destinationVC.messageId = self.messageId
            destinationVC.typeCoach = self.typeCoach
            destinationVC.coachId = self.coachId
            destinationVC.userIdTarget = self.userIdTarget
        } else if (segue.identifier == kGoUserProfile) {
            let destination = segue.destinationViewController as! UserProfileViewController
            destination.userId = userIdTarget
            destination.userDetail = self.targerUser
        } else if (segue.identifier == kGoProfile) {
            let destination = segue.destinationViewController as! CoachProfileViewController
            destination.coachDetail = self.targerUser
            destination.isFromChat = true
        }
    }
    
    func sendMessage(addEmptyMessage:Bool) {
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
                    
                    if (addEmptyMessage) {
                        self.addMessageToExistConverstation()
                    } else {
                        self.getArrayChat()
                    }
                }
        }
        
    }
    
    func addMessageToExistConverstation(){
        var prefix = kPMAPIUSER
        
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION)
        prefix.appendContentsOf("/")
        prefix.appendContentsOf(self.messageId as String)
        prefix.appendContentsOf(kPM_PARTH_MESSAGE_V2)
        Alamofire.request(.POST, prefix, parameters: [kConversationId:self.messageId, kText:textBox.text, "file":"nodata".dataUsingEncoding(NSUTF8StringEncoding)!])
            .responseJSON { response in
                self.isSending = false
                if response.response?.statusCode == 200 {
                    self.getArrayChat()
                    self.textBox.text = ""
                    self.textBox.resignFirstResponder()                }
        }
    }
    
    @IBAction func clickOnSendButton() {
        if !(self.textBox.text == "" && self.isSending == false) {
            self.isSending = true
            if (self.messageId != nil) {
                self.addMessageToExistConverstation()
            } else {
                self.sendMessage(true)
            }
            
            self.isSendMessage = true
            
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Navigation Click", "Label":"Send Message"]
            mixpanel.track("IOS.ChatMessage", properties: properties)
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

