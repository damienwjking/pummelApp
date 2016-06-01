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
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.title = "MESSAGES"
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        let image = UIImage(named: "newmessage")!.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action:"newMessage")
        let selectedImage = UIImage(named: "messagesSelcted")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        self.listMessageTB.delegate = self
        self.listMessageTB.dataSource = self
        self.listMessageTB.separatorStyle = UITableViewCellSeparatorStyle.None
        self.getMessage()
    }
    
    func newMessage() {
        performSegueWithIdentifier("newMessage", sender: nil)
    }
    
    func getMessage() {
        Alamofire.request(.GET, "http://api.pummel.fit/api/user/conversations")
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
        cell.messageLB.text = message["title"]  as? String
        let idSenderArray = message["userIds"] as! NSArray
        let idSender = String(format:"%0.f", idSenderArray[0].doubleValue)
        var prefix = "http://api.pummel.fit/api/users/" as String
        prefix.appendContentsOf(idSender)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                print(JSON)
                let userInfo = JSON as! NSDictionary
                var name = userInfo.objectForKey("firstname") as! String
                name.appendContentsOf(" ")
                name.appendContentsOf(userInfo.objectForKey("lastname") as! String)
                cell.nameLB.text = name
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
                    var link = listPhoto[0] as! String
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
        print(timeAgo)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let dateFromString : NSDate = dateFormatter.dateFromString(timeAgo)!
        cell.timeLB.text = self.timeAgoSinceDate(dateFromString)
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
        performSegueWithIdentifier("checkChatMessage", sender: indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "checkChatMessage")
        {
            let destinationVC = segue.destinationViewController as! ChatMessageViewController
            let indexPathRow = sender as! Int
            let message = arrayMessages[indexPathRow] as! NSDictionary
            let idSenderArray = message["userIds"] as! NSArray
            let idSender = String(format:"%0.f", idSenderArray[0].doubleValue)
            destinationVC.userIdTarget = idSender
            destinationVC.messageId = String(format:"%0.f", message["id"]!.doubleValue)
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