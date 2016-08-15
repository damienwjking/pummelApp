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
    var arrayMessages: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listMessageTB.delegate = self
        self.listMessageTB.dataSource = self
        self.listMessageTB.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.title = "MESSAGES"
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        let image = UIImage(named: "newmessage")!.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action:#selector(SessionsViewController.newMessage))
        let selectedImage = UIImage(named: "messagesSelcted")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.getMessage()
    }
    
    func newMessage() {
        performSegueWithIdentifier("newMessage", sender: nil)
    }
    
    func getMessage() {
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        prefix.appendContentsOf("/conversations")
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                print(JSON)
                self.arrayMessages = JSON as! NSArray
                self.listMessageTB.reloadData()
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 120
        // Ceiling this value fixes disappearing separators
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        let message = arrayMessages[indexPath.row] as! NSDictionary
        //Get Text 
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        prefix.appendContentsOf("/conversations/")
        prefix.appendContentsOf(String(format:"%0.f", message["conversationId"]!.doubleValue))
        prefix.appendContentsOf("/messages")
        prefix.appendContentsOf("?limit=1")
        Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let arrayMessageThisConverId = JSON as! NSArray
                    if (arrayMessageThisConverId.count != 0) {
                        let messageDetail = arrayMessageThisConverId[0]
                        if (!(messageDetail["text"] is NSNull)) {
                            cell.messageLB.text = messageDetail["text"]  as? String
                        } else {
                            if (!(messageDetail["imageUrl"] is NSNull)) {
                                cell.messageLB.text = "Sent you a image"
                            } else if (!(messageDetail["videoUrl"] is NSNull)) {
                                cell.messageLB.text = "Sent you a video"
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
      
        let conversations = message["conversation"] as! NSDictionary
        let conversationUsers = conversations["conversationUsers"] as! NSArray
        let targetUser = conversationUsers[0] as! NSDictionary
        let targetUserId = String(format:"%0.f", targetUser["userId"]!.doubleValue)
        var prefixUser = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        prefixUser.appendContentsOf(targetUserId)
        Alamofire.request(.GET, prefixUser)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userInfo = JSON as! NSDictionary
                let name = userInfo.objectForKey("firstname") as! String
                cell.nameLB.text = name.uppercaseString
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
       
        prefixUser.appendContentsOf("/photos")
        Alamofire.request(.GET, prefixUser)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let listPhoto = JSON as! NSArray
                if (listPhoto.count >= 1) {
                    let photo = listPhoto.objectAtIndex(0) as! NSDictionary
                    print(photo)
                    var link = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
                    link.appendContentsOf(photo.objectForKey("imageUrl") as! String)
                    link.appendContentsOf("?width=80&height=80")
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
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let dateFromString : NSDate = dateFormatter.dateFromString(timeAgo)!
        cell.timeLB.text = self.timeAgoSinceDate(dateFromString)
        if (message["lastOpenedAt"] is NSNull) {
            cell.nameLB.font = UIFont(name: "Montserrat-Regular", size: 16)
            cell.messageLB.font = UIFont(name: "Montserrat-Regular", size: 16)
            cell.timeLB.textColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1)
        } else {
            let lastOpenAt =  message["lastOpenedAt"] as! String
            let dayOpen = dateFormatter.dateFromString(lastOpenAt)
            let dayCurrent = NSDate()
            if (dayOpen!.compare(dayCurrent) == NSComparisonResult.OrderedDescending) {
                cell.nameLB.font = UIFont(name: "Montserrat-Regular", size: 13)
                cell.messageLB.font = UIFont(name: "Montserrat-Regular", size: 16)
                cell.timeLB.textColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1)
            } else {
                cell.nameLB.font = UIFont(name: "Montserrat-Light", size: 13)
                cell.messageLB.font = UIFont(name: "Montserrat-Light", size: 16)
                cell.timeLB.textColor = UIColor.blackColor()
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.arrayMessages == nil) {
            return 0
        } else {
            return self.arrayMessages.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let message = arrayMessages[indexPath.row] as! NSDictionary
        let messageId = String(format:"%0.f", message["conversationId"]!.doubleValue)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let dayCurrent = dateFormatter.stringFromDate(NSDate())
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        prefix.appendContentsOf("/conversations/")
        prefix.appendContentsOf(String(format:"%0.f", message["conversationId"]!.doubleValue))
        Alamofire.request(.PUT, prefix, parameters: ["conversationId":messageId, "lastOpenedAt":dayCurrent, "userId": defaults.objectForKey("currentId") as! String])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                     self.performSegueWithIdentifier("checkChatMessage", sender: indexPath.row)
                } else {
                    let alertController = UIAlertController(title: "Open Issues", message: "Please do it again", preferredStyle: .Alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
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
            let message = arrayMessages[indexPathRow] as! NSDictionary
            let conversations = message["conversation"] as! NSDictionary
            let conversationUsers = conversations["conversationUsers"] as! NSArray
            let targetUser = conversationUsers[0] as! NSDictionary
            let targetUserId = String(format:"%0.f", targetUser["userId"]!.doubleValue)
            destinationVC.userIdTarget = targetUserId
            destinationVC.messageId = String(format:"%0.f", message["conversationId"]!.doubleValue)
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