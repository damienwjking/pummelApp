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
    
    @IBOutlet weak var selectSegment: UISegmentedControl!
    @IBOutlet weak var sessionTableView: UITableView!
    
    @IBOutlet weak var noSessionV: UIView!
    @IBOutlet weak var noSessionYetLB: UILabel!
    @IBOutlet weak var noSessionContentLB: UILabel!
    @IBOutlet weak var addSessionBT: UIButton!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var isUpComing = true
    var isloading = false
    var canLoadMore = true
    
    var upCommingSessions = [Session]()
    var completedSessions = [Session]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noSessionYetLB.font = UIFont.pmmPlayFairReg18()
        self.noSessionContentLB.font = UIFont.pmmMonLight13()
        self.addSessionBT.titleLabel!.font = UIFont.pmmMonReg12()
        
        selectSegment.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13()], forState: .Normal)
        
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
        
        let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
        self.sessionTableView.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0)
    }
    
    func initNavigationBar() {
        // Remove Button At Left Navigationbar Item
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        // ADD + Button At Right Navigationbar Item
        var image = UIImage(named: "icon_add")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(self.rightButtonClicked))
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
                        } else {
                            self.canLoadMore = false
                        }
                    case .Failure(let error):
                        self.canLoadMore = false
                        print("Request failed with error: \(error)")
                    }
                    
                    self.isloading = false
                    
                    self.sessionTableView.reloadData()
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
    func rightButtonClicked() {
        let selectLog = { (action:UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("coachLogASession", sender: nil)
        }
        let selectBook = { (action:UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("coachMakeABook", sender: nil)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kLog, style: UIAlertActionStyle.Default, handler: selectLog))
        alertController.addAction(UIAlertAction(title: kBook, style: UIAlertActionStyle.Default, handler: selectBook))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    @IBAction func selecSegmentValueChanged(sender: AnyObject) {
        if self.selectSegment.selectedSegmentIndex == 0 {
            self.isUpComing = true
        } else {
            self.isUpComing = false
        }
        
        self.sessionTableView.reloadData()
    }
    
    @IBAction func addSessionBTClicked(sender: AnyObject) {
        print("add session clicked")
        self.performSegueWithIdentifier("coachLogASession", sender: nil)
    }
    
}
