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
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChatMessageViewController.cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        self.setNavigationTitle()
       
        self.textBox.font = UIFont(name: "Montserrat-Regular", size: 13)!
//      self.textBox.attributedPlaceholder = NSAttributedString(string:"START A CONVERSATION",           attributes:([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor.blackColor()]))
       // self.textBox.delegate = self
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
        
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        prefix.appendContentsOf("/photos")
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                print(JSON)
                let listPhoto = JSON as! NSArray
                if (listPhoto.count >= 1) {
                    let photo = listPhoto[0] as! NSDictionary
                    var link = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
                    link.appendContentsOf(photo.objectForKey("imageUrl") as! String)
                    link.appendContentsOf("?width=80&height=80")
                    
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
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        prefix.appendContentsOf("/conversations/")
        if (messageId != nil) {
            prefix.appendContentsOf(self.messageId as String)
            prefix.appendContentsOf("/messages")
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
                var prefixUser = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
                prefixUser.appendContentsOf(userIdTarget)
                Alamofire.request(.GET, prefixUser)
                    .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                        let userInfo = JSON as! NSDictionary
                        let name = userInfo.objectForKey("firstname") as! String
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
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
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
            let cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageHeaderTableViewCell", forIndexPath: indexPath) as! ChatMessageHeaderTableViewCell
                var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
                prefix.appendContentsOf(userIdTarget as String)
                prefix.appendContentsOf("/photos")
                Alamofire.request(.GET, prefix)
                    .responseJSON { response in switch response.result {
                        case .Success(let JSON):
                            let listPhoto = JSON as! NSArray
                            if (listPhoto.count >= 1) {
                                let photo = listPhoto[listPhoto.count - 1] as! NSDictionary
                                var link = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
                                link.appendContentsOf(photo.objectForKey("imageUrl") as! String)
                                link.appendContentsOf("?width=80&height=80")
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
            if (typeCoach == true) {
                cell.nameChatUserLB.text = coachName
            } else {
                if (nameChatUser != nil) {
                    cell.nameChatUserLB.text = nameChatUser
                } else {
                    var prefixUser = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
                    prefixUser.appendContentsOf(userIdTarget)
                    Alamofire.request(.GET, prefixUser)
                        .responseJSON { response in switch response.result {
                        case .Success(let JSON):
                            let userInfo = JSON as! NSDictionary
                            let name = userInfo.objectForKey("firstname") as! String
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
            print (message)
            if (message["imageUrl"] is NSNull) {
                let cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageWithoutImageTableViewCell", forIndexPath: indexPath) as! ChatMessageWithoutImageTableViewCell
                
                
                var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
                prefix.appendContentsOf(String(format:"%0.f",message["userId"]!.doubleValue))
                Alamofire.request(.GET, prefix)
                        .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                            let userInfo = JSON as! NSDictionary
                            let name = userInfo.objectForKey("firstname") as! String
                            cell.nameLB.text = name.uppercaseString
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
                            var link = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
                            link.appendContentsOf(photo.objectForKey("imageUrl") as! String)
                            link.appendContentsOf("?width=80&height=80")
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
                
                if (message.objectForKey("text") == nil) {
                    cell.messageLB.text = ""
                } else {
                    cell.messageLB.text = message.objectForKey("text") as? String
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ChatMessageImageTableViewCell", forIndexPath: indexPath) as! ChatMessageImageTableViewCell
                
                var link = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
                link.appendContentsOf(message.objectForKey("imageUrl") as! String)
                link.appendContentsOf("?width=320&height=320")
                print(link)
                Alamofire.request(.GET, link)
                    .responseImage { response in
                        let imageRes = response.result.value! as UIImage
                       cell.photoIMW.image = imageRes
                }

                
                var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
                prefix.appendContentsOf(String(format:"%0.f",message["userId"]!.doubleValue))
                Alamofire.request(.GET, prefix)
                    .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                        let userInfo = JSON as! NSDictionary
                        let name = userInfo.objectForKey("firstname") as! String
                        cell.nameLB.text = name.uppercaseString
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
                            var link = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
                            link.appendContentsOf(photo.objectForKey("imageUrl") as! String)
                            link.appendContentsOf("?width=80&height=80")
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

                if (message.objectForKey("text") == nil) {
                    cell.messageLB.text = ""
                } else {
                    cell.messageLB.text = message.objectForKey("text") as? String
                }
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
        
        if (self.typeCoach == true) {
            values = [coachId]
        } else {
            values = [userIdTarget as String]
        }
        
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        prefix.appendContentsOf("/conversations/")
        Alamofire.request(.POST, prefix, parameters: ["userId":defaults.objectForKey("currentId") as! String, "userIds":values])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    let JSON = response.result.value
                    print("JSON: \(JSON)")
                    let conversationId = String(format:"%0.f",JSON!.objectForKey("id")!.doubleValue)

                    //Add message to converstaton
                    self.messageId = conversationId
                    self.addMessageToExistConverstation()
                } else {
                    print(response.response?.statusCode)
                }
        }
        
    }
    
    func addMessageToExistConverstation(){
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        prefix.appendContentsOf("/conversations/")
        prefix.appendContentsOf(self.messageId as String)
        prefix.appendContentsOf("/messages")
        Alamofire.request(.POST, prefix, parameters: ["conversationId":self.messageId, "text":textBox.text, "file":"nodata".dataUsingEncoding(NSUTF8StringEncoding)!])
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

