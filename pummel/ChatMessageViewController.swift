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

class ChatMessageViewController : BaseViewController {
    var nameChatUser : String!
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var chatTB: UITableView!
    @IBOutlet var cursorView: UIView!
    @IBOutlet var leftMarginLeftChatCT: NSLayoutConstraint!
    @IBOutlet var chatTBDistantCT: NSLayoutConstraint!
    @IBOutlet var avatarTextBox: UIImageView!
    @IBOutlet weak var chatTextViewHeightConstraint: NSLayoutConstraint!
    
    var typeCoach : Bool = false
    var coachName: String!
    var coachId: String!
    var userIdTarget: String!
    var targerUser: NSDictionary!
    var messageId: String!
    var arrayChat: [NSDictionary] = []
    
    var preMessage: String = ""
    
    var isSending: Bool = false
    var isSendMessage = false
    var needOpenKeyboard = false
    var isStopGetChat = false
    
    let defaults = UserDefaults.standard
    
    // MARK: Controller Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChatMessageViewController.cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        self.navigationController!.navigationBar.isTranslucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]

        self.navigationItem.hidesBackButton = true;
        
        self.chatTB.delegate = self
        self.chatTB.dataSource = self
        self.chatTB.separatorStyle = UITableViewCellSeparatorStyle.none
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.handleTap(recognizer:)))
        self.chatTB.addGestureRecognizer(recognizer)
        self.avatarTextBox.layer.cornerRadius = 20
        self.avatarTextBox.clipsToBounds = true
        self.avatarTextBox.isHidden = true
        self.getImageAvatarTextBox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.chatTextView.text = self.preMessage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.needOpenKeyboard == true) {
            self.chatTextView.becomeFirstResponder()
        }
        
        self.getArrayChat()
        self.setNavigationTitle()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getImageAvatarTextBox() {
        ImageVideoRouter.getCurrentUserAvatar(sizeString: widthHeight120, completed: { (result, error) in
            if (error == nil) {
                let textBoxImage = result as! UIImage
                
                self.avatarTextBox.image = textBoxImage
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }).fetchdata()
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.chatTextView.resignFirstResponder()
        self.view.frame.origin.y = 64
        self.cursorView.isHidden = false
        self.avatarTextBox.isHidden = true
        self.leftMarginLeftChatCT.constant = 15
    }

    func getArrayChat() {
        if (self.messageId != nil && self.isStopGetChat == false) {
            MessageRouter.getDetailConversation(messageID: self.messageId) { (result, error) in
                if (error == nil) {
                    let chatDetails = result as! [NSDictionary]
                    
                    if (chatDetails.count > 0) {
                        for chatDetail in chatDetails {
                            self.arrayChat.append(chatDetail)
                        }
                        
                        self.chatTB.reloadData {
                            let lastIndex = NSIndexPath(row: self.arrayChat.count, section: 0)
                            self.chatTB.scrollToRow(at: lastIndex as IndexPath, at: UITableViewScrollPosition.bottom, animated: false)
                        }
                    } else {
                        self.isStopGetChat = true
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
                }.fetchdata()
        } else {
            self.sendMessage(addEmptyMessage: false)
        }
    }
    
    func setNavigationTitle() {
        if (self.typeCoach == true) {
            self.navigationItem.title = coachName
        } else {
            if (nameChatUser != nil) {
                self.navigationItem.title = nameChatUser
            } else {
                UserRouter.getUserInfo(userID: self.userIdTarget, completed: { (result, error) in
                    if (error == nil) {
                        let userInfo = result as! NSDictionary
                        let name = userInfo.object(forKey: kFirstname) as! String
                        self.navigationItem.title = name.uppercased()
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
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
        if (self.chatTextView.text == "") {
            self.cursorView.isHidden = false
            self.avatarTextBox.isHidden = true
            self.leftMarginLeftChatCT.constant = 15
        }
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
    
    @IBAction func goPhoto(_ sender: Any) {
        performSegue(withIdentifier: "sendPhoto", sender: nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Go Send Picture Message"]
        mixpanel?.track("IOS.ChatMessage", properties: properties)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "sendPhoto") {
            self.chatTextView.resignFirstResponder()
            let destinationVC = segue.destination as! SendPhotoViewController
            destinationVC.messageId = self.messageId
            destinationVC.typeCoach = self.typeCoach
            destinationVC.coachId = self.coachId
            destinationVC.userIdTarget = self.userIdTarget! as NSString
        }
    }
    
    func sendMessage(addEmptyMessage:Bool) {
        let values = (self.typeCoach == true) ? self.coachId : self.userIdTarget
        
        MessageRouter.createConversationWithUser(userID: values!) { (result, error) in
            if (error == nil) {
                let messageInfo = result as! NSDictionary
                
                let conversationId = String(format:"%0.f", (messageInfo.object(forKey: kId)! as AnyObject).doubleValue)
                
                //Add message to converstaton
                self.messageId = conversationId
                
                if (addEmptyMessage) {
                    self.addMessageToExistConverstation()
                } else {
                    self.isStopGetChat = false
                    self.getArrayChat()
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    func addMessageToExistConverstation(){
        MessageRouter.sendMessage(conversationID: self.messageId, text: self.chatTextView.text, imageData: Data()) { (result, error) in
            self.isSending = false
            
            let isSendMessageSuccess = result as! Bool
            if (isSendMessageSuccess == true) {
                self.isStopGetChat = false
                self.getArrayChat()
                self.chatTextView.text = ""
                self.chatTextView.resignFirstResponder()
            }
        }.fetchdata()
    }
    
    @IBAction func sendMessageButtonClicked(_ sender: Any) {
        if !(self.chatTextView.text == "" && self.isSending == false) {
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
            if let encodedString = string.data(using: String.Encoding.utf8) {
                data.append(encodedString)
                data.append(terminator, length: 1)
            }
        }
        return data
    }
}

// MARK: - UITableViewDelegate
extension ChatMessageViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 197
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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
            
            ImageVideoRouter.getUserAvatar(userID: self.userIdTarget, sizeString: widthHeight160, completed: { (result, error) in
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
                    UserRouter.getUserInfo(userID: self.userIdTarget, completed: { (result, error) in
                        if (error == nil) {
                            let userInfo = result as! NSDictionary
                            let name = userInfo.object(forKey: kFirstname) as! String
                            cell.nameChatUserLB.text = name.uppercased()
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }).fetchdata()
                }
                
            }
            
            cell.timeLB.isHidden = true
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } else {
            let num = arrayChat.count
            let message = arrayChat[num - indexPath.row]
            let messageImageURL = message[kImageUrl] as? String
            if (messageImageURL == nil || messageImageURL?.isEmpty == true) {
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
                                
                                ImageVideoRouter.getImage(imageURLString: userImageURL, sizeString: widthHeight160, completed: { (result, error) in
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
                
                if (imageURLString != nil && imageURLString?.isEmpty == false) {
                    ImageVideoRouter.getImage(imageURLString: imageURLString!, sizeString: widthHeight640, completed: { (result, error) in
                        if (error == nil) {
                            let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                            if visibleCell == true {
                                let imageRes = result as! UIImage
                                cell.photoIMW.image = imageRes
                            }
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                            
                            let index = self.arrayChat.index(of: message)
                            if (index != nil) {
                                let tempMessage1 = message.mutableCopy() as! NSMutableDictionary
                                tempMessage1.setValue("", forKey: kImageUrl)
                                
                                self.arrayChat.remove(at: index!)
                                self.arrayChat.insert(tempMessage1, at: index!)
                            }
                            
                            
                            self.chatTB.reloadData()
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
                                ImageVideoRouter.getImage(imageURLString: imageURLString!, sizeString: widthHeight120, completed: { (result, error) in
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
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
}

// MARK: - UITextViewDelegate, UITextFieldDelegate
extension ChatMessageViewController : UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if (textView == self.chatTextView) {
            var heightText = self.chatTextView.getHeightWithWidthFixed()
            if (heightText > 100) {
                heightText = 100
            }
            
            self.chatTextViewHeightConstraint.constant = heightText
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.cursorView.isHidden = true
        self.avatarTextBox.isHidden = false
        self.leftMarginLeftChatCT.constant = 40
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.sendMessage(addEmptyMessage: true)
        return true
    }
}
