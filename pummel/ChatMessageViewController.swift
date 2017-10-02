//
//  ChatMessageViewController.swift
//  pummel
//
//  Created by Bear Daddy on 5/15/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
//import RSKGrowingTextView
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
    var needOpenKeyboard = false
    
    let defaults = UserDefaults.standard
    
    // MARK: Controller Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChatMessageViewController.cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .Normal)
        self.navigationController!.navigationBar.isTranslucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.setNavigationTitle()
       
        self.textBox.font = .pmmMonReg13()
        self.textBox.delegate = self

        self.navigationItem.hidesBackButton = true;
        
        self.chatTB.delegate = self
        self.chatTB.dataSource = self
        self.chatTB.separatorStyle = UITableViewCellSeparatorStyle.none
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.handleTap(_:)))
        self.chatTB.addGestureRecognizer(recognizer)
        self.avatarTextBox.layer.cornerRadius = 20
        self.avatarTextBox.clipsToBounds = true
        self.avatarTextBox.isHidden = true
        self.getImageAvatarTextBox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.getArrayChat()
        
        self.textBox.text = self.preMessage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated: animated)
        
        if (self.needOpenKeyboard == true) {
            self.textBox.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getImageAvatarTextBox() {
        ImageRouter.getCurrentUserAvatar(sizeString: widthHeight120, completed: { (result, error) in
            if (error == nil) {
                let textBoxImage = result as! UIImage
                
                self.avatarTextBox.image = textBoxImage
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }).fetchdata()
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.textBox.resignFirstResponder()
        self.view.frame.origin.y = 64
        self.cursorView.isHidden = false
        self.avatarTextBox.isHidden = true
        self.leftMarginLeftChatCT.constant = 15
    }

    func getArrayChat() {
        var prefix = kPMAPIUSER
        prefix.append(PMHelper.getCurrentID())
        prefix.append(kPM_PATH_CONVERSATION)
        prefix.append("/")
        
        if (messageId != nil) {
            prefix.append(self.messageId as String)
            prefix.append(kPM_PARTH_MESSAGE)
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
                    print("Request failed with error: \(String(describing: error))")
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
                prefixUser.append(userIdTarget)
                Alamofire.request(.GET, prefixUser)
                    .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                        let userInfo = JSON as! NSDictionary
                        let name = userInfo.object(forKey: kFirstname) as! String
                        self.navigationItem.title = name.uppercased()
                    case .Failure(let error):
                        print("Request failed with error: \(String(describing: error))")
                    }
                }
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            self.view.frame.origin.y = 64 - keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 64
        if (self.textBox.text == "") {
            self.cursorView.isHidden = false
            self.avatarTextBox.isHidden = true
            self.leftMarginLeftChatCT.constant = 15
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.sendMessage(true)
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.cursorView.isHidden = true
        self.avatarTextBox.isHidden = false
        self.leftMarginLeftChatCT.constant = 40
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: kChatMessageHeaderTableViewCell, for: indexPath as IndexPath) as! ChatMessageHeaderTableViewCell
            
            let avatarGesture = UITapGestureRecognizer(target: self, action:#selector(self.avatarClicked))
            cell.avatarIMV.addGestureRecognizer(avatarGesture)
            cell.avatarIMV.isUserInteractionEnabled = true
            cell.avatarIMV.image = UIImage(named: "display-empty.jpg")
            
            ImageRouter.getUserAvatar(userID: self.userIdTarget, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    
                    let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                    if visibleCell == true {
                        DispatchQueue.main.async(execute: {
                            cell.avatarIMV.image = imageRes
                        })
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
            
            if (typeCoach == true) {
                cell.nameChatUserLB.text = coachName
            } else {
                if (nameChatUser != nil) {
                    cell.nameChatUserLB.text = nameChatUser
                } else {
                    var prefixUser = kPMAPIUSER
                    prefixUser.append(userIdTarget)
                    Alamofire.request(.GET, prefixUser)
                        .responseJSON { response in switch response.result {
                        case .Success(let JSON):
                            let userInfo = JSON as! NSDictionary
                            let name = userInfo.object(forKey: kFirstname) as! String
                            cell.nameChatUserLB.text = name.uppercased()
                        case .Failure(let error):
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }
                }

            }
            
            cell.timeLB.isHidden = true
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } else {
            let num = arrayChat.count
            let message = arrayChat[num-indexPath.row] as! NSDictionary
            if (message[kImageUrl] is NSNull) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kChatMessageWithoutImageTableViewCell, for: indexPath as IndexPath) as! ChatMessageWithoutImageTableViewCell
                
                let userID = String(format:"%0.f",(message[kUserId]! as AnyObject).doubleValue)
                cell.avatarIMV.image = nil
                
                UserRouter.getUserInfo(userID: userID, completed: { (result, error) in
                    if (error == nil) {
                        let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                        if visibleCell == true {
                            let userInfo = result as! NSDictionary
                            
                            let name = userInfo.object(forKey: kFirstname) as! String
                            cell.nameLB.text = name.uppercased()
                            if (userInfo[kImageUrl] is NSNull == false) {
                                let userImageURL = userInfo[kImageUrl] as! String
                                
                                ImageRouter.getImage(imageURLString: userImageURL, sizeString: widthHeight160, completed: { (result, error) in
                                    if (error == nil) {
                                        let imageRes = result as! UIImage
                                        
                                        let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                                        if visibleCell == true {
                                            DispatchQueue.main.async(execute: {
                                                cell.avatarIMV.image = imageRes
                                            })
                                        }
                                    } else {
                                        print("Request failed with error: \(String(describing: error))")
                                    }
                                }).fetchdata()
                                
                            } else {
                                cell.avatarIMV.image = UIImage(named: "display-empty.jpg")
                            }
                        }
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
                
                if (message.object(forKey: kText) == nil) {
                    cell.messageLB.text = ""
                } else {
                    cell.messageLB.text = message.object(forKey: kText) as? String
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: kChatMessageImageTableViewCell, for: indexPath as IndexPath) as! ChatMessageImageTableViewCell
                
                let imageURLString = message.object(forKey: kImageUrl) as? String
                
                if (imageURLString?.isEmpty == false) {
                    ImageRouter.getImage(imageURLString: imageURLString!, sizeString: widthHeight640, completed: { (result, error) in
                        if (error == nil) {
                            let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                            if visibleCell == true {
                                let imageRes = result as! UIImage
                                cell.photoIMW.image = imageRes
                            }
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }).fetchdata()
                }
                
                
                let userID = String(format:"%0.f",(message[kUserId]! as AnyObject).doubleValue)
                
                UserRouter.getUserInfo(userID: userID, completed: { (result, error) in
                    if (error == nil) {
                        let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                        if visibleCell == true {
                            let userInfo = result as! NSDictionary
                            
                            let name = userInfo.object(forKey: kFirstname) as! String
                            cell.nameLB.text = name.uppercased()
                            
                            let imageURLString = userInfo[kImageUrl] as? String
                            if (imageURLString?.isEmpty == false) {
                                ImageRouter.getImage(imageURLString: imageURLString!, sizeString: widthHeight120, completed: { (result, error) in
                                    if (error == nil) {
                                        let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                                        if visibleCell == true {
                                            let imageRes = result as! UIImage
                                            cell.avatarIMV.image = imageRes
                                        }
                                    } else {
                                        print("Request failed with error: \(String(describing: error))")
                                    }
                                }).fetchdata()
                            }
                        }
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
                
                cell.messageLB.text = (message.object(forKey: kText) == nil) ? "" :  message.object(forKey: kText) as? String
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.messageId == nil) {
            chatTBDistantCT.constant = self.view.frame.size.height/2 - 64 - 49
            tableView.isScrollEnabled = false
            
            return 1
        } else {
            if (self.arrayChat != nil) {
                chatTBDistantCT.constant = 0
                tableView.isScrollEnabled = true
                return self.arrayChat.count + 1
            } else {
                chatTBDistantCT.constant = self.view.frame.size.height/2 - 64 - 49
                tableView.isScrollEnabled = false
                return 1
            }
        }
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    // MARK: Outlet function
    func cancel() {
        if self.isSendMessage {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SEND_CHAT_MESSAGE"), object: nil)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func avatarClicked() {
        PMHelper.showCoachOrUserView(userID: self.userIdTarget, showTestimonial: false, isFromChat: true)
    }
    
    @IBAction func goPhoto(sender:UIButton!) {
        performSegue(withIdentifier: "sendPhoto", sender: nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Go Send Picture Message"]
        mixpanel?.track("IOS.ChatMessage", properties: properties)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "sendPhoto") {
            self.textBox.resignFirstResponder()
            let destinationVC = segue.destination as! SendPhotoViewController
            destinationVC.messageId = self.messageId as! NSString
            destinationVC.typeCoach = self.typeCoach
            destinationVC.coachId = self.coachId
            destinationVC.userIdTarget = self.userIdTarget as! NSString
        }
    }
    
    func sendMessage(addEmptyMessage:Bool) {
        let values : [String]
        
        values = (self.typeCoach == true) ? [coachId] : [userIdTarget as String]
        
        var prefix = kPMAPIUSER
        prefix.append(PMHelper.getCurrentID())
        prefix.append(kPM_PATH_CONVERSATION)
        prefix.append("/")
        
        let param = [kUserId : PMHelper.getCurrentID(),
                     kUserIds : values] as [String : Any]
        
        Alamofire.request(.POST, prefix, parameters: param as? [String : AnyObject])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    let JSON = response.result.value
                    let conversationId = String(format:"%0.f",JSON!.object(forKey: kId)!.doubleValue)
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
        prefix.append(PMHelper.getCurrentID())
        prefix.append(kPM_PATH_CONVERSATION)
        prefix.append("/")
        prefix.append(self.messageId as String)
        prefix.append(kPM_PARTH_MESSAGE_V2)
        
        let param = [kConversationId : self.messageId,
                     kText : textBox.text,
                     "file" : "nodata".dataUsingEncoding(NSUTF8StringEncoding)!]
        
        Alamofire.request(.POST, prefix, parameters: param as? [String : AnyObject])
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
                self.sendMessage(addEmptyMessage: true)
            }
            
            self.isSendMessage = true
            
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Navigation Click", "Label":"Send Message"]
            mixpanel?.track("IOS.ChatMessage", properties: properties)
        }
    }

    func stringArrayToNSData(array: [String]) -> NSData {
        let data = NSMutableData()
        let terminator = [0]
        for string in array {
            if let encodedString = string.data(using: NSUTF8StringEncoding) {
                data.append(encodedString)
                data.append(terminator, length: 1)
            }
        }
        return data
    }
}

