//
//  MessageViewController.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
// Sessions will show all the users previous sessions


import UIKit
import Contacts
import Mixpanel
import Alamofire
import MessageUI
import Foundation
import AddressBook
import AlamofireImage

class MessageViewController: BaseViewController {
    
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
    
    var arrayMessages: [MessageModel] = []
    let defaults = UserDefaults.standard
    var dataSourceArr : [NSDictionary] = []
    var messageOffset : Int = 0
    var leadOffset : Int = 0
    var isStopLoadLead = false
    var isStopLoadMessage = false
    var isLoadingMessage = false
    var saveIndexPath: NSIndexPath?
    var isGoToMessageDetail = false
    var saveIndexPathScrollView : NSIndexPath?
    var arrayListLead :[NSDictionary] = []
    
//    var currentContentOffset = CGPoint()
    
    var refreshControl: UIRefreshControl!
    
    private struct Constants {
        static let ContentSize: CGSize = CGSize(width: 80, height: 96.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listMessageTB.delegate = self
        self.listMessageTB.dataSource = self
        self.listMessageTB.separatorStyle = UITableViewCellSeparatorStyle.none
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotNewNotificationShowBage), name: NSNotification.Name(rawValue: k_PM_REFRESH_MESSAGE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshControlTable), name: NSNotification.Name(rawValue: "SEND_CHAT_MESSAGE"), object: nil)
        
        self.connectionsLB!.font = .pmmMonReg13()
        self.connectionsLB!.textColor = UIColor.pmmWarmGreyColor()
        self.connectionsLB!.text = kNewConnections
        
        self.horizontalTableView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2.0))
        self.separeateline!.backgroundColor = UIColor.pmmWhiteColor()
        
        self.noMessageTitleLB.font = UIFont.pmmPlayFairReg18()
        self.noMessageDetailLB.font = UIFont.pmmMonLight13()
        self.startConversationBT.titleLabel!.font = UIFont.pmmMonReg12()
        
        self.startConversationBT.layer.cornerRadius = 5
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refreshControlTable), for: .valueChanged)
        self.listMessageTB.addSubview(self.refreshControl)
        
        self.horizontalViewHeightConstraint!.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initNavigationBar()
        
        self.listMessageTB.reloadData()
        
        self.view.bringSubview(toFront: self.noMessageV)
        
        if (defaults.bool(forKey: k_PM_IS_COACH) == true) {
            self.noMessageTitleLB.text = "Get Connections With Your Clients"
        } else {
            self.noMessageTitleLB.text = "Get Connections With Your Coaches"
        }
        
        self.isGoToMessageDetail = false
        
        self.getMessage()
        
        self.leadOffset = 0
        self.isStopLoadLead = false
        self.getListLead()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let moveScreenType = self.defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if (moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_3) {
            defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
            self.newMessage()
        } else if (moveScreenType == k_PM_MOVE_SCREEN_MESSAGE_DETAIL) {
            self.defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
            
            // Get message data and separate to ID
            let userID = defaults.object(forKey: k_PM_MOVE_SCREEN_MESSAGE_DETAIL) as! String
            self.defaults.removeObject(forKey: k_PM_MOVE_SCREEN_MESSAGE_DETAIL)
            
            self.isGoToMessageDetail = true
            self.performSegue(withIdentifier: "checkChatMessage", sender: userID)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func initNavigationBar() {
        self.tabBarController?.title = kNavMessage
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let image = UIImage(named: "newmessage")!.withRenderingMode(.alwaysOriginal)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.newMessage))
        let selectedImage = UIImage(named: "messagesSelcted")
        self.tabBarItem.selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
    }
    
    func refreshControlTable() {
        if (self.isLoadingMessage == false) {
            self.listMessageTB.contentOffset = CGPoint()
            
            self.gotNewMessage()
            
            self.leadOffset = 0
            self.isStopLoadLead = false
            self.getListLead()
        }
    }
    
    func gotNewMessage() {
        self.arrayMessages.removeAll()
        self.isStopLoadMessage = false
        self.messageOffset = 0
        
        self.getMessage()
    }
    
    func gotNewNotificationShowBage() {
        self.arrayMessages.removeAll()
        self.isStopLoadMessage = false
        self.messageOffset = 0
        
        self.getMessage()
    }
    
    @IBAction func startConversation(sender: AnyObject) {
        self.newMessage()
    }
    
    func newMessage() {
        self.performSegue(withIdentifier: "newMessage", sender: nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"New Message"]
        mixpanel?.track("IOS.Message", properties: properties)
    }
    
    func getListLead() {
        if (self.isStopLoadLead == false) {
            let currentUserID = PMHelper.getCurrentID()
            UserRouter.getLead(userID: currentUserID, type: kPMAPICOACH_LEADS, offset: self.leadOffset) { (result, error) in
                if (error == nil) {
                    let leadList =  result as! [NSDictionary]
                    if leadList.count > 0 {
                        self.getListLead()
                        
                        self.arrayListLead += leadList
                        self.leadOffset = self.leadOffset + 10
                        
                        if (self.arrayListLead.count == 0) {
                            self.horizontalViewHeightConstraint!.constant = 0
                        } else {
                            self.horizontalViewHeightConstraint!.constant = 180
                        }
                    } else {
                        self.isStopLoadLead = true
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.isStopLoadLead = true
                }
                }.fetchdata()
        }
    }
    
    func getMessage() {
        if (self.isStopLoadMessage == false && self.isLoadingMessage == false) {
            if (self.messageOffset == 0) {
                self.view.makeToastActivity(message: "Loading")
            }
            
            self.isLoadingMessage = true
            
            MessageRouter.getConversationList(offset: self.messageOffset, completed: { (result, error) in
                self.view.hideToastActivity()
                self.refreshControl.endRefreshing()
                
                self.isLoadingMessage = false
                
                if (error == nil) {
                    let messageList = result as! [MessageModel]
                    
                    if (messageList.count == 0) {
                        self.isStopLoadMessage = true
                    } else {
                        for message in messageList {
                            if (message.existInList(messageList: self.arrayMessages) == false) {
                                self.arrayMessages.append(message)
                            }
                        }
                    }
                    
                    self.messageOffset = self.messageOffset + 10
                    
                    self.updateMessageData()
                    self.listMessageTB.reloadData()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
    
    func updateMessageData() {
        var i = 0
        while i < self.arrayMessages.count {
            let message = arrayMessages[i]
            
            MessageRouter.getDetailConversation(messageID: message.messageID!, completed: { (result, error) in
                if (error == nil) {
                    // Check which on is sender
                    let conversationsUserArray = result as! NSArray
                    let conversationMe : NSDictionary!
                    let conversationTarget: NSDictionary!
                    
                    let converstationTemp = conversationsUserArray[0] as! NSDictionary
                    let tempUserID = String(format:"%0.f", (converstationTemp[kUserId]! as AnyObject).doubleValue)
                    
                    if (tempUserID == PMHelper.getCurrentID()) {
                        conversationMe = conversationsUserArray[0] as! NSDictionary
                        conversationTarget = conversationsUserArray[1]  as! NSDictionary
                    } else {
                        conversationMe = conversationsUserArray[1] as! NSDictionary
                        conversationTarget = conversationsUserArray[0]  as! NSDictionary
                    }
                    
                    message.targetUserID = String(format:"%0.f", (conversationTarget[kUserId]! as AnyObject).doubleValue)
                    
                    // Check New or old
                    if (conversationMe[kLastOpenAt] is NSNull) {
                        message.isOpen = false
                    } else {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = kFullDateFormat
                        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
                        
                        let lastOpenAtM = dateFormatter.date(from: conversationMe[kLastOpenAt] as! String)
                        let updateAtM =  dateFormatter.date(from: message.updateAt!)
                        
                        if (lastOpenAtM!.compare(updateAtM!) == .orderedAscending) {
                            message.isOpen = false
                        } else {
                            message.isOpen = true
                        }
                    }
                    
                    // Get name
                    UserRouter.getUserInfo(userID: message.targetUserID!, completed: { (result, error) in
                        let userInfo = result as! NSDictionary
                        
                        let name = userInfo.object(forKey: kFirstname) as! String
                        message.targetUserName = name.uppercased()
                        
                        var imageURL = userInfo.object(forKey: kImageUrl) as? String
                        if (imageURL?.isEmpty == true) {
                            imageURL = " "
                        }
                        
                        if (userInfo[kImageUrl] is NSNull == false) {
                            let imageURLString = userInfo[kImageUrl] as! String
                            
                            ImageVideoRouter.getImage(imageURLString: imageURLString, sizeString: widthHeight160, completed: { (result, error) in
                                if (error == nil) {
                                    DispatchQueue.main.async(execute: {
                                        let imageRes = result as! UIImage
                                        message.targetUserImage = imageRes
                                        
                                        self.listMessageTB.reloadData()
                                    })
                                } else {
                                    print("Request failed with error: \(String(describing: error))")
                                }
                            }).fetchdata()
                        } else {
                            message.targetUserImage = UIImage(named:"display-empty.jpg")
                            
                            self.listMessageTB.reloadData()
                        }
                    }).fetchdata()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()

            // Get message
            MessageRouter.getDetailConversation(messageID: message.messageID!, completed: { (result, error) in
                if (error == nil) {
                    let arrayMessageThisConverId = result as! NSArray
                    if (arrayMessageThisConverId.count != 0) {
                        let messageDetail = arrayMessageThisConverId[0] as! NSDictionary
                        
                        if ((messageDetail[kText] is NSNull) == false) {
                            if (messageDetail[kText] as! String == "") {
                                message.text = "Media message"
                            } else {
                                message.text = messageDetail[kText]  as? String
                            }
                        } else {
                            if (!(messageDetail[kImageUrl] is NSNull)) {
                                message.text = sendYouAImage
                            } else if (!(messageDetail[KVideoUrl] is NSNull)) {
                                message.text = sendYouAVideo
                            } else {
                                message.text = "Media messge"
                            }
                        }
                    } else {
                        message.text = " "
                    }
                    
                    self.listMessageTB.reloadData()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
            
            i = i + 1
        }
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "checkChatMessage") {
            let destinationVC = segue.destination as! ChatMessageViewController
            
            if (self.isGoToMessageDetail == false) {
                let indexPathRow = sender as! Int
                let message = arrayMessages[indexPathRow]
                message.isOpen = true
                let cell = self.listMessageTB.cellForRow(at: NSIndexPath(row: indexPathRow, section: 0) as IndexPath) as! MessageTableViewCell
                
                destinationVC.userIdTarget = cell.targetId
                destinationVC.messageId = message.messageID
            } else {
                let userID = sender as! String
                destinationVC.userIdTarget = userID
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (defaults.bool(forKey: k_PM_IS_COACH) == true) {
            if (scrollView == self.listMessageTB) {
                if (self.arrayListLead.count == 0) {
                    self.horizontalViewHeightConstraint!.constant = 0
                } else {
                    if(velocity.y > 0){
                        self.horizontalViewHeightConstraint!.constant = 0
                    } else {
                        self.horizontalViewHeightConstraint!.constant = 180
                    }
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView == self.horizontalTableView) {
            if (defaults.bool(forKey: k_PM_IS_COACH) == true) {
                return 96
            }
        } else {
            let message = arrayMessages[indexPath.row]
            let text = message.text
            if (text == nil || text?.isEmpty == true || text == " ") {
                return 0
            }
            
            return 120
            // Ceiling this value fixes disappearing separators
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == listMessageTB && arrayMessages.count != 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: kMessageTableViewCell, for: indexPath) as! MessageTableViewCell
            let message = arrayMessages[indexPath.row]
            
            cell.setupData(message: message)
            
            return cell
        } else {
            let cellId = "HorizontalCell"
            var cell:HorizontalCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? HorizontalCell
            if cell == nil {
                cell = Bundle.main.loadNibNamed(cellId, owner: nil, options: nil)!.first as? HorizontalCell
                cell!.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
            }
            cell!.addButton.isHidden = true
            
            let lead = self.arrayListLead[indexPath.row]
            let targetUserId = String(format:"%0.f", (lead["userId"]! as AnyObject).doubleValue)
            
            UserRouter.getUserInfo(userID: targetUserId, completed: { (result, error) in
                if (error == nil) {
                    let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath as NSIndexPath)
                    if visibleCell == true {
                        let userInfo = result as! NSDictionary
                        cell?.setupData(leadDictionay: userInfo)
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
            
            return cell!
        }
    }
    
    func clickOnConnectionImage(indexPath: NSIndexPath) {
        self.saveIndexPath = indexPath
        let message = arrayMessages[indexPath.row]
        
        self.view.makeToastActivity(message: "Loading")
        MessageRouter.setOpenMessage(messageID: message.messageID!) { (result, error) in
            self.view.hideToastActivity()
            
            let isChangeSuccess = result as! Bool
            if (isChangeSuccess == true) {
                // TODO: get number badge: maybe call func get number badge in chat message
//                let numberBadge = result as? Int
//                let messageTabItem = self.tabBarController?.tabBar.items![3]
//                if (numberBadge != nil && numberBadge > 0) {
//                    messageTabItem?.badgeValue = String(format: "%d", numberBadge!)
//                } else {
//                    messageTabItem?.badgeValue = nil
//                }
                
                self.performSegue(withIdentifier: "checkChatMessage", sender: indexPath.row)
            } else {
                PMHelper.showDoAgainAlert()
            }
        }.fetchdata()
    }
    
    func clickOnRowMessage(indexPath: NSIndexPath) {
        let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            DispatchQueue.main.async() {
                if granted == false {
                    //TODO: show message not enable contact
                } else {
                    self.saveIndexPath = indexPath
                    self.listMessageTB.deselectRow(at: indexPath as IndexPath, animated: false)
                    let cell = self.horizontalTableView.cellForRow(at: indexPath as IndexPath) as! HorizontalCell
                    
                    if (cell.imageV.image != nil) {
                        self.view.makeToastActivity(message: "Loading")
                        
                        let userNumber = self.arrayListLead[indexPath.row]["userId"] as! Double
                        let targetUserId = String(format:"%0.f", userNumber)
                        
                        UserRouter.getUserInfo(userID: targetUserId, completed: { (result, error) in
                            self.view.hideToastActivity()
                            
                            if (error == nil) {
                                let userInfo = result as! NSDictionary
                                
                                let firstName = userInfo.object(forKey: kFirstname) as? String
                                let lastName = userInfo.object(forKey: kLastName) as? String
                                
                                var fullName = firstName
                                if (lastName != nil && lastName?.isEmpty == false) {
                                    fullName = String(format: "%@ %@", firstName!, lastName!)
                                }
                                
                                var phoneNumber = userInfo.object(forKey: kMobile) as? String
                                if phoneNumber == nil {
                                    phoneNumber = ""
                                }
                                
                                var emailString = userInfo.object(forKey: kEmail) as? String
                                if emailString == nil {
                                    emailString = ""
                                }
                                
                                var facebookURL = userInfo.object(forKey: kFacebookUrl) as? String
                                if facebookURL == nil {
                                    facebookURL = ""
                                }
                                
                                var twitterURL = userInfo.object(forKey: kTwitterUrl) as? String
                                if twitterURL == nil {
                                    twitterURL = ""
                                }
                                
                                var DOBString = (userInfo.object(forKey: kDob) as? String)
                                if twitterURL == nil {
                                    twitterURL = "1990-01-01"
                                } else {
                                    DOBString = DOBString?.substring(to: (DOBString?.index((DOBString?.startIndex)!, offsetBy: 10))!)
                                }
                                
                                let newContact = CNMutableContact()
                                
                                newContact.givenName = firstName!
                                if (lastName != nil && lastName?.isEmpty == false) {
                                    newContact.middleName = lastName!
                                }
                                
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
                                
                                let DOBArray = DOBString?.components(separatedBy: "-")
                                if (DOBArray?.count == 3) {
                                    let birthday = NSDateComponents()
                                    birthday.year = Int(DOBArray![0])!
                                    birthday.month = Int(DOBArray![1])!
                                    birthday.day = Int(DOBArray![2])!
                                    newContact.birthday = birthday as DateComponents
                                }
                                
                                
                                let alert = UIAlertController(title: pmmNotice, message: "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in }))
                                
                                let request = CNSaveRequest()
                                request.add(newContact, toContainerWithIdentifier: nil)
                                do {
                                    let store = CNContactStore()
                                    
                                    let contacts = try store.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName(fullName!), keysToFetch:[CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey])
                                    
                                    if (contacts.count == 0) {
                                        try store.executeSaveRequest(request)
                                    } else {
                                        alert.message = contactExist
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    
                                    
                                } catch let error{
                                    print(error)
                                    
                                    alert.message = pleaseDoItAgain
                                    self.present(alert, animated: true, completion: nil)
                                }
                            } else {
                                print("Request failed with error: \(String(describing: error))")
                            }
                        }).fetchdata()
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell , forRowAtIndexPath indexPath: IndexPath) {
        if (indexPath.row == self.arrayMessages.count - 1 && tableView == self.listMessageTB) {
            self.getMessage()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.listMessageTB) {
            return self.arrayMessages.count
        } else {
            return self.arrayListLead.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        var properties = ["Name": "Navigation Click", "Label":"Go Chat"]
        
        if (tableView == listMessageTB) {
            // Check new message here
            self.clickOnConnectionImage(indexPath: indexPath)
            
            properties = ["Name": "Navigation Click", "Label":"Add Contact"]
        } else {
            let selectedLeadID = self.arrayListLead[indexPath.row][kUserId] as! Double
            let userID = String(format: "%0.f", selectedLeadID)
            
            self.view.makeToastActivity()
            UserRouter.getUserInfo(userID: userID, completed: { (result, error) in
                self.view.hideToastActivity()
                
                if (error == nil) {
                    let userInfo = result as! NSDictionary
                    let userMail = userInfo[kEmail] as! String
                    let phoneNumber = userInfo[kMobile] as? String
                    
                    let viewProfileAction = { (action:UIAlertAction!) -> Void in
                        PMHelper.showCoachOrUserView(userID: userID)
                    }
                    
                    let acceptClientAction = { (action:UIAlertAction!) -> Void in
                        self.view.makeToast(message: "Setting")
                        let lead = self.arrayListLead[indexPath.row]
                        let targetUserId = String(format:"%0.f", (lead[kUserId]! as AnyObject).doubleValue)
                        
                        let param = [kUserId: PMHelper.getCurrentID(),
                            kUserIdRequest: targetUserId]
                        
                        var prefix = kPMAPICOACHES
                        prefix.append(PMHelper.getCurrentID())
                        prefix.append(kPMAPICOACH_CURRENT)
                        prefix.append("/")
                        
                        Alamofire.request(.PUT, prefix, parameters: param)
                            .responseJSON { response in
                                self.view.hideToastActivity()
                                
                                if response.response?.statusCode == 200 {
                                    self.arrayListLead.removeAll()
                                    self.leadOffset = 0
                                    self.isStopLoadLead = false
                                    self.getListLead()
                                }
                        }
                    }
                    
                    // Email action
                    let emailClientAction = { (action:UIAlertAction!) -> Void in
                        UserRouter.getCurrentUserInfo(completed: { (result, error) in
                            if (error == nil) {
                                let currentInfo = result as! NSDictionary
                                let currentMail = currentInfo[kEmail] as! String
                                let coachFirstName = currentInfo[kFirstname] as! String
                                let userFirstName = userInfo[kFirstname] as! String
                                
                                if MFMailComposeViewController.canSendMail() {
                                    let mail = MFMailComposeViewController()
                                    mail.mailComposeDelegate = self
                                    
                                    mail.setSubject("Come join me on Pummel Fitness")
                                    mail.setMessageBody("Hey \(userFirstName),\n\nCome join me on the Pummel Fitness app, where we can book appointments, log workouts, save transformation photos and chat for free.\n\nDownload the app at http://get.pummel.fit\n\nThanks,\n\nCoach\n\(coachFirstName)", isHTML: true)
//                                    mail.set
                                    self.present(mail, animated: true, completion: nil)
                                } else {
                                    PMHelper.showDoAgainAlert()
                                }
                                
                                
                                
                                var urlString = "mailto:"
                                urlString = urlString.stringByAppendingString(userMail)
                                
                                urlString = urlString.stringByAppendingString("?subject=")
                                urlString = urlString.stringByAppendingString("")
                                
                                urlString = urlString.stringByAppendingString("&from=")
                                urlString = urlString.stringByAppendingString(currentMail)
                                
                                urlString = urlString.stringByAppendingString("&body=")
                                urlString = urlString.stringByAppendingString("")
                                
                                let mailURL = NSURL(string: urlString)
                                if (UIApplication.shared.canOpenURL(mailURL!)) {
                                    UIApplication.shared.openURL(mailURL!)
                                }
                            } else {
                                print("Request failed with error: \(String(describing: error))")
                            }
                        }).fetchdata()
                    }
                    
                    // Call action
                    let callClientAction = { (action:UIAlertAction!) -> Void in
                        var urlString = "tel:///"
                        urlString = urlString.stringByAppendingString(phoneNumber!)
                        
                        let tellURL = NSURL(string: urlString)
                        if (UIApplication.shared.canOpenURL(tellURL!)) {
                            UIApplication.shared.openURL(tellURL!)
                        }
                    }
                    
                    // Send message action
                    let sendMessageClientAction = { (action:UIAlertAction!) -> Void in
                        self.isGoToMessageDetail = true
                        self.performSegue(withIdentifier: "checkChatMessage", sender: userID)
                    }
                    
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alertController.addAction(UIAlertAction(title: kViewProfile, style: UIAlertActionStyle.destructive, handler: viewProfileAction))
                    
                    
                    alertController.addAction(UIAlertAction(title: kSendMessage, style: UIAlertActionStyle.destructive, handler: sendMessageClientAction))
                    
                    // Check exist phone number
                    if (phoneNumber != nil &&
                        phoneNumber!.isEmpty == false) {
                        alertController.addAction(UIAlertAction(title: kCallClient, style: UIAlertActionStyle.destructive, handler: callClientAction))
                    }
                    
                    // Check exist email
                    if (userMail.isEmpty == false) {
                        alertController.addAction(UIAlertAction(title: kEmailClient, style: UIAlertActionStyle.destructive, handler: emailClientAction))
                    }
                    
                    alertController.addAction(UIAlertAction(title: kAcceptClient, style: UIAlertActionStyle.destructive, handler: acceptClientAction))
                    
                    alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
        mixpanel?.track("IOS.Message", properties: properties)
    }
}

