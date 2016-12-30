//
//  SessionClientViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import AlamofireImage

class SessionClientViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var underLineViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sessionTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var isUpComing = true
    
    var upCommingSessions = [Session]()
    var completedSessions = [Session]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTableView()
        self.initNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getListSession()
    }
    
    // MARK: Init
    func initTableView() {
        self.sessionTableView.estimatedRowHeight = 100
        
        let nibName = UINib(nibName: "LogTableViewCell", bundle:nil)
        self.sessionTableView.registerNib(nibName, forCellReuseIdentifier: "LogTableViewCell")
    }
    
    func initNavigationBar() {
        // Remove Button At Left Navigationbar Item
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        // ADD Log Button At Right Navigationbar Item
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kLog, style:.Plain, target: self, action: #selector(SessionClientViewController.logButtonClicked))
        self.tabBarController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState:.Normal)
    }
    
    // MARK: Private function
    func convertDateTimeFromString(dateTimeString: String) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "EEE F MMM"
        let newDateString = newDateFormatter.stringFromDate(date!)
        
        return newDateString
    }
    
    func getHourFromString(dateTimeString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "ha"
        let newDateString = newDateFormatter.stringFromDate(date!).uppercaseString
        
        return newDateString
    }
    
    func checkUpCommingSesion(session: Session) {
        let now = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let sessionDate = dateFormatter.dateFromString(session.createdAt!)
        
        if now.compare(sessionDate!) == .OrderedDescending {
            self.upCommingSessions.append(session)
        } else {
            self.completedSessions.append(session)
        }
    }
    
    func getListSession() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_ACTIVITIES_USER)
        
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    let sessionInfo = JSON as! [NSDictionary]
                    if (sessionInfo.count > 0) {
                        for i in 0 ..< sessionInfo.count {
                            let sessionContent = sessionInfo[i]
                            let session = Session()
                            
                            session.id = sessionContent.objectForKey("id") as? Int
                            session.text = sessionContent.objectForKey("text") as? String
                            session.imageUrl = sessionContent.objectForKey("imageUrl") as? String
                            session.type = sessionContent.objectForKey("type") as? String
                            session.status = sessionContent.objectForKey("status") as? Int
                            session.userId = sessionContent.objectForKey("userId") as? Int
                            session.coachId = sessionContent.objectForKey("coachId") as? Int
                            session.uploadId = sessionContent.objectForKey("uploadId") as? String
                            session.datetime = sessionContent.objectForKey("datetime") as? String
                            session.createdAt = sessionContent.objectForKey("createdAt") as? String
                            session.updatedAt = sessionContent.objectForKey("updatedAt") as? String
                            session.distance = sessionContent.objectForKey("distance") as? Int
                            session.longtime = sessionContent.objectForKey("longtime") as? Int
                            session.intensity = sessionContent.objectForKey("intensity") as? Int
                            session.calorie = sessionContent.objectForKey("calorie") as? Int
                            
                            self.checkUpCommingSesion(session)
                        }
                        
                        self.sessionTableView.reloadData()
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    // MARK: UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isUpComing {
            return self.upCommingSessions.count
        } else {
            return self.completedSessions.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var session = Session()
        
        if self.isUpComing {
            session = self.upCommingSessions[indexPath.row]
        } else {
            session = self.completedSessions[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LogTableViewCell") as! LogTableViewCell
        
        cell.nameLB.text = session.text
        cell.messageLB.text = self.convertDateTimeFromString(session.createdAt!)
        cell.timeLB.text = self.getHourFromString(session.datetime!)
        cell.rateButton.hidden = self.isUpComing
        
        cell.typeLB.text = session.type
        if session.type?.isEmpty == true {
            cell.typeLBHeightConstraint.constant = 0
            cell.typeLBBottomConstraint.constant = 0
        } else {
            cell.typeLBHeightConstraint.constant = 21
            cell.typeLBBottomConstraint.constant = 5.5
        }
        
        var prefix = kPMAPIUSER
//        if session.coachId != nil {
//            prefix.appendContentsOf(String(format:"%ld", session.coachId!))
//        } else {
//            prefix.appendContentsOf(String(format:"%ld", session.userId!))
//        }
        prefix.appendContentsOf(String(format:"%ld", session.userId!))
        
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetail = JSON as! NSDictionary
                if !(userDetail[kImageUrl] is NSNull) {
                    var link = kPMAPI
                    link.appendContentsOf(userDetail[kImageUrl] as! String)
                    link.appendContentsOf(widthHeight160)
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
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: Outlet function
    
    @IBAction func upcomingButtonClicked(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.underLineViewLeadingConstraint.constant = 0
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.isUpComing = true
            
            self.sessionTableView.reloadData()
        }
    }
    
    
    @IBAction func completedButtonClicked(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.underLineViewLeadingConstraint.constant = self.upcomingButton.frame.size.width
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.isUpComing = false
            
            self.sessionTableView.reloadData()
        }
    }
    
    func logButtonClicked() {
        print("log clicked")
        self.performSegueWithIdentifier("userLogASession", sender: nil)
    }
    
}
