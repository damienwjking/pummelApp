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
    @IBOutlet weak var logTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var isUpComing = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTableView()
        
        self.getListSession()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let buttonColor = UIColor.hex("FB4311", alpha: 1)
        
        // Remove Button At Left Navigationbar Item
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        // ADD Log Button At Right Navigationbar Item
        let rightButton = UIButton()
        rightButton.titleLabel?.font = .pmmMonReg13()
        rightButton.setTitle(kLog, forState: .Normal)
        rightButton.setTitleColor(buttonColor, forState: .Normal)
        rightButton.addTarget(self, action: #selector(SessionClientViewController.logButtonClicked), forControlEvents: .TouchUpInside)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        rightButton.sizeToFit()
        self.tabBarController?.navigationItem.rightBarButtonItem? = rightBarButton
    }
    
    // MARK: Init
    func initTableView() {
        self.logTableView.estimatedRowHeight = 100
    }
    
    // MARK: Private function
    func getListSession() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_ACTIVITIES_USER)
        
        Alamofire.request(.GET, prefix)
            .responseImage { response in
                if (response.response?.statusCode == 200) {
                }
                
                self.logTableView.reloadData()
        }
    }
    
    // MARK: UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isUpComing == true {
            return 6
        } else {
            return 4;
        }
        
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isUpComing == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("LogComingTableViewCell") as! LogComingTableViewCell
            
            cell.nameLB.text = "SARAH"
            cell.messageLB.text = "tue 19th dec"
            cell.timeLB.text = "4PM"
            
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
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LogCompletedTableViewCell") as! LogCompletedTableViewCell
            
            cell.nameLB.text = "SARAH"
            cell.messageLB.text = "tue 19th dec"
            cell.timeLB.text = "4PM"
            cell.tagActionLB.text = "#RUNNING"
            
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
        }
        
        return UITableViewCell()
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
            self.logTableView.reloadData()
        }
    }
    
    
    @IBAction func completedButtonClicked(sender: AnyObject) {
        self.isUpComing = false
        
        self.view.layoutIfNeeded()
        self.underLineViewLeadingConstraint.constant = self.upcomingButton.frame.size.width
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.logTableView.reloadData()
        }
    }
    
    
    func logButtonClicked() {
        print("log clicked")
        self.performSegueWithIdentifier("userLogASession", sender: nil)
    }
    
}
