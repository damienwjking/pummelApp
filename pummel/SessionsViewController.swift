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

class SessionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var listMessageTB: UITableView!
    @IBOutlet var listMessageTBTopDistance : NSLayoutConstraint?
    var arrayMessages: [NSDictionary] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    var dataSourceArr : [NSDictionary] = []
    var scrollTableView : UITableView!
    var offset : Int = -10
    var isStopLoadMessage : Bool = false
    var isLoadingMessage : Bool = false
    private struct Constants {
        static let ContentSize: CGSize = CGSize(width: 80, height: 96.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listMessageTB.delegate = self
        self.listMessageTB.dataSource = self
        self.listMessageTB.separatorStyle = UITableViewCellSeparatorStyle.None
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
        let tabItem = self.tabBarController?.tabBar.items![3]
        if (UIApplication.sharedApplication().applicationIconBadgeNumber != 0) {
            tabItem!.badgeValue = String(UIApplication.sharedApplication().applicationIconBadgeNumber)
        }
        offset += 10
        self.getMessage()
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
            let connectionsLB : UILabel = UILabel.init(frame: CGRectMake(0, 15, self.view.frame.size.width, 14))
            connectionsLB.font = .pmmMonReg13()
            connectionsLB.textColor = UIColor.pmmWarmGreyColor()
            connectionsLB.textAlignment = .Center
            connectionsLB.text = kNewConnections
            self.view.addSubview(connectionsLB)
            self.listMessageTBTopDistance!.constant = 180
            self.scrollTableView = UITableView(frame: CGRectMake(150, -96, 96, self.view.frame.size.width))
            self.view.addSubview(scrollTableView)
              self.scrollTableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
            self.scrollTableView.separatorStyle = .None
            self.scrollTableView.delegate = self
            self.scrollTableView.dataSource = self
            self.scrollTableView.rowHeight = 96
            self.scrollTableView.separatorStyle = .None
            let sep : UIView = UIView.init(frame: CGRectMake(0, 179.5, self.view.frame.width, 0.5))
            sep.backgroundColor = UIColor.pmmWhiteColor()
            self.view.addSubview(sep)
        }
        // Remove badge
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func newMessage() {
        performSegueWithIdentifier("newMessage", sender: nil)
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
                        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
                            self.scrollTableView.reloadData()
                        }
                    } else {
                        self.isLoadingMessage = false
                        self.isStopLoadMessage = true
                    }
                case .Failure(let error):
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
        if (tableView == listMessageTB) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kMessageTableViewCell, forIndexPath: indexPath) as! MessageTableViewCell
            let message = arrayMessages[indexPath.row]
            //Get Text
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPM_PATH_CONVERSATION)
            prefix.appendContentsOf("/")
            prefix.appendContentsOf(String(format:"%0.f", message[kConversationId]!.doubleValue))
            prefix.appendContentsOf(kPM_PARTH_MESSAGE)
            prefix.appendContentsOf("?limit=1")
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let arrayMessageThisConverId = JSON as! NSArray
                    if (arrayMessageThisConverId.count != 0) {
                        let messageDetail = arrayMessageThisConverId[0]
                        if (!(messageDetail[kText] is NSNull)) {
                            cell.messageLB.text = messageDetail[kText]  as? String
                        } else {
                            if (!(messageDetail[kImageUrl] is NSNull)) {
                                cell.messageLB.text = sendYouAImage
                            } else if (!(messageDetail[KVideoUrl] is NSNull)) {
                                cell.messageLB.text = sendYouAVideo
                            } else
                            {
                                cell.messageLB.text = ""
                            }
                        }
                    } else {
                        cell.messageLB.text = ""
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            
            let conversations = message[kConversation] as! NSDictionary
            let conversationUsers = conversations[kConversationUser] as! NSArray
            var targetUser = conversationUsers[0] as! NSDictionary
            let currentUserid = defaults.objectForKey(k_PM_CURRENT_ID) as! String
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
                    var link = kPMAPI
                    if !(JSON[kImageUrl] is NSNull) {
                        link.appendContentsOf(JSON[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight160)
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                cell.avatarIMV.image = imageRes
                        }
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            
            let timeAgo = message["updatedAt"] as! String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = kFullDateFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            let dateFromString : NSDate = dateFormatter.dateFromString(timeAgo)!
            cell.timeLB.text = self.timeAgoSinceDate(dateFromString)
            if (message[kLastOpenAt] is NSNull) {
                cell.nameLB.font = .pmmMonReg16()
                cell.messageLB.font = .pmmMonReg16()
                cell.timeLB.textColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1)
            } else {
                let lastOpenAt =  message[kLastOpenAt] as! String
                let dayOpen = dateFormatter.dateFromString(lastOpenAt)
                let dayCurrent = NSDate()
                if (dayOpen!.compare(dayCurrent) == NSComparisonResult.OrderedDescending) {
                    cell.nameLB.font = .pmmMonReg13()
                    cell.messageLB.font = .pmmMonReg16()
                    cell.timeLB.textColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1)
                } else {
                    cell.nameLB.font = .pmmMonLight13()
                    cell.messageLB.font = .pmmMonLight16()
                    cell.timeLB.textColor = UIColor.blackColor()
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
            let message = arrayMessages[indexPath.row]
            let conversations = message[kConversation] as! NSDictionary
            let conversationUsers = conversations[kConversationUser] as! NSArray
            var targetUser = conversationUsers[0] as! NSDictionary
            let currentUserid = defaults.objectForKey(k_PM_CURRENT_ID) as! String
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
                    cell!.name.text = name.uppercaseString
                    var link = kPMAPI
                    if !(JSON[kImageUrl] is NSNull) {
                        link.appendContentsOf(JSON[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight160)
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                cell!.imageV.image = imageRes
                        }
                    } else {
                        cell?.imageV.image = UIImage(named: "display-empty.jpg")
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            cell?.imageV.tag = indexPath.row
            let recognizer = UITapGestureRecognizer(target: self, action:#selector(SessionsViewController.clickOnConnectionImage(_:)))
            cell?.imageV.addGestureRecognizer(recognizer)
            cell!.selectionStyle = .None
            return cell!
        }
    }
    
    func clickOnConnectionImage(sender: UIButton) {
        let message = arrayMessages[sender.tag]
        let messageId = String(format:"%0.f", message[kConversationId]!.doubleValue)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let dayCurrent = dateFormatter.stringFromDate(NSDate())
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION)
        prefix.appendContentsOf("/")
        prefix.appendContentsOf(String(format:"%0.f", message[kConversationId]!.doubleValue))
        Alamofire.request(.PUT, prefix, parameters: [kConversationId:messageId, kLastOpenAt:dayCurrent, kUserId: defaults.objectForKey(k_PM_CURRENT_ID) as! String])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.performSegueWithIdentifier("checkChatMessage", sender: sender.tag)
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell , forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.arrayMessages.count - 1 && isLoadingMessage == false) {
            offset += 10
            self.getMessage()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.arrayMessages == []) {
            return 0
        } else {
            return self.arrayMessages.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let message = arrayMessages[indexPath.row]
        let messageId = String(format:"%0.f", message[kConversationId]!.doubleValue)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let dayCurrent = dateFormatter.stringFromDate(NSDate())
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION)
        prefix.appendContentsOf("/")
        prefix.appendContentsOf(String(format:"%0.f", message[kConversationId]!.doubleValue))
        Alamofire.request(.PUT, prefix, parameters: [kConversationId:messageId, kLastOpenAt:dayCurrent, kUserId: defaults.objectForKey(k_PM_CURRENT_ID) as! String])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "checkChatMessage")
        {
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
        } else if (components.second >= 3) {
            return "\(components.second)s"
        } else {
            return "Just now"
        }
    }
}
