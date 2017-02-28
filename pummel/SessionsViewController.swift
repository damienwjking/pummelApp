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
    @IBOutlet var listMessageTBTopDistance : NSLayoutConstraint?
    
    @IBOutlet weak var noMessageV: UIView!
    @IBOutlet weak var noMessageTitleLB: UILabel!
    @IBOutlet weak var noMessageDetailLB: UILabel!
    @IBOutlet weak var startConversationBT: UIButton!
    
    var arrayMessages: [NSDictionary] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    var dataSourceArr : [NSDictionary] = []
    var scrollTableView : UITableView!
    var offset : Int = 0
    var isStopLoadMessage : Bool = false
    var isLoadingMessage : Bool = false
    var saveIndexPath: NSIndexPath?
    var isGoToMessageDetail : Bool = false
    var saveIndexPathScrollView : NSIndexPath?
    var connectionsLB : UILabel?
    var arrayListLead :[NSDictionary] = []
    var separeateline: UIView?
    
    private struct Constants {
        static let ContentSize: CGSize = CGSize(width: 80, height: 96.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listMessageTB.delegate = self
        self.listMessageTB.dataSource = self
        self.listMessageTB.separatorStyle = UITableViewCellSeparatorStyle.None
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(SessionsViewController.gotNewNotificationShowBage), name: k_PM_REFRESH_MESSAGE, object: nil)
        
        
        self.noMessageTitleLB.font = UIFont.pmmPlayFairReg18()
        self.noMessageDetailLB.font = UIFont.pmmMonLight13()
        self.startConversationBT.titleLabel!.font = UIFont.pmmMonReg12()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.title = kNavMessage
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let image = UIImage(named: "newmessage")!.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action:#selector(SessionsViewController.newMessage))
        let selectedImage = UIImage(named: "messagesSelcted")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        if (isGoToMessageDetail == false) {
            arrayMessages.removeAll()
            self.listMessageTB.reloadData()
            isStopLoadMessage = false
            offset = 0
            self.getMessage()
        } else {
            self.isGoToMessageDetail = false
            self.getMessagetAtSaveIndexPathScrollView()
        }
        
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
            self.noMessageTitleLB.text = "Get Connections With Your Clients"
            
            connectionsLB = UILabel.init(frame: CGRectMake(0, 15, self.view.frame.size.width, 14))
            connectionsLB!.font = .pmmMonReg13()
            connectionsLB!.textColor = UIColor.pmmWarmGreyColor()
            connectionsLB!.textAlignment = .Center
            connectionsLB!.text = kNewConnections
            self.view.addSubview(connectionsLB!)
            self.listMessageTBTopDistance!.constant = 180
            
            let SCREEN_MAX_LENGTH = max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
                self.scrollTableView = UITableView(frame: CGRectMake(112, -50, 96, self.view.frame.size.width))
            } else {
                self.scrollTableView = UITableView(frame: CGRectMake(150, -96, 96, self.view.frame.size.width))
            }
            self.arrayListLead.removeAll()
            self.scrollTableView.reloadData()
            self.getListLead()
            self.view.addSubview(scrollTableView)
            self.scrollTableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
            self.scrollTableView.separatorStyle = .None
            self.scrollTableView.rowHeight = 96
            self.scrollTableView.separatorStyle = .None
            self.scrollTableView.showsHorizontalScrollIndicator = false
            self.scrollTableView.showsVerticalScrollIndicator = false
            separeateline = UIView.init(frame: CGRectMake(0, 179.5, self.view.frame.width, 0.5))
            separeateline!.backgroundColor = UIColor.pmmWhiteColor()
            self.view.addSubview(separeateline!)
            self.view.bringSubviewToFront(self.noMessageV)
        } else {
            self.noMessageTitleLB.text = "Get Connections With Your Coaches"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let touch3DType = defaults.objectForKey(k_PM_3D_TOUCH) as! String
        if touch3DType == "3dTouch_3" {
            defaults.setObject(k_PM_3D_TOUCH_VALUE, forKey: k_PM_3D_TOUCH)
            self.newMessage()
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
    
    func getMessagetAtSaveIndexPathScrollView() {
        let message = self.arrayMessages[(self.saveIndexPath?.row)!]
        let messageID = message.objectForKey(kConversationId) as! Int
        
        var offset = 0;
        for (messageItem) in self.arrayMessages {
            let messageItemID = messageItem.objectForKey(kConversationId) as! Int
            
            if messageID > messageItemID {
                offset = offset + 1
            }
        }
        
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION_OFFSET)
        prefix.appendContentsOf(String((offset)))
        prefix.appendContentsOf(kPM_PATH_LIMIT_ONE)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let arrayMessageT = JSON as! [NSDictionary]
                if (arrayMessageT.count > 0) {
                    self.arrayMessages.removeAtIndex((self.saveIndexPath?.row)!)
                    self.arrayMessages.insert(arrayMessageT[0], atIndex: (self.saveIndexPath?.row)!)
                    
                    self.sortMessage()
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
                self.scrollTableView.delegate = self
                self.scrollTableView.dataSource = self
                self.scrollTableView.reloadData()
                if (self.arrayListLead.count == 0) {
                    self.listMessageTBTopDistance!.constant = 0
                    self.scrollTableView.hidden = true
                    self.connectionsLB!.hidden = true
                    self.separeateline?.hidden = true
                } else {
                    self.scrollTableView.hidden = false
                    self.listMessageTBTopDistance!.constant = 180
                    self.connectionsLB!.hidden = false
                    self.separeateline?.hidden = false
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func sortMessage() {
        if self.arrayMessages.count > 0 {
            self.arrayMessages = self.arrayMessages.sort { (message1, message2) -> Bool in
                let lastOpen1 = message1["conversation"]!["updatedAt"] as? String
                if lastOpen1 == nil {
                    return true
                }
                
                let lastOpen2 = message2["conversation"]!["updatedAt"] as? String
                if lastOpen2 == nil {
                    return false
                }
                
                return (lastOpen1!.compare(lastOpen2!) == NSComparisonResult.OrderedDescending)
            }
        }
    }
    
    func getMessage() {
        if (isStopLoadMessage == false) {
            isLoadingMessage = true
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPM_PATH_CONVERSATION_OFFSET)
            prefix.appendContentsOf(String(offset))
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let arrayMessageT = JSON as! [NSDictionary]
                    if (arrayMessageT.count > 0) {
                        self.arrayMessages += arrayMessageT
                        self.isLoadingMessage = false
                        self.listMessageTB.reloadData()
                        self.noMessageV.hidden = true
                    } else {
                        if self.arrayMessages.count <= 0 {
                            self.noMessageV.hidden = false
                        }
                        self.isLoadingMessage = false
                        self.isStopLoadMessage = true
                    }
                    self.sortMessage()
                    self.view.bringSubviewToFront(self.noMessageV)
                case .Failure(let error):
                    self.offset -= 10
                    self.isLoadingMessage = false
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (defaults.boolForKey(k_PM_IS_COACH) == true) { if (tableView == self.scrollTableView) {
                return 96
            }
        }
        return 120
        // Ceiling this value fixes disappearing separators
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView == listMessageTB && arrayMessages.count != 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kMessageTableViewCell, forIndexPath: indexPath) as! MessageTableViewCell
            let message = arrayMessages[indexPath.row]
            let currentUserid = defaults.objectForKey(k_PM_CURRENT_ID) as! String
            //Get Text
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPM_PATH_CONVERSATION)
            prefix.appendContentsOf("/")
            prefix.appendContentsOf(String(format:"%0.f", message[kConversationId]!.doubleValue))
            prefix.appendContentsOf(kPM_PARTH_MESSAGE)
            prefix.appendContentsOf("?limit=1")
            
            let timeAgo = message["conversation"]!["updatedAt"] as! String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = kFullDateFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            let dateFromString : NSDate = dateFormatter.dateFromString(timeAgo)!
            cell.timeLB.text = self.timeAgoSinceDate(dateFromString)
            
            if (message[kLastOpenAt] is NSNull) {
                cell.nameLB.font = .pmmMonReg13()
                cell.messageLB.font = .pmmMonReg16()
                cell.timeLB.textColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1)
            } else {
                let lastOpenAtM = dateFormatter.dateFromString(message[kLastOpenAt] as! String)
                let updateAtM =  dateFormatter.dateFromString(message["conversation"]!["updatedAt"] as! String)
                if (lastOpenAtM!.compare(updateAtM!) == NSComparisonResult.OrderedAscending) {
                    cell.nameLB.font = .pmmMonReg13()
                    cell.messageLB.font = .pmmMonReg16()
                    cell.timeLB.textColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1)
                } else {
                    cell.messageLB.font = .pmmMonLight16()
                    cell.timeLB.textColor = UIColor.blackColor()
                    cell.isNewMessage = false
                }
            }
            
            let messageText = message[kText] as? String
            
            if messageText?.isEmpty == false {
                cell.messageLB.text = messageText
            } else {
                cell.messageLB.text = " "
                Alamofire.request(.GET, prefix)
                    .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                        let arrayMessageThisConverId = JSON as! NSArray
                        if (arrayMessageThisConverId.count != 0) {
                            let messageDetail = arrayMessageThisConverId[0]
                            if (!(messageDetail[kText] is NSNull)) {
                                cell.messageLB.text = messageDetail[kText]  as? String
                                if (messageDetail[kText] as! String == "") {
                                    cell.messageLB.text = "Media message"
                                }
                            } else {
                                if (!(messageDetail[kImageUrl] is NSNull)) {
                                    cell.messageLB.text = sendYouAImage
                                } else if (!(messageDetail[KVideoUrl] is NSNull)) {
                                    cell.messageLB.text = sendYouAVideo
                                } else
                                {
                                    cell.messageLB.text = "Media messge"
                                }
                            }
                        } else {
                            cell.messageLB.text = " "
                        }
                        
                        // Update message
                        let messageIndex = self.arrayMessages.indexOf(message)
                        
                        if messageIndex != nil {
                            let mutaMessage = message.mutableCopy() as! NSMutableDictionary
                            mutaMessage[kText] = cell.messageLB.text
                            let newMessage = NSDictionary(dictionary: mutaMessage)
                            
                            self.arrayMessages.removeAtIndex(messageIndex!)
                            self.arrayMessages.insert(newMessage, atIndex: messageIndex!)
                        }
                        
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        }
                }
            }
        
            
            let nameText = message[kFirstname] as? String
            
            if nameText?.isEmpty == false {
                cell.nameLB.text = nameText?.uppercaseString
                
                let imageURL = message[kImageUrl] as? String
                if (imageURL?.isEmpty == false) {
                    var link = kPMAPI
                    link.appendContentsOf(imageURL!)
                    link.appendContentsOf(widthHeight160)
                    if (NSCache.sharedInstance.objectForKey(link) != nil) {
                        let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                        cell.avatarIMV.image = imageRes
                    } else {
                        cell.avatarIMV.image = UIImage(named:"display-empty.jpg")
                    }
                } else {
                    cell.avatarIMV.image = UIImage(named:"display-empty.jpg")
                }
            } else {
                let conversations = message[kConversation] as! NSDictionary
                let conversationUsers = conversations[kConversationUser] as! NSArray
                var targetUser = conversationUsers[0] as! NSDictionary
                
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
                        let userInfo = JSON as! NSDictionary
                        
                        let name = userInfo.objectForKey(kFirstname) as! String
                        cell.nameLB.text = name.uppercaseString
                        
                        var imageURL = userInfo.objectForKey(kImageUrl) as? String
                        if (imageURL?.isEmpty == true) {
                            imageURL = " "
                        }
                        
                        // Update message
                        let messageIndex = self.arrayMessages.indexOf(message)
                        
                        if messageIndex != nil {
                            let mutaMessage = message.mutableCopy() as! NSMutableDictionary
                            mutaMessage[kFirstname] = name
                            mutaMessage[kImageUrl] = imageURL
                            let newMessage = NSDictionary(dictionary: mutaMessage)
                            
                            self.arrayMessages.removeAtIndex(messageIndex!)
                            self.arrayMessages.insert(newMessage, atIndex: messageIndex!)
                        }
                        
                        var link = kPMAPI
                        if !(JSON[kImageUrl] is NSNull) {
                            link.appendContentsOf(JSON[kImageUrl] as! String)
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
                                            tableView.reloadData()
                                        }
                                }
                            }
                        } else {
                            cell.avatarIMV.image = UIImage(named:"display-empty.jpg")
                        }
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        }
                }
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
            var prefixUser = kPMAPIUSER
            prefixUser.appendContentsOf(targetUserId)
            Alamofire.request(.GET, prefixUser)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let userInfo = JSON as! NSDictionary
                    let name = userInfo.objectForKey(kFirstname) as! String
                    cell!.name.text = name.uppercaseString
                    var link = kPMAPI
                    if !(JSON[kImageUrl] is NSNull) {
                        link.appendContentsOf(JSON[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight160)
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                cell!.imageV.image = imageRes
                                cell!.addButton.hidden = false
                        }
                    } else {
                        cell?.imageV.image = UIImage(named: "display-empty.jpg")
                        cell!.addButton.hidden = false
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            cell!.selectionStyle = .None
            return cell!
        }
    }
    
    func clickOnConnectionImage(indexPath: NSIndexPath) {
        self.saveIndexPath = indexPath
        let message = arrayMessages[indexPath.row]
        let messageId = String(format:"%0.f", message[kConversationId]!.doubleValue)
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION_V2)
        prefix.appendContentsOf("/")
        prefix.appendContentsOf(String(format:"%0.f", message[kConversationId]!.doubleValue))
        Alamofire.request(.PUT, prefix, parameters: [kConversationId:messageId, kUserId: defaults.objectForKey(k_PM_CURRENT_ID) as! String])
            .responseJSON { response in
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
                    let cell = self.scrollTableView.cellForRowAtIndexPath(indexPath) as! HorizontalCell
                    
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
            let conversations = message[kConversation] as! NSDictionary
            let conversationUsers = conversations[kConversationUser] as! NSArray
            var targetUser = conversationUsers[0] as! NSDictionary
            var targetUserId = String(format:"%0.f", targetUser[kUserId]!.doubleValue)
            let currentUserid = defaults.objectForKey(k_PM_CURRENT_ID) as! String
            if (currentUserid == targetUserId){
                targetUser = conversationUsers[1] as! NSDictionary
                targetUserId = String(format:"%0.f", targetUser[kUserId]!.doubleValue)
            }
            destinationVC.userIdTarget = targetUserId
            destinationVC.messageId = String(format:"%0.f", message[kConversationId]!.doubleValue)
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
            return "\(components.month)m"
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
