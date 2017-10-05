//
//  MessageViewController.swift
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
    
    var arrayMessages: [NSMutableDictionary] = []
    let defaults = UserDefaults.standard
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
        
        self.getListLead()
        self.horizontalViewHeightConstraint!.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initNavigationBar()
        
        self.listMessageTB.reloadData()
        
        self.view.bringSubviewToFront(self.noMessageV)
        
        if (defaults.bool(forKey: k_PM_IS_COACH) == true) {
            self.noMessageTitleLB.text = "Get Connections With Your Clients"
        } else {
            self.noMessageTitleLB.text = "Get Connections With Your Coaches"
        }
        
        self.isGoToMessageDetail = false
        
        self.getMessage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated: animated)
        
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
    
    func getMessagetAtSaveIndexPathScrollView() {
        var prefix = kPMAPIUSER
        prefix.append(PMHelper.getCurrentID())
        prefix.append(kPM_PATH_CONVERSATION_OFFSET_V2)
        prefix.append(String((self.saveIndexPath?.row)!))
        prefix.append(kPM_PATH_LIMIT_ONE)
        
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
                print("Request failed with error: \(String(describing: error))")
                }
        }
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
        var prefix = kPMAPICOACHES
        prefix.append(PMHelper.getCurrentID())
        prefix.append(kPMAPICOACH_LEADS)
        
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
                print("Request failed with error: \(String(describing: error))")
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
            prefix.append(PMHelper.getCurrentID())
            prefix.append(kPM_PATH_CONVERSATION_OFFSET_V2)
            prefix.append(String(offset))
            
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
                            self.noMessageV.isHidden = true
                            
                             self.listMessageTB.reloadData()
                        } else {
                            if self.arrayMessages.count <= 0 {
                                self.noMessageV.isHidden = false
                            }
                            self.isLoadingMessage = false
                            self.isStopLoadMessage = true
                        }
                        
                        self.updateMessageData()
                    case .Failure(let error):
                        self.view.hideToastActivity()
                        self.offset -= 10
                        self.isLoadingMessage = false
                        print("Request failed with error: \(String(describing: error))")
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
                var prefix = kPMAPIUSER
                prefix.append(PMHelper.getCurrentID())
                prefix.append(kPM_PATH_CONVERSATION)
                prefix.append("/")
                prefix.append(String(format:"%0.f", (message[kId]! as AnyObject).doubleValue))
                
                Alamofire.request(.GET, prefix)
                    .responseJSON { response in switch response.result {
                    case .Success(let JSON):
                        
                        // Check which on is sender
                        let conversationsUserArray = JSON as! NSArray
                        let conversationMe : NSDictionary!
                        let conversationTarget: NSDictionary!
                        let converstationTemp = conversationsUserArray[0] as! NSDictionary
                        if (String(format:"%0.f", converstationTemp[kUserId]!.doubleValue) == PMHelper.getCurrentID()) {
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
                            let dateFormatter = DateFormatter
                            dateFormatter.dateFormat = kFullDateFormat
                            dateFormatter.timeZone = NSTimeZone(name: "UTC")
                            
                            let lastOpenAtM = dateFormatter.date(from: conversationMe[kLastOpenAt] as! String)
                            let updateAtM =  dateFormatter.date(from: message["updatedAt"] as! String)
                            
                            if (lastOpenAtM!.compare(updateAtM!) == NSComparisonResult.OrderedAscending) {
                                message[kLastOpenAt] = "0"
                            } else {
                                message[kLastOpenAt] = "1"
                            }
                        }
                        
                        // Get name
                        var prefixUser = kPMAPIUSER
                        prefixUser.append(String(format:"%0.f", conversationTarget[kUserId]!.doubleValue))
                        Alamofire.request(.GET, prefixUser)
                            .responseJSON { response in switch response.result {
                            case .Success(let JSON):
                                let userInfo = JSON as! NSDictionary
                                
                                let name = userInfo.object(forKey: kFirstname) as! String
                                message[kFirstname] = name.uppercased()
                                
                                var imageURL = userInfo.object(forKey: kImageUrl) as? String
                                if (imageURL?.isEmpty == true) {
                                    imageURL = " "
                                }
                                
                                if (JSON[kImageUrl] is NSNull == false) {
                                    let imageURLString = JSON[kImageUrl] as! String
                                    
                                    ImageVideoRouter.getImage(imageURLString: imageURLString, sizeString: widthHeight160, completed: { (result, error) in
                                        if (error == nil) {
                                            DispatchQueue.main.async(execute: {
                                                let imageRes = result as! UIImage
                                                message["userImage"] = imageRes
                                                
                                                self.listMessageTB.reloadData()
                                            })
                                        } else {
                                            print("Request failed with error: \(String(describing: error))")
                                        }
                                    }).fetchdata()
                                } else {
                                    message["userImage"] = UIImage(named:"display-empty.jpg")
                                    
                                    self.listMessageTB.reloadData()
                                }
                                
                            case .Failure(let error):
                                print("Request failed with error: \(String(describing: error))")
                                }
                        }
                        
                    case .Failure(let error):
                        print("Request failed with error: \(String(describing: error))")
                        }
                }
            }
            
            // Get message
            var prefixT = kPMAPIUSER
            prefixT.append(PMHelper.getCurrentID())
            prefixT.append(kPM_PATH_CONVERSATION)
            prefixT.append("/")
            prefixT.append(String(format:"%0.f", (message[kId]! as AnyObject).doubleValue))
            prefixT.append("/messages")
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
                    print("Request failed with error: \(String(describing: error))")
                    }
            }
            
            i = i + 1
        }
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "checkChatMessage") {
            let destinationVC = segue.destination as! ChatMessageViewController
            
            if (self.isGoToMessageDetail == false) {
                let indexPathRow = sender as! Int
                let message = arrayMessages[indexPathRow]
                message[kLastOpenAt] = "1"
                let cell = self.listMessageTB.cellForRowAtIndexPath(NSIndexPath.init(forRow: indexPathRow, inSection: 0)) as! MessageTableViewCell
                
                destinationVC.userIdTarget = cell.targetId
                destinationVC.messageId = String(format:"%0.f", (message[kId]! as AnyObject).doubleValue)
            } else {
                let userID = sender as! String
                destinationVC.userIdTarget = userID
            }
        }
    }

    func timeAgoSinceDate(date:NSDate) -> String {
        let calendar = NSCalendar.current
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if (tableView == self.horizontalTableView) {
            if (defaults.bool(forKey: k_PM_IS_COACH) == true) {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == listMessageTB && arrayMessages.count != 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: kMessageTableViewCell, for: indexPath) as! MessageTableViewCell
            let message = arrayMessages[indexPath.row]
            let currentUserid = PMHelper.getCurrentID()
            
            // TargetID
            let targerID = message["targetId"] as? String
            if (targerID?.isEmpty == false) {
                cell.targetId = targerID
                cell.isUserInteractionEnabled = true
            } else {
                cell.isUserInteractionEnabled = false
            }
            
            
            //Get Text
            var prefix = kPMAPIUSER
            prefix.append(currentUserid)
            prefix.append(kPM_PATH_CONVERSATION)
            prefix.append("/")
            prefix.append(String(format:"%0.f", (message[kId]! as AnyObject).doubleValue))
            
            // Chat time
            let timeAgo = message["updatedAt"] as! String
            let dateFormatter = DateFormatter
            dateFormatter.dateFormat = kFullDateFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            let dateFromString : NSDate = dateFormatter.date(from: timeAgo)!
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
                    cell.timeLB.textColor = UIColor.black
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
            var cell:HorizontalCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? HorizontalCell
            if cell == nil {
                cell = Bundle.main.loadNibNamed(cellId, owner: nil, options: nil)!.first as? HorizontalCell
                cell!.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
            }
            cell!.addButton.isHidden = true
            
            let lead = self.arrayListLead[indexPath.row]
            let targetUserId = String(format:"%0.f", lead["userId"]!.doubleValue)
            
            UserRouter.getUserInfo(userID: targetUserId, completed: { (result, error) in
                if (error == nil) {
                    let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                    if visibleCell == true {
                        let userInfo = result as! NSDictionary
                        let name = userInfo.object(forKey: kFirstname) as! String
                        cell!.name.text = name.uppercased()
                        
                        if (userInfo[kImageUrl] is NSNull == false) {
                            let imageURLString = userInfo[kImageUrl] as! String
                            ImageVideoRouter.getImage(imageURLString: imageURLString, sizeString: widthHeight160, completed: { (result, error) in
                                if (error == nil) {
                                    let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                                    if visibleCell == true {
                                        let imageRes = result as! UIImage
                                        cell!.imageV.image = imageRes
                                        cell!.addButton.isHidden = false
                                    }
                                } else {
                                    print("Request failed with error: \(String(describing: error))")
                                }
                            }).fetchdata()
                        } else {
                            cell?.imageV.image = UIImage(named: "display-empty.jpg")
                            cell!.addButton.isHidden = false
                        }
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
            
            cell!.selectionStyle = .None
            return cell!
        }
    }
    
    func clickOnConnectionImage(indexPath: NSIndexPath) {
        self.saveIndexPath = indexPath
        let message = arrayMessages[indexPath.row]
        let messageId = String(format:"%0.f", (message[kId]! as AnyObject).doubleValue)
        var prefix = kPMAPIUSER
        prefix.append(PMHelper.getCurrentID())
        prefix.append(kPM_PATH_CONVERSATION_V2)
        prefix.append("/")
        prefix.append(messageId)
        
        let param = [kConversationId:messageId,
                     kUserId: PMHelper.getCurrentID()]
        
        self.view.makeToastActivity(message: "Loading")
        Alamofire.request(.PUT, prefix, parameters: param)
            .responseJSON { response in
                self.view.hideToastActivity()
                
                if response.response?.statusCode == 200 {
                    let numberBadge = response.result.value as? Int
                    let messageTabItem = self.tabBarController?.tabBar.items![3]
                    if (numberBadge != nil && numberBadge > 0) {
                        messageTabItem?.badgeValue = String(format: "%d", numberBadge!)
                    } else {
                        messageTabItem?.badgeValue = nil
                    }
                    
                    self.performSegue(withIdentifier: "checkChatMessage", sender: indexPath.row)
                } else {
                    PMHelper.showDoAgainAlert()
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
                    self.listMessageTB.deselectRow(at: indexPath, animated: false)
                    let cell = self.horizontalTableView.cellForRowAtIndexPath(indexPath) as! HorizontalCell
                    
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
                                    DOBString = DOBString?.substringToIndex(DOBString!.startIndex.advancedBy(10))
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
                                    newContact.birthday = birthday
                                }
                                
                                
                                let alert = UIAlertController(title: pmmNotice, message: "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { _ in }))
                                
                                let request = CNSaveRequest()
                                request.addContact(newContact, toContainerWithIdentifier: nil)
                                do {
                                    let store = CNContactStore()
                                    
                                    let contacts = try store.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName(fullName!), keysToFetch:[CNContactGivenNameKey, CNContactFamilyNameKey])
                                    
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell , forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.arrayMessages.count - 1 && isLoadingMessage == false && tableView == self.listMessageTB) {
            offset += 10
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        var properties = ["Name": "Navigation Click", "Label":"Go Chat"]
        
        if (tableView == listMessageTB) {
            // Check new message here
            self.clickOnConnectionImage(indexPath)
            
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
                        let targetUserId = String(format:"%0.f", lead[kUserId]!.doubleValue)
                        
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
                                
                                var urlString = "mailto:"
                                urlString = urlString.stringByAppendingString(userMail)
                                
                                urlString = urlString.stringByAppendingString("?subject=")
                                urlString = urlString.stringByAppendingString("Come%20join%20me%20on%20Pummel%20Fitness")
                                
                                urlString = urlString.stringByAppendingString("&from=")
                                urlString = urlString.stringByAppendingString(currentMail)
                                
                                urlString = urlString.stringByAppendingString("&body=")
                                urlString = urlString.stringByAppendingString("Hey%20\(userFirstName),%0A%0ACome%20join%20me%20on%20the%20Pummel%20Fitness%20app,%20where%20we%20can%20book%20appointments,%20log%20workouts,%20save%20transformation%20photos%20and%20chat%20for%20free.%0A%0ADownload%20the%20app%20at%20http://get.pummel.fit%0A%0AThanks,%0A%0ACoach%0A\(coachFirstName)")
                                
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

