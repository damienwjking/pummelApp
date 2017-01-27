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
import EventKit

class SessionCoachViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, LogCellDelegate {
    
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
        
        if self.defaults.objectForKey(k_PM_IS_UP_COMING) == nil {
            self.isUpComing = true
            self.defaults.setValue(1, forKey: k_PM_IS_UP_COMING)
        } else {
            let isComingValue = self.defaults.objectForKey(k_PM_IS_UP_COMING) as! Int
            if isComingValue == 1 {
                self.isUpComing = true
                self.selectSegment.selectedSegmentIndex = 0
            } else {
                self.isUpComing = false
                self.selectSegment.selectedSegmentIndex = 1
            }
        }
        
        self.initTableView()
        self.initNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getListSession()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let touch3DType = defaults.objectForKey(k_PM_3D_TOUCH) as! String
        if touch3DType == "3dTouch_2" {
            defaults.setObject(k_PM_3D_TOUCH_VALUE, forKey: k_PM_3D_TOUCH)
            self.performSegueWithIdentifier("coachLogASession", sender: nil)
        }
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
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(self.rightButtonClicked))
        self.tabBarController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
    }
    
    // MARK: Private function
    func checkUpCommingSesion(session: Session) {
        let now = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        if session.datetime != nil {
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
        
        
        cell.setData(session, hiddenRateButton: self.isUpComing, hiddenCalendarButton: false)
        cell.logCellDelegate = self;
        
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
        
        var session = Session()
        if self.isUpComing {
            session = self.upCommingSessions[indexPath.row]
        } else {
            session = self.completedSessions[indexPath.row]
        }
        
        self.performSegueWithIdentifier("coachSessionDetail", sender: session)
    }
    
    // MARK: Outlet function
    func rightButtonClicked() {
        let logAction = UIAlertAction(title: kLog, style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("coachLogASession", sender: nil)
        })
        
        let bookAction = UIAlertAction(title: kBook, style: UIAlertActionStyle.Destructive, handler: { (action:UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("coachMakeABook", sender: nil)
        })
        
        let cancleAction = UIAlertAction(title: kCancle, style: .Cancel, handler: { (UIAlertAction) in
            
        })
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(logAction)
        alertController.addAction(bookAction)
        alertController.addAction(cancleAction)
        
        self.presentViewController(alertController, animated: true) { }
        
//        let logAttributedText = NSMutableAttributedString(string: kLog)
//        let logRange = NSRange(location: 0, length: logAttributedText.length)
//        logAttributedText.addAttribute(NSFontAttributeName, value: UIFont.pmmMonReg16(), range: logRange)
//        logAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.pmmBrightOrangeColor(), range: logRange)
//        guard let logTitleLabel = logAction.valueForKey("__representer")?.valueForKey("label") as? UILabel else { return }
//        logTitleLabel.attributedText = logAttributedText
//        
//        let bookAttributedText = NSMutableAttributedString(string: kBook)
//        let bookRange = NSRange(location: 0, length: bookAttributedText.length)
//        bookAttributedText.addAttribute(NSFontAttributeName, value: UIFont.pmmMonReg16(), range: bookRange)
//        bookAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.pmmBrightOrangeColor(), range: bookRange)
//        guard let bookTitleLabel = bookAction.valueForKey("__representer")?.valueForKey("label") as? UILabel else { return }
//        bookTitleLabel.attributedText = bookAttributedText
//        
//        let cancleAttributedText = NSMutableAttributedString(string: kCancle)
//        let cancleRange = NSRange(location: 0, length: cancleAttributedText.length)
//        cancleAttributedText.addAttribute(NSFontAttributeName, value: UIFont.pmmMonReg18(), range: cancleRange)
//        guard let cancleTitleLabel = cancleAction.valueForKey("__representer")?.valueForKey("label") as? UILabel else { return }
//        cancleTitleLabel.attributedText = cancleAttributedText
    }
    
    @IBAction func selecSegmentValueChanged(sender: AnyObject) {
        if self.selectSegment.selectedSegmentIndex == 0 {
            self.isUpComing = true
            self.defaults.setValue(1, forKey: k_PM_IS_UP_COMING)
        } else {
            self.isUpComing = false
            self.defaults.setValue(0, forKey: k_PM_IS_UP_COMING)
        }
        
        self.sessionTableView.reloadData()
    }
    
    @IBAction func addSessionBTClicked(sender: AnyObject) {
        self.rightButtonClicked()
    }
    
    // MARK: LogCellDelegate
    func LogCellClickAddCalendar(cell: LogTableViewCell) {
        var session = Session()
        let indexPath = self.sessionTableView.indexPathForCell(cell)
        if self.isUpComing {
            session = self.upCommingSessions[indexPath!.row]
        } else {
            session = self.completedSessions[indexPath!.row]
        }
        
        let eventStore : EKEventStore = EKEventStore()
        
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        
        eventStore.requestAccessToEntityType(.Event, completion: {
            (granted, error) in
            
            if (granted) && (error == nil) {
                let event:EKEvent = EKEvent(eventStore: eventStore)
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = kFullDateFormat
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                let startDate = dateFormatter.dateFromString(session.datetime!)
                
                let longTime = session.longtime! > 0 ? session.longtime! : 1
                let calendar = NSCalendar.currentCalendar()
                let endDate = calendar.dateByAddingUnit(.Minute, value: longTime, toDate: startDate!, options: [])
                
                
                event.title = session.type!
                event.startDate = startDate!
                event.endDate = endDate!
                event.notes = session.text!
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.saveEvent(event, span: .FutureEvents, commit: true)
                    let alertController = UIAlertController(title: "", message: "This session has added to your callendar!", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                } catch {
                    
                }
            }
        })
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "coachSessionDetail" {
            let destination = segue.destinationViewController as! DetailSessionViewController
            destination.session = sender as! Session
        }
    }
    
}
