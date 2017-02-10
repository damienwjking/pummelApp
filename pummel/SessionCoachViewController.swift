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
import CVCalendar

class SessionCoachViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, LogCellDelegate, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
    @IBOutlet weak var selectSegment: UISegmentedControl!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var calendarMenuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendateMenuViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var separateLineView: UIView!
    @IBOutlet weak var sessionTableView: UITableView!
    
    @IBOutlet weak var noSessionV: UIView!
    @IBOutlet weak var noSessionYetLB: UILabel!
    @IBOutlet weak var noSessionContentLB: UILabel!
    @IBOutlet weak var noSessionVCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var nosessionIMVHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addSessionBT: UIButton!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var isloading = false
    var canLoadMore = true
    
    var sessionList = [Session]()
    var selectedSessionList = [Session]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendarMenuView.menuViewDelegate = self
        self.calendarView.calendarAppearanceDelegate = self
        self.calendarView.calendarDelegate = self
        
        self.monthLabel.font = UIFont.pmmMonReg13()
        self.noSessionYetLB.font = UIFont.pmmPlayFairReg18()
        self.noSessionContentLB.font = UIFont.pmmMonLight13()
        self.addSessionBT.titleLabel!.font = UIFont.pmmMonReg12()
        
        self.selectSegment.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13()], forState: .Normal)
        
        if self.defaults.objectForKey(k_PM_IS_UP_COMING) == nil {
            self.defaults.setValue(1, forKey: k_PM_IS_UP_COMING)
        } else {
            let isComingValue = self.defaults.objectForKey(k_PM_IS_UP_COMING) as! Int
            if isComingValue == 1 {
                self.selectSegment.selectedSegmentIndex = 0
            } else {
                self.selectSegment.selectedSegmentIndex = 1
            }
        }
        
        self.initTableView()
        self.initNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        self.calendarMenuView.commitMenuViewUpdate()
        self.calendarView.commitCalendarViewUpdate()
        
        
        super.viewDidLayoutSubviews()
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
        
        // Update Calendar
        self.calendarView.presentedDate = CVDate(date: NSDate())
        self.updateLayout()
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
    func getListSession() {
        if (self.canLoadMore == true && self.isloading == false) {
            self.isloading = true
            let totalSession = self.sessionList.count
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
                                
                                var isNewSession = true
                                for sessionItem in self.sessionList {
                                    if session.id == sessionItem.id {
                                        isNewSession = false
                                    }
                                }
                                
                                if isNewSession == true {
                                    self.sessionList.append(session)
                                }
                            }
                        } else {
                            self.canLoadMore = false
                        }
                    case .Failure(let error):
                        self.canLoadMore = false
                        print("Request failed with error: \(error)")
                    }
                    
                    self.isloading = false
                    
                    self.getListSession()
                    
                    self.presentedDateUpdated(self.calendarView.presentedDate)
                    
                    self.updateLayout()
            }
        }
        
        self.calendarView.contentController.refreshPresentedMonth()
    }
    
    // MARK: UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedSessionList.count > 0 {
            self.noSessionV.hidden = true
        } else {
            self.noSessionV.hidden = false
        }
        
        return self.selectedSessionList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let session = self.selectedSessionList[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LogTableViewCell") as! LogTableViewCell
        
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let sessionDate = dateFormatter.dateFromString(session.datetime!)
        
        if now.compare(sessionDate!) == .OrderedAscending {
            cell.setData(session, isUpComing: true)
        } else {
            cell.setData(session, isUpComing: false)
        }
        
        cell.logCellDelegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.sessionList.count == 0 {
            return 0.01
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let session = self.selectedSessionList[indexPath.row]
        
        self.performSegueWithIdentifier("coachSessionDetail", sender: session)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) in
            if indexPath.row < self.selectedSessionList.count {
                let session = self.selectedSessionList[indexPath.row]
                
                let prefix = kPMAPIDELETEACTIVITY
                let param = ["activityId":session.id!]
                
                Alamofire.request(.POST, prefix, parameters: param)
                    .responseJSON { response in
                        if response.response?.statusCode == 200 {
                            self.selectedSessionList.removeAtIndex(indexPath.row)
                            tableView.reloadData()
                            
                            self.sessionList.removeAll()
                            self.canLoadMore = true
                            self.getListSession()
                            
                            self.calendarView.contentController.refreshPresentedMonth()
                            
                        }
                }
            }
            
        }
        deleteRowAction.backgroundColor = UIColor.pmmBrightOrangeColor()
        
        
        return [deleteRowAction]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Call to show editing action
    }
    
    // MARK: CVCalendarViewDelegate
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func presentedDateUpdated(date: Date) {
        self.calendarView.contentController.refreshPresentedMonth()
        
        // update month label
        let monthDateFormatter = NSDateFormatter()
        monthDateFormatter.dateFormat = "yyyy M"
        let dateString = String(format:"%ld %ld", date.year, date.month)
        let convertDate = monthDateFormatter.dateFromString(dateString)
        
        let convertDateFormatter = NSDateFormatter()
        convertDateFormatter.dateFormat = "LLLL yyyy"
        self.monthLabel.text = convertDateFormatter.stringFromDate(convertDate!)
        
        // update session list
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        //let eventDateString = dateFormatter.stringFromDate(date)
        
        let calendarString = String(format:"%ld%ld%ld%ld%ld", date.year, date.month/10, date.month%10, date.day/10, date.day%10)
        
        let fullDateFormatter = NSDateFormatter()
        fullDateFormatter.dateFormat = kFullDateFormat
        fullDateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        var i = 0
        self.selectedSessionList.removeAll()
        while i < self.sessionList.count {
            let session = self.sessionList[i]
            let sessionDate = fullDateFormatter.dateFromString(session.datetime!)
            let sessionDateString = dateFormatter.stringFromDate(sessionDate!)
            
            if NSDate().compare(sessionDate!) == .OrderedAscending && calendarString == sessionDateString {
                self.selectedSessionList.append(session)
            }
            
            i = i + 1
        }
        
        self.sessionTableView.reloadData()
    }
    
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont {
        return UIFont.pmmMonLight13()
    }
    
    func dayLabelWeekdayHighlightedBackgroundColor() -> UIColor {
        return UIColor.pmmBrightOrangeColor()
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.pmmBrightOrangeColor()
    }
    
    func dayLabelPresentWeekdayHighlightedBackgroundColor() -> UIColor {
        return UIColor.pmmBrightOrangeColor()
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.pmmBrightOrangeColor()
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor {
        return UIColor.pmmBrightOrangeColor()
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        //let eventDateString = dateFormatter.stringFromDate(date)
        
        let calendarString = String(format:"%ld%ld%ld%ld%ld", dayView.date.year, dayView.date.month/10, dayView.date.month%10, dayView.date.day/10, dayView.date.day%10)
        
        let fullDateFormatter = NSDateFormatter()
        fullDateFormatter.dateFormat = kFullDateFormat
        fullDateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        var i = 0
        var showDotMarker = false
        while i < self.sessionList.count {
            let session = self.sessionList[i]
            let sessionDate = fullDateFormatter.dateFromString(session.datetime!)
            let sessionDateString = dateFormatter.stringFromDate(sessionDate!)
            
            if NSDate().compare(sessionDate!) == .OrderedAscending &&  calendarString == sessionDateString {
                showDotMarker = true
                break;
            }
            
            i = i + 1
        }
        
        return showDotMarker
    }
    
    func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat {
        return 9
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [UIColor.pmmBrightOrangeColor()]
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
    
    @IBAction func addSessionBTClicked(sender: AnyObject) {
        self.rightButtonClicked()
    }

    @IBAction func selecSegmentValueChanged(sender: AnyObject) {
        if self.selectSegment.selectedSegmentIndex == 0 {
            self.defaults.setValue(1, forKey: k_PM_IS_UP_COMING)
        } else {
            self.defaults.setValue(0, forKey: k_PM_IS_UP_COMING)
        }
        
        self.updateLayout()
    }

    func updateLayout() {
        // Update layout
        var isUpComing = false
        
        let isComingValue = self.defaults.objectForKey(k_PM_IS_UP_COMING) as! Int
        if isComingValue == 1 {
            isUpComing = true
        }
        
        if isUpComing == true {
            self.monthLabelHeightConstraint.constant = 40
            self.calendarViewHeightConstraint.constant = 200
            self.calendateMenuViewHeightConstraint.constant = 25
            self.nosessionIMVHeightConstraint.constant = 0
            self.noSessionVCenterYConstraint.constant = 0;
            self.separateLineView.hidden = false
            
            // To Call function presentedDateUpdated
            self.calendarView.presentedDate = self.calendarView.presentedDate
            
            // Subtitle no session
            self.noSessionContentLB.text = "Upcoming appointments from your coach will appear here as well"
        } else {
            self.monthLabelHeightConstraint.constant = 0
            self.calendarViewHeightConstraint.constant = 0
            self.calendateMenuViewHeightConstraint.constant = 0
            self.nosessionIMVHeightConstraint.constant = 160
            self.noSessionVCenterYConstraint.constant = -29;
            self.separateLineView.hidden = true
            
            // Subtitle no session
            self.noSessionContentLB.text = "Completed appointments from your coach will appear here as well"
            
            // Update session table
            let fullDateFormatter = NSDateFormatter()
            fullDateFormatter.dateFormat = kFullDateFormat
            fullDateFormatter.timeZone = NSTimeZone.localTimeZone()
            
            var i = 0
            self.selectedSessionList.removeAll()
            while i < self.sessionList.count {
                let session = self.sessionList[i]
                let sessionDate = fullDateFormatter.dateFromString(session.datetime!)
                
                if NSDate().compare(sessionDate!) == .OrderedDescending {
                    self.selectedSessionList.append(session)
                }
                
                i = i + 1
            }
            
            self.sessionTableView.reloadData()
        }
    }
    
    // MARK: LogCellDelegate
    func LogCellClickAddCalendar(cell: LogTableViewCell) {
        let indexPath = self.sessionTableView.indexPathForCell(cell)
        let session = self.sessionList[indexPath!.row]
        
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
                    let alertController = UIAlertController(title: "", message: "This session has been added to your callendar!", preferredStyle: .Alert)
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
