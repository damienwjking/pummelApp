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
    
    @IBOutlet weak var noSessionV: UIView!
    @IBOutlet weak var noSessionYetLB: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var isUpComing = true
    var isloading = false
    var canLoadMore = true
    
    var upCommingSessions = [Session]()
    var completedSessions = [Session]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTableView()
        self.initNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.upcomingButton.titleLabel?.font = UIFont.pmmMonReg13()
        self.completedButton.titleLabel?.font = UIFont.pmmMonReg13()
        
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
    func checkUpCommingSesion(session: Session) {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let sessionDate = dateFormatter.dateFromString(session.datetime!)
        
        if now.compare(sessionDate!) == .OrderedAscending {
            var isNewSession = true
            for sessionItem in self.upCommingSessions {
                if session.id == sessionItem.id {
                    isNewSession = false
                }
            }
            
            if isNewSession == true {
                self.upCommingSessions.append(session)
            }
        } else {
            var isNewSession = true
            for sessionItem in self.completedSessions {
                if session.id == sessionItem.id {
                    isNewSession = false
                }
            }
            
            if isNewSession == true {
                self.completedSessions.append(session)
            }
        }
    }
    
    func getListSession() {
        if (self.canLoadMore == true && self.isloading == false) {
            self.isloading = true
            let totalSession = self.upCommingSessions.count + self.completedSessions.count
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPM_PATH_ACTIVITIES_USER)
            prefix.appendContentsOf(String(totalSession))
            
            Alamofire.request(.GET, prefix)
                .responseJSON { response in
                    switch response.result {
                    case .Success(let JSON):
                        let sessionInfo = JSON as! [NSDictionary]
                        if (sessionInfo.count > 0) {
                            for i in 0 ..< sessionInfo.count {
                                let sessionContent = sessionInfo[i]
                                let session = Session()
                                session.parseDataWithDictionary(sessionContent)
                                
                                self.checkUpCommingSesion(session)
                            }
                            
                            let totalSession = self.upCommingSessions.count + self.completedSessions.count
                            if totalSession > 0 {
                                self.noSessionV.hidden = true
                            } else {
                                self.noSessionV.hidden = false
                            }
                            
                            self.sessionTableView.reloadData()
                        } else {
                            self.canLoadMore = false
                        }
                    case .Failure(let error):
                        self.canLoadMore = false
                        print("Request failed with error: \(error)")
                    }
                    
                    self.isloading = false
            }
        }
    }
    
    // MARK: UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isUpComing {
            if self.upCommingSessions.count == 0 {
                self.getListSession()
                
                return 0
            } else {
                return self.upCommingSessions.count
            }
        } else {
            if self.completedSessions.count == 0 {
                self.getListSession()
                
                return 0
            } else {
                return self.completedSessions.count
            }
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var session = Session()
        
        if self.isUpComing {
            session = self.upCommingSessions[indexPath.row]
            
            if indexPath.row == self.upCommingSessions.count - 1{
                self.getListSession()
            }
        } else {
            session = self.completedSessions[indexPath.row]
            
            if indexPath.row == self.completedSessions.count - 1{
                self.getListSession()
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LogTableViewCell") as! LogTableViewCell
        
        cell.setData(session, hiddenRateButton: self.isUpComing)
        
        let totalSession = self.upCommingSessions.count + self.completedSessions.count
        if indexPath.row == totalSession - 1{
            self.getListSession()
        }

        return cell
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.isUpComing {
            if self.upCommingSessions.count == 0 {
                return 0.01
            }
        } else {
            if self.completedSessions.count == 0 {
                return 0.01
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
