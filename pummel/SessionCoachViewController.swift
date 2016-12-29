//
//  SessionCoachViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import AlamofireImage


class SessionCoachViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var underLineViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sessionTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var isUpComing = true
    
    var sessions = [Session]()
    
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
    }
    
    func initNavigationBar() {
        // ADD Log Button At Left Navigationbar Item
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title:kLog, style:.Plain, target: self, action: #selector(SessionCoachViewController.logButtonClicked))
        self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState:.Normal)
        
        
        // ADD Book Button At Right Navigationbar Item
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kBook, style:.Plain, target: self, action: #selector(SessionCoachViewController.bookButtonClicked))
        self.tabBarController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState:.Normal)
    }
    
    // MARK: Private function
    func convertDateTimeFromString(dateTimeString: String) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let date = dateFormatter.dateFromString(dateTimeString.substringToIndex(dateTimeString.startIndex.advancedBy(10)))
        
        let convertDateFormatter = NSDateFormatter()
        convertDateFormatter.dateFormat = "EEE F MMM"
        let convertDateString = convertDateFormatter.stringFromDate(date!)
        
        return convertDateString
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
                            
                            self.sessions.append(session)
                        }
                        
                        self.sessionTableView.reloadData()
                    }
                    
//                    let name = sessionInfo.objectForKey(kFirstname) as! String
//                    self.navigationItem.title = name.uppercaseString
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
                
        }
    }
    
    // MARK: UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sessions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if self.isUpComing == true {
//            let cell = tableView.dequeueReusableCellWithIdentifier("LogComingTableViewCell") as! LogComingTableViewCell
//            
//            cell.nameLB.text = "SARAH"
//            cell.messageLB.text = "tue 19th dec"
//            cell.timeLB.text = "4PM"
//            
//            let prefix = "http://api.pummel.fit/api/uploads/235/render?width=125.0&height=125.0"
//            if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
//                let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
//                cell.avatarIMV.image = imageRes
//            } else {
//                Alamofire.request(.GET, prefix)
//                    .responseImage { response in
//                        if (response.response?.statusCode == 200) {
//                            let imageRes = response.result.value! as UIImage
//                            cell.avatarIMV.image = imageRes
//                        }
//                }
//            }
//            
//            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
//            
//            return cell
//        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LogCompletedTableViewCell") as! LogCompletedTableViewCell
        
            let session = self.sessions[indexPath.row]
        
            cell.nameLB.text = session.text
            cell.messageLB.text = self.convertDateTimeFromString(session.createdAt!)
            cell.timeLB.text = "4PM"
            cell.tagActionLB.text = session.type
            
            let prefix = "http://api.pummel.fit/api/uploads/235/render?width=125.0&height=125.0"
            if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                cell.avatarIMV.image = imageRes
            } else {
                Alamofire.request(.GET, prefix)
                    .responseImage { response in
                        if (response.response?.statusCode == 200) {
                            let imageRes = response.result.value! as UIImage
                            cell.avatarIMV.image = imageRes
                        }
                }
            }
            
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
            
            return cell
//        }
        
//        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: Outlet function
    
    @IBAction func upcomingButtonClicked(sender: AnyObject) {
        self.isUpComing = true
        
        self.view.layoutIfNeeded()
        self.underLineViewLeadingConstraint.constant = 0
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.sessionTableView.reloadData()
        }
    }
    
    
    @IBAction func completedButtonClicked(sender: AnyObject) {
        self.isUpComing = false
        
        self.view.layoutIfNeeded()
        self.underLineViewLeadingConstraint.constant = self.upcomingButton.frame.size.width
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.sessionTableView.reloadData()
        }
    }
    
    func bookButtonClicked() {
        print("book clicked")
        self.performSegueWithIdentifier("coachMakeABook", sender: nil)
        
    }
    
    func logButtonClicked() {
        print("log clicked")
        self.performSegueWithIdentifier("coachLogASession", sender: nil)
    }
}
