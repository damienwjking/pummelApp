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
import EventKit
import CVCalendar

class SessionClientViewController: BaseViewController, LogCellDelegate, UITableViewDelegate, UITableViewDataSource, CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
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
    
    let defaults = UserDefaults.standard
    
    var isloading = false
    var canLoadMore = true
    
    var offset = 0
    var sessionList = [SessionModel]()
    var selectedSessionList = [SessionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendarMenuView.menuViewDelegate = self
        self.calendarView.calendarAppearanceDelegate = self
        self.calendarView.calendarDelegate = self
        
        self.monthLabel.font = UIFont.pmmMonReg13()
        self.noSessionYetLB.font = UIFont.pmmPlayFairReg18()
        self.noSessionContentLB.font = UIFont.pmmMonLight13()
        self.addSessionBT.titleLabel!.font = UIFont.pmmMonReg12()
        
        self.addSessionBT.layer.cornerRadius = 5
        
        self.selectSegment.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13()], for: .Normal)
        
        if self.defaults.object(forKey: k_PM_IS_UP_COMING) == nil {
            self.defaults.setValue(1, forKey: k_PM_IS_UP_COMING)
        } else {
            let isComingValue = self.defaults.object(forKey: k_PM_IS_UP_COMING) as! Int
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector:  #selector(self.getListSession), name: NSNotification.Name(rawValue: k_PM_REFRESH_SESSION), object: nil)
        self.getListSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let moveScreenType = defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_2 {
            defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
            self.performSegue(withIdentifier: "userLogASession", sender: nil)
        }
        
        // Update Calendar
        self.calendarView.presentedDate = CVDate(date: NSDate() as Date)
        self.updateLayout()
        
        self.resetSBadge()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Init
    func initTableView() {
        self.sessionTableView.estimatedRowHeight = 100
        let nibName = UINib(nibName: "LogTableViewCell", bundle:nil)
        self.sessionTableView.register(nibName, forCellReuseIdentifier: "LogTableViewCell")
        
        self.sessionTableView.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0)
    }
    
    func initNavigationBar() {
        // Remove Button At Left Navigationbar Item
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        // ADD Log Button At Right Navigationbar Item
        var image = UIImage(named: "icon_add")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.logButtonClicked))
        self.tabBarController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
    }
    
    // MARK: Private function
    func getListSession() {
        if (self.canLoadMore == true && self.isloading == false) {
            self.isloading = true
            
            SessionRouter.getSessionList(offset: self.offset, completed: { (result, error) in
                self.isloading = false
                
                if (error == nil) {
                    let sessionInfos = result as! [NSDictionary]
                    
                    if (sessionInfos.count > 0) {
                        for sessionInfo in sessionInfos {
                            let session = SessionModel()
                            session.parseData(data: sessionInfo)
                            
                            if (session.existInList(sessionList: self.sessionList) == false) {
                                self.sessionList.append(session)
                            }
                        }
                    } else {
                        self.canLoadMore = false
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.canLoadMore = false
                }
                
                self.offset = self.offset + 20
                self.getListSession()
                
                self.presentedDateUpdated(date: self.calendarView.presentedDate)
                
                self.updateLayout()
            }).fetchdata()
        }
        
        self.calendarView.contentController.refreshPresentedMonth()
    }
    
    func sortSession(isUpcoming: Bool) {
        if self.selectedSessionList.count > 0 {
            self.selectedSessionList = self.selectedSessionList.sorted { (session1, session2) -> Bool in
                let lastOpen1 = session1.datetime
                let lastOpen2 = session2.datetime
                
                if isUpcoming {
                    return (lastOpen1!.compare(lastOpen2!) == ComparisonResult.OrderedAscending)
                } else {
                    return (lastOpen1!.compare(lastOpen2!) == ComparisonResult.OrderedDescending)
                }
            }
        }
    }
    
    // MARK: UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedSessionList.count > 0 {
            self.noSessionV.isHidden = true
        } else {
            self.noSessionV.isHidden = false
        }
        
        return self.selectedSessionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let session = self.selectedSessionList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogTableViewCell") as! LogTableViewCell
        
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let sessionDate = dateFormatter.date(from: session.datetime!)
        
        if now.compare(sessionDate!) == .orderedAscending {
            cell.setData(session: session, isUpComing: true)
        } else {
            cell.setData(session: session, isUpComing: false)
        }
        
        cell.logCellDelegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.sessionList.count == 0 {
            return 0.01
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let session = self.selectedSessionList[indexPath.row]
        
        self.performSegue(withIdentifier: "userSessionDetail", sender: session)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            if indexPath.row < self.selectedSessionList.count {
                let session = self.selectedSessionList[indexPath.row]
                let sessionID = "\(session.id)"
                
                SessionRouter.deleteSession(sessionID: sessionID, completed: { (result, error) in
                    let isDeleteSuccess = result as! Bool
                    
                    if (isDeleteSuccess == true) {
                        self.selectedSessionList.remove(at: indexPath.row)
                        tableView.reloadData()
                        
                        self.sessionList.removeAll()
                        self.canLoadMore = true
                        self.getListSession()
                        
                        self.calendarView.contentController.refreshPresentedMonth()
                    }
                }).fetchdata()
            }
            
        }
        
        deleteRowAction.backgroundColor = UIColor.pmmBrightOrangeColor()
        
        return [deleteRowAction]
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
        let monthDateFormatter = DateFormatter
        monthDateFormatter.dateFormat = "yyyy M"
        let dateString = String(format:"%ld %ld", date.year, date.month)
        let convertDate = monthDateFormatter.date(from: dateString)
        
        let convertDateFormatter = DateFormatter
        convertDateFormatter.dateFormat = "LLLL yyyy"
        self.monthLabel.text = convertDateFormatter.string(from: convertDate!)
        
        // update session list
        let dateFormatter = DateFormatter
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        //let eventDateString = dateFormatter.string(from: date)
        
        let calendarString = String(format:"%ld%ld%ld%ld%ld", date.year, date.month/10, date.month%10, date.day/10, date.day%10)
        
        let fullDateFormatter = DateFormatter
        fullDateFormatter.dateFormat = kFullDateFormat
        fullDateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        var i = 0
        self.selectedSessionList.removeAll()
        while i < self.sessionList.count {
            let session = self.sessionList[i]
            let sessionDate = fullDateFormatter.date(from: session.datetime!)
            let sessionDateString = dateFormatter.string(from: sessionDate!)
            
            if NSDate().compare(sessionDate!) == .OrderedAscending && calendarString == sessionDateString {
                self.selectedSessionList.append(session)
            }
            
            i = i + 1
        }
        
        self.sortSession(true)
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
        let dateFormatter = DateFormatter
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        //let eventDateString = dateFormatter.string(from: date)
        
        let calendarString = String(format:"%ld%ld%ld%ld%ld", dayView.date.year, dayView.date.month/10, dayView.date.month%10, dayView.date.day/10, dayView.date.day%10)
        
        let fullDateFormatter = DateFormatter
        fullDateFormatter.dateFormat = kFullDateFormat
        fullDateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        var i = 0
        var showDotMarker = false
        while i < self.sessionList.count {
            let session = self.sessionList[i]
            let sessionDate = fullDateFormatter.date(from: session.datetime!)
            let sessionDateString = dateFormatter.string(from: sessionDate!)
            
            if NSDate().compare(sessionDate!) == .OrderedAscending && calendarString == sessionDateString {
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
    @IBAction func addSessionBTClicked(sender: AnyObject) {
        print("add session clicked")
        self.performSegue(withIdentifier: "userLogASession", sender: nil)
    }
    
    func logButtonClicked() {
        print("log clicked")
        self.performSegue(withIdentifier: "userLogASession", sender: nil)
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
        
        let isComingValue = self.defaults.object(forKey: k_PM_IS_UP_COMING) as! Int
        if isComingValue == 1 {
            isUpComing = true
        }
        
        if isUpComing == true {
            self.monthLabelHeightConstraint.constant = 40
            self.calendarViewHeightConstraint.constant = 200
            self.calendateMenuViewHeightConstraint.constant = 25
            self.nosessionIMVHeightConstraint.constant = 0
            self.noSessionVCenterYConstraint.constant = 0;
            self.separateLineView.isHidden = false
            
            // to Call function presentedDateUpdated
            self.calendarView.presentedDate = self.calendarView.presentedDate
            
            // Subtitle no session
            self.noSessionContentLB.text = "Upcoming appointments from your coach will appear here as well"
        } else {
            self.monthLabelHeightConstraint.constant = 0
            self.calendarViewHeightConstraint.constant = 0
            self.calendateMenuViewHeightConstraint.constant = 0
            self.nosessionIMVHeightConstraint.constant = 160
            self.noSessionVCenterYConstraint.constant = -29;
            self.separateLineView.isHidden = true
            
            // Subtitle no session
            self.noSessionContentLB.text = "Completed appointments from your coach will appear here as well"
            
            // Update session table
            let fullDateFormatter = DateFormatter
            fullDateFormatter.dateFormat = kFullDateFormat
            fullDateFormatter.timeZone = NSTimeZone.localTimeZone()
            
            var i = 0
            self.selectedSessionList.removeAll()
            while i < self.sessionList.count {
                let session = self.sessionList[i]
                let sessionDate = fullDateFormatter.date(from: session.datetime!)
                
                if NSDate().compare(sessionDate!) == .OrderedDescending {
                    self.selectedSessionList.append(session)
                }
                
                i = i + 1
            }
            
            self.sortSession(false)
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
                
                let dateFormatter = DateFormatter
                dateFormatter.dateFormat = kFullDateFormat
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                let startDate = dateFormatter.date(from: session.datetime!)
                
                let longTime = session.longtime > 0 ? session.longtime : 1
                let calendar = NSCalendar.current
                let endDate = calendar.dateByAddingUnit(.Minute, value: longTime, toDate: startDate!, options: [])
                
                
                event.title = session.type!
                event.startDate = startDate!
                event.endDate = endDate!
                event.notes = session.text!
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.saveEvent(event, span: .FutureEvents, commit: true)
                    let alertController = UIAlertController(title: "", message: "This session has been added to your calendar", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
                        // ...
                    }
                } catch {
                    
                }
            } 
        })
    }
    
    // MARK: Segue
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "userSessionDetail" {
            let destination = segue.destination as! DetailSessionViewController
            destination.session = sender as! SessionModel
        }
    }
    
}
