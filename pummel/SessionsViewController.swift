//
//  SessionsViewController.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
// Sessions will show all the users previous sessions


import UIKit
import Alamofire
import AlamofireImage
import Foundation
import Contacts
import AddressBook
import Mixpanel

class SessionsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var listMessageTB: UITableView!
//    @IBOutlet var listMessageTBTopDistance : NSLayoutConstraint?
    
    @IBOutlet weak var horizontalViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noMessageV: UIView!
    @IBOutlet weak var noMessageTitleLB: UILabel!
    @IBOutlet weak var noMessageDetailLB: UILabel!
    @IBOutlet weak var startConversationBT: UIButton!
    
    @IBOutlet weak var horizontalView: UIView!
    @IBOutlet weak var horizontalTableView : UITableView!
    @IBOutlet weak var connectionsLB : UILabel?
    @IBOutlet weak var separeateline: UIView?
    
    var arrayMessages: [NSMutableDictionary] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    var dataSourceArr : [NSDictionary] = []
    var offset : Int = 0
    var isStopLoadMessage : Bool = false
    var isLoadingMessage : Bool = false
    var saveIndexPath: NSIndexPath?
    var isGoToMessageDetail : Bool = false
    var saveIndexPathScrollView : NSIndexPath?
    var arrayListLead :[NSDictionary] = []
    
//    var currentContentOffset = CGPointZero
    
    var refreshControl: UIRefreshControl!
    
    private struct Constants {
        static let ContentSize: CGSize = CGSize(width: 80, height: 96.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listMessageTB.delegate = self
        self.listMessageTB.dataSource = self
        self.listMessageTB.separatorStyle = UITableViewCellSeparatorStyle.None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.gotNewNotificationShowBage), name: k_PM_REFRESH_MESSAGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.refreshControlTable), name: "SEND_CHAT_MESSAGE", object: nil)
        
        self.connectionsLB!.font = .pmmMonReg13()
        self.connectionsLB!.textColor = UIColor.pmmWarmGreyColor()
        self.connectionsLB!.text = kNewConnections
        
        self.horizontalTableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
        self.separeateline!.backgroundColor = UIColor.pmmWhiteColor()
        
        self.noMessageTitleLB.font = UIFont.pmmPlayFairReg18()
        self.noMessageDetailLB.font = UIFont.pmmMonLight13()
        self.startConversationBT.titleLabel!.font = UIFont.pmmMonReg12()
        
        self.startConversationBT.layer.cornerRadius = 5
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refreshControlTable), forControlEvents: UIControlEvents.ValueChanged)
        self.listMessageTB.addSubview(self.refreshControl)
        
        self.getMessage()
        
        self.getListLead()
        self.horizontalViewHeightConstraint!.constant = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        self.initNavigationBar()
        
        self.listMessageTB.reloadData()
        
        self.view.bringSubviewToFront(self.noMessageV)
        
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
            self.noMessageTitleLB.text = "Get Connections With Your Clients"
        } else {
            self.noMessageTitleLB.text = "Get Connections With Your Coaches"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let moveScreenType = self.defaults.objectForKey(k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_3 {
            defaults.setObject(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
            self.newMessage()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func initNavigationBar() {
        self.tabBarController?.title = kNavMessage
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let image = UIImage(named: "newmessage")!.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action:#selector(SessionsViewController.newMessage))
        let selectedImage = UIImage(named: "messagesSelcted")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
    }
    
    func refreshControlTable() {
        if (self.isLoadingMessage == false) {
            self.listMessageTB.contentOffset = CGPointZero
            
            self.gotNewMessage()
            
            self.getListLead()
        }
    }
    
    func gotNewMessage() {
        arrayMessages.removeAll()
        self.listMessageTB.reloadData {
            self.isStopLoadMessage = false
            self.offset = 0
            self.getMessage()
        }
    }
    
    func gotNewNotificationShowBage() {
        arrayMessages.removeAll()
        self.listMessageTB.reloadData {
            self.isStopLoadMessage = false
            self.offset = 0
            self.getMessage()
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
            if (scrollView == self.listMessageTB) {
                if (self.arrayListLead.count == 0) {
                    self.horizontalViewHeightConstraint!.constant = 0
                } else {
                    if(velocity.y > 0){
                        self.horizontalViewHeightConstraint!.constant = 0
                    } else {
                        self.horizontalViewHeightConstraint!.constant = 180
                    }
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    func getMessagetAtSaveIndexPathScrollView() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION_OFFSET_V2)
        prefix.appendContentsOf(String((self.saveIndexPath?.row)!))
        prefix.appendContentsOf(kPM_PATH_LIMIT_ONE)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let arrayMessageT = JSON as! [NSMutableDictionary]
                if (arrayMessageT.count > 0) {
                    self.arrayMessages.removeAtIndex((self.saveIndexPath?.row)!)
                    self.arrayMessages.insert(arrayMessageT[0], atIndex: (self.saveIndexPath?.row)!)
                    self.listMessageTB.reloadData()
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    @IBAction func startConversation(sender: AnyObject) {
        self.newMessage()
    }
    
    func newMessage() {
        self.performSegueWithIdentifier("newMessage", sender: nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"New Message"]
        mixpanel.track("IOS.Message", properties: properties)
    }
    
    func getListLead() {
        var prefix = kPMAPICOACHES
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPMAPICOACH_LEADS)
        
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                self.arrayListLead = JSON as! [NSDictionary]
                self.horizontalTableView.reloadData()
                if (self.arrayListLead.count == 0) {
                    self.horizontalViewHeightConstraint!.constant = 0
                } else {
                    self.horizontalViewHeightConstraint!.constant = 180
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func getMessage() {
        if (isStopLoadMessage == false) {
            if (offset == 0) {
                self.view.makeToastActivity(message: "Loading")
            }
            isLoadingMessage = true
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPM_PATH_CONVERSATION_OFFSET_V2)
            prefix.appendContentsOf(String(offset))
            Alamofire.request(.GET, prefix)
                .responseJSON { response in
                    switch response.result {
                    case .Success(let JSON):
                        let arrayMessageT = JSON as! [NSDictionary]
                        self.view.hideToastActivity()
                        if (arrayMessageT.count > 0) {
                            for (message) in arrayMessageT {
                                var isExist = false
                                for (localMessage) in self.arrayMessages {
                                    let localMessageID = localMessage[kId] as? Int
                                    let messageID = message[kId]  as? Int
                                    
                                    if (localMessageID != nil && messageID != nil) {
                                        if (localMessageID == messageID) {
                                            isExist = true
                                            break
                                        }
                                    }
                                }
                                
                                if (isExist == false) {
                                    self.arrayMessages.append(message.mutableCopy() as! NSMutableDictionary)
                                }

                            }
                            
                            self.isLoadingMessage = false
                            self.noMessageV.hidden = true
                            
                             self.listMessageTB.reloadData()
                        } else {
                            if self.arrayMessages.count <= 0 {
                                self.noMessageV.hidden = false
                            }
                            self.isLoadingMessage = false
                            self.isStopLoadMessage = true
                        }
                        
                        self.updateMessageData()
                    case .Failure(let error):
                        self.view.hideToastActivity()
                        self.offset -= 10
                        self.isLoadingMessage = false
                        print("Request failed with error: \(error)")
                    }
                    
                    self.refreshControl.endRefreshing()
            }
        }
    }
    
    func updateMessageData() {
        var i = 0
        while i < self.arrayMessages.count {
            let message = arrayMessages[i]
            
            let targetID: String? = message["targetId"] as? String
            
            if (targetID == nil || targetID?.isEmpty == true) {
                let currentUserid = defaults.objectForKey(k_PM_CURRENT_ID) as! String
                var prefix = kPMAPIUSER
                prefix.appendContentsOf(currentUserid)
                prefix.appendContentsOf(kPM_PATH_CONVERSATION)
                prefix.appendContentsOf("/")
                prefix.appendContentsOf(String(format:"%0.f", message[kId]!.doubleValue))
                
                Alamofire.request(.GET, prefix)
                    .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                        
                        // Check which on is sender
                        let conversationsUserArray = JSON as! NSArray
                        let conversationMe : NSDictionary!
                        let conversationTarget: NSDictionary!
                        let converstationTemp = conversationsUserArray[0] as! NSDictionary
                        if (String(format:"%0.f", converstationTemp[kUserId]!.doubleValue) == self.defaults.objectForKey(k_PM_CURRENT_ID) as! String) {
                            conversationMe = conversationsUserArray[0] as! NSDictionary
                            conversationTarget = conversationsUserArray[1]  as! NSDictionary
                        } else {
                            conversationMe = conversationsUserArray[1] as! NSDictionary
                            conversationTarget = conversationsUserArray[0]  as! NSDictionary
                        }
                        
                        message["targetId"] = String(format:"%0.f", conversationTarget[kUserId]!.doubleValue)
                        
                        // Check New or old
                        if (conversationMe[kLastOpenAt] is NSNull) {
                            message[kLastOpenAt] = "0"
                        } else {
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = kFullDateFormat
                            dateFormatter.timeZone = NSTimeZone(name: "UTC")
                            
                            let lastOpenAtM = dateFormatter.dateFromString(conversationMe[kLastOpenAt] as! String)
                            let updateAtM =  dateFormatter.dateFromString(message["updatedAt"] as! String)
                            
                            if (lastOpenAtM!.compare(updateAtM!) == NSComparisonResult.OrderedAscending) {
                                message[kLastOpenAt] = "0"
                            } else {
                                message[kLastOpenAt] = "1"
                            }
                        }
                        
                        // Get name
                        var prefixUser = kPMAPIUSER
                        prefixUser.appendContentsOf(String(format:"%0.f", conversationTarget[kUserId]!.doubleValue))
                        Alamofire.request(.GET, prefixUser)
                            .responseJSON { response in switch response.result {
                            case .Success(let JSON):
                                let userInfo = JSON as! NSDictionary
                                
                                let name = userInfo.objectForKey(kFirstname) as! String
                                message[kFirstname] = name.uppercaseString
                                
                                var imageURL = userInfo.objectForKey(kImageUrl) as? String
                                if (imageURL?.isEmpty == true) {
                                    imageURL = " "
                                }
                                
                                if (JSON[kImageUrl] is NSNull == false) {
                                    let imageURLString = JSON[kImageUrl] as! String
                                    
                                    ImageRouter.getImage(posString: imageURLString, sizeString: widthHeight160, completed: { (result, error) in
                                        if (error == nil) {
                                            dispatch_async(dispatch_get_main_queue(),{
                                                let imageRes = result as! UIImage
                                                message["userImage"] = imageRes
                                                
                                                self.listMessageTB.reloadData()
                                            })
                                        } else {
                                            print("Request failed with error: \(error)")
                                        }
                                    }).fetchdata()
                                } else {
                                    message["userImage"] = UIImage(named:"display-empty.jpg")
                                    
                                    self.listMessageTB.reloadData()
                                }
                                
                            case .Failure(let error):
                                print("Request failed with error: \(error)")
                                }
                        }
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        }
                }
            }
            
            // Get message
            var prefixT = kPMAPIUSER
            prefixT.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefixT.appendContentsOf(kPM_PATH_CONVERSATION)
            prefixT.appendContentsOf("/")
            prefixT.appendContentsOf(String(format:"%0.f", message[kId]!.doubleValue))
            prefixT.appendContentsOf("/messages")
            Alamofire.request(.GET, prefixT)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let arrayMessageThisConverId = JSON as! NSArray
                    if (arrayMessageThisConverId.count != 0) {
                        let messageDetail = arrayMessageThisConverId[0]
                        if (!(messageDetail[kText] is NSNull)) {
                            if (messageDetail[kText] as! String == "") {
                                message[kText] = "Media message"
                            } else {
                                message[kText] = messageDetail[kText]  as? String
                            }
                        } else {
                            if (!(messageDetail[kImageUrl] is NSNull)) {
                                message[kText] = sendYouAImage
                            } else if (!(messageDetail[KVideoUrl] is NSNull)) {
                                message[kText] = sendYouAVideo
                            } else {
                                message[kText] = "Media messge"
                            }
                        }
                    } else {
                        message[kText] = " "
                    }
                    
                    self.listMessageTB.reloadData()
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            
            i = i + 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (tableView == self.horizontalTableView) {
            if (defaults.boolForKey(k_PM_IS_COACH) == true) {
                return 96
            }
        } else {
            let message = arrayMessages[indexPath.row]
            let text = message[kText] as? String
            if (text == nil || text?.isEmpty == true || text == " ") {
                return 0
            }
            
            return 120
            // Ceiling this value fixes disappearing separators
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView == listMessageTB && arrayMessages.count != 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kMessageTableViewCell, forIndexPath: indexPath) as! MessageTableViewCell
            let message = arrayMessages[indexPath.row]
            let currentUserid = defaults.objectForKey(k_PM_CURRENT_ID) as! String
            
            // TargetID
            let targerID = message["targetId"] as? String
            if (targerID?.isEmpty == false) {
                cell.targetId = targerID
                cell.userInteractionEnabled = true
            } else {
                cell.userInteractionEnabled = false
            }
            
            
            //Get Text
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(currentUserid)
            prefix.appendContentsOf(kPM_PATH_CONVERSATION)
            prefix.appendContentsOf("/")
            prefix.appendContentsOf(String(format:"%0.f", message[kId]!.doubleValue))
            
            // Chat time
            let timeAgo = message["updatedAt"] as! String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = kFullDateFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            let dateFromString : NSDate = dateFormatter.dateFromString(timeAgo)!
            cell.timeLB.text = self.timeAgoSinceDate(dateFromString)
            
            // User name
            let nameString: String? = message[kFirstname] as? String
            if nameString?.isEmpty == false {
                cell.nameLB.text = nameString
            } else {
                cell.nameLB.text = ""
            }
            
            // User image
            let userImage = message["userImage"] as? UIImage
            if userImage != nil {
                cell.avatarIMV.image = userImage
            } else {
                cell.avatarIMV.image = UIImage(named:"display-empty.jpg")
            }
            
            // Check New or old
            let lastOpen = message[kLastOpenAt] as? String
            if lastOpen?.isEmpty == true {
                cell.isNewMessage = true
                cell.nameLB.font = .pmmMonReg13()
                cell.messageLB.font = .pmmMonReg16()
                cell.timeLB.textColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1)
            } else {
                if lastOpen == "0" {
                    cell.isNewMessage = true
                    cell.nameLB.font = .pmmMonReg13()
                    cell.messageLB.font = .pmmMonReg16()
                    cell.timeLB.textColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1)
                } else {
                    cell.nameLB.font = .pmmMonLight13()
                    cell.messageLB.font = .pmmMonLight16()
                    cell.timeLB.textColor = UIColor.blackColor()
                }
            }
            
            // Get last text
            let userMessage = message[kText] as? String
            if lastOpen?.isEmpty == false {
                cell.messageLB.text = userMessage
            } else {
                cell.messageLB.text = " "
            }
            
            return cell
        } else {
            let cellId = "HorizontalCell"
            var cell:HorizontalCell? = tableView.dequeueReusableCellWithIdentifier(cellId) as? HorizontalCell
            if cell == nil {
                cell = NSBundle.mainBundle().loadNibNamed(cellId, owner: nil, options: nil)!.first as? HorizontalCell
                cell!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0))
            }
            cell!.addButton.hidden = true
            
            let lead = self.arrayListLead[indexPath.row]
            let targetUserId = String(format:"%0.f", lead["userId"]!.doubleValue)
            
            UserRouter.getUserInfo(userID: targetUserId, completed: { (result, error) in
                if (error == nil) {
                    let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                    if visibleCell == true {
                        let userInfo = result as! NSDictionary
                        let name = userInfo.objectForKey(kFirstname) as! String
                        cell!.name.text = name.uppercaseString
                        
                        if (userInfo[kImageUrl] is NSNull == false) {
                            let imageURLString = userInfo[kImageUrl] as! String
                            ImageRouter.getImage(posString: imageURLString, sizeString: widthHeight160, completed: { (result, error) in
                                if (error == nil) {
                                    let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                                    if visibleCell == true {
                                        let imageRes = result as! UIImage
                                        cell!.imageV.image = imageRes
                                        cell!.addButton.hidden = false
                                    }
                                } else {
                                    print("Request failed with error: \(error)")
                                }
                            }).fetchdata()
                        } else {
                            cell?.imageV.image = UIImage(named: "display-empty.jpg")
                            cell!.addButton.hidden = false
                        }
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
            
            cell!.selectionStyle = .None
            return cell!
        }
    }
    
    func clickOnConnectionImage(indexPath: NSIndexPath) {
        self.saveIndexPath = indexPath
        let message = arrayMessages[indexPath.row]
        let messageId = String(format:"%0.f", message[kId]!.doubleValue)
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION_V2)
        prefix.appendContentsOf("/")
        prefix.appendContentsOf(messageId)
        
        self.view.makeToastActivity(message: "Loading")
        Alamofire.request(.PUT, prefix, parameters: [kConversationId:messageId, kUserId: defaults.objectForKey(k_PM_CURRENT_ID) as! String])
            .responseJSON { response in
                self.view.hideToastActivity()
                
                if response.response?.statusCode == 200 {
                    self.isGoToMessageDetail = true
                    self.performSegueWithIdentifier("checkChatMessage", sender: indexPath.row)
                } else {
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .Alert)
                    
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                }
        }
    }
    
    
    func clickOnRowMessage(indexPath: NSIndexPath) {
        let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if granted == false {
                    //TODO: show message not enable contact
                } else {
                    self.saveIndexPath = indexPath
                    self.isGoToMessageDetail = true
                    self.listMessageTB.deselectRowAtIndexPath(indexPath, animated: false)
                    let cell = self.horizontalTableView.cellForRowAtIndexPath(indexPath) as! HorizontalCell
                    
                    if (cell.imageV.image != nil) {
                        self.view.makeToastActivity(message: "Loading")
                        
                        let message = self.arrayMessages[indexPath.row]
                        let conversations = message[kConversation] as! NSDictionary
                        let conversationUsers = conversations[kConversationUser] as! NSArray
                        var targetUser = conversationUsers[0] as! NSDictionary
                        let currentUserid = self.defaults.objectForKey(k_PM_CURRENT_ID) as! String
                        var targetUserId = String(format:"%0.f", targetUser[kUserId]!.doubleValue)
                        if (currentUserid == targetUserId){
                            targetUser = conversationUsers[1] as! NSDictionary
                            targetUserId = String(format:"%0.f", targetUser[kUserId]!.doubleValue)
                        }
                        var prefixUser = kPMAPIUSER
                        prefixUser.appendContentsOf(targetUserId)
                        Alamofire.request(.GET, prefixUser)
                            .responseJSON { response in switch response.result {
                            case .Success(let JSON):
                                self.view.hideToastActivity()
                                
                                let userInfo = JSON as! NSDictionary
                                
                                let firstName = userInfo.objectForKey(kFirstname) as? String
                                let lastName = userInfo.objectForKey(kLastName) as? String
                                let fullName = String(format: "%@ %@", firstName!, lastName!)
                                
                                var phoneNumber = userInfo.objectForKey(kMobile) as? String
                                if phoneNumber == nil {
                                    phoneNumber = ""
                                }
                                
                                var emailString = userInfo.objectForKey(kEmail) as? String
                                if emailString == nil {
                                    emailString = ""
                                }
                                
                                var facebookURL = userInfo.objectForKey(kFacebookUrl) as? String
                                if facebookURL == nil {
                                    facebookURL = ""
                                }
                                
                                var twitterURL = userInfo.objectForKey(kTwitterUrl) as? String
                                if twitterURL == nil {
                                    twitterURL = ""
                                }
                                
                                var DOBString = (userInfo.objectForKey(kDob) as? String)
                                if twitterURL == nil {
                                    twitterURL = "1990-01-01"
                                } else {
                                    DOBString = DOBString?.substringToIndex(DOBString!.startIndex.advancedBy(10))
                                }
                                
                                let newContact = CNMutableContact()
                                
                                newContact.givenName = firstName!
                                newContact.middleName = lastName!
                                if let image = cell.imageV.image,
                                    let data = UIImagePNGRepresentation(image) {
                                    newContact.imageData = data
                                }
                                
                                let phone = CNLabeledValue(label: CNLabelWork, value:CNPhoneNumber(stringValue: phoneNumber!))
                                newContact.phoneNumbers = [phone]
                                let email = CNLabeledValue(label: CNLabelWork, value:emailString!)
                                newContact.emailAddresses = [email]
                                
                                let facebookProfile = CNLabeledValue(label: "Facebook", value: CNSocialProfile(urlString: facebookURL, username: fullName, userIdentifier: fullName, service: CNSocialProfileServiceFacebook))
                                
                                let twitterProfile = CNLabeledValue(label: "Twitter", value: CNSocialProfile(urlString: twitterURL, username: fullName, userIdentifier: fullName, service: CNSocialProfileServiceTwitter))
                                
                                newContact.socialProfiles = [facebookProfile, twitterProfile]
                                
                                let DOBArray = DOBString?.componentsSeparatedByString("-")
                                if (DOBArray?.count == 3) {
                                    let birthday = NSDateComponents()
                                    birthday.year = Int(DOBArray![0])!
                                    birthday.month = Int(DOBArray![1])!
                                    birthday.day = Int(DOBArray![2])!
                                    newContact.birthday = birthday
                                }
                                
                                
                                let alert = UIAlertController(title: pmmNotice, message: "", preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { _ in }))
                                
                                let request = CNSaveRequest()
                                request.addContact(newContact, toContainerWithIdentifier: nil)
                                do {
                                    let store = CNContactStore()
                                    
                                    let contacts = try store.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName(fullName), keysToFetch:[CNContactGivenNameKey, CNContactFamilyNameKey])
                                    
                                    if (contacts.count == 0) {
                                        try store.executeSaveRequest(request)
                                    } else {
                                        alert.message = contactExist
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
                                    
                                    
                                } catch let error{
                                    print(error)
                                    
                                    alert.message = pleaseDoItAgain
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                                
                            case .Failure(let error):
                                self.view.hideToastActivity()
                                
                                print("Request failed with error: \(error)")
                                }
                        }
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell , forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.arrayMessages.count - 1 && isLoadingMessage == false && tableView == self.listMessageTB) {
            offset += 10
            self.getMessage()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.listMessageTB) {
            return self.arrayMessages.count
        } else {
            return self.arrayListLead.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        var properties = ["Name": "Navigation Click", "Label":"Go Chat"]
        
        if (tableView == listMessageTB) {
            // Check new message here
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! MessageTableViewCell
//            if (cell.isNewMessage == true) {
//                var bageValue = NSUserDefaults.standardUserDefaults().integerForKey("MESSAGE_BADGE_VALUE")
//                bageValue = bageValue - 2
//                NSUserDefaults.standardUserDefaults().setInteger(bageValue, forKey: "MESSAGE_BADGE_VALUE")
//                NSNotificationCenter.defaultCenter().postNotificationName(k_PM_SHOW_MESSAGE_BADGE_WITHOUT_REFRESH, object: nil)
//            }
            
            
            self.clickOnConnectionImage(indexPath)
            
            
            properties = ["Name": "Navigation Click", "Label":"Add Contact"]
        } else {
            
            let addToIphoneContact = { (action:UIAlertAction!) -> Void in
                self.clickOnRowMessage(indexPath)
            }
            
            let viewProfile = { (action:UIAlertAction!) -> Void in
                self.performSegueWithIdentifier(kGoUserProfile, sender: indexPath.row)
            }
            
            let setAsCurrentUserUnderTrained = { (action:UIAlertAction!) -> Void in
                self.view.makeToast(message: "Setting")
                let lead = self.arrayListLead[indexPath.row]
                let targetUserId = String(format:"%0.f", lead[kUserId]!.doubleValue)
               
                
                var prefix = kPMAPICOACHES
                prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
                prefix.appendContentsOf(kPMAPICOACH_CURRENT)
                prefix.appendContentsOf("/")
                print(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
                Alamofire.request(.PUT, prefix, parameters: [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, kUserIdRequest:targetUserId])
                    .responseJSON { response in
                        self.view.hideToastActivity()
                        
                        if response.response?.statusCode == 200 {
                            self.arrayListLead.removeAll()
                            self.getListLead()
                        }
                }
            }
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alertController.addAction(UIAlertAction(title: kAddToIphoneContact, style: UIAlertActionStyle.Destructive, handler: addToIphoneContact))
            alertController.addAction(UIAlertAction(title: kViewProfile, style: UIAlertActionStyle.Destructive, handler: viewProfile))
            alertController.addAction(UIAlertAction(title: kSetToCurrentCustomer, style: UIAlertActionStyle.Destructive, handler: setAsCurrentUserUnderTrained))
            alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
            
            self.presentViewController(alertController, animated: true) { }
        }
        
        mixpanel.track("IOS.Message", properties: properties)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "checkChatMessage") {
            let destinationVC = segue.destinationViewController as! ChatMessageViewController
            let indexPathRow = sender as! Int
            let message = arrayMessages[indexPathRow]
            message[kLastOpenAt] = "1"
            let cell = self.listMessageTB.cellForRowAtIndexPath(NSIndexPath.init(forRow: indexPathRow, inSection: 0)) as! MessageTableViewCell
            
            destinationVC.userIdTarget = cell.targetId
            destinationVC.messageId = String(format:"%0.f", message[kId]!.doubleValue)
        }
        
        if (segue.identifier == kGoUserProfile) {
            let destination = segue.destinationViewController as! UserProfileViewController
            
            let indexPathRow = sender as! Int
            
            let lead = self.arrayListLead[indexPathRow]
            let targetUserId = String(format:"%0.f", lead[kUserId]!.doubleValue)
            
            destination.userId = targetUserId
            destination.userDetail = lead
        }
    }

    func timeAgoSinceDate(date:NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .Month, .Year]
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options:NSCalendarOptions.MatchPreviousTimePreservingSmallerUnits)
        
        if (components.year >= 2) {
            return "\(components.year)y"
        } else if (components.year >= 1){
            return "1y"
        } else if (components.month >= 2) {
            return "\(components.month)month"
        } else if (components.month >= 1){
            return "1m"
        } else if (components.day >= 2) {
            return "\(components.day)d"
        } else if (components.day >= 1){
            return "1d"
        } else if (components.hour >= 2) {
            return "\(components.hour)hr"
        } else if (components.hour >= 1){
            return "1hr"
        } else if (components.minute >= 2) {
            return "\(components.minute)m"
        } else if (components.minute >= 1){
            return "1m"
        } else if (components.second >= 20) {
            return "\(components.second)s"
        } else {
            return "Just now"
        }
    }
}
