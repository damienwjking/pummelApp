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

class SessionCoachViewController: BaseViewController, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
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
        
        self.selectSegment.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13()], for: .normal)
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(SessionCoachViewController.getListSession), name: NSNotification.Name(rawValue: k_PM_REFRESH_SESSION), object: nil)
        self.getListSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let moveScreenType = defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_2 {
            self.defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
            self.performSegue(withIdentifier: "coachLogASession", sender: nil)
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
        // ADD + Button At Right Navigationbar Item
        var image = UIImage(named: "icon_add")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.rightButtonClicked))
        self.tabBarController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
    }
    
    // MARK: Private function
    func getListSession() {
        if (self.canLoadMore == true && self.isloading == false) {
            self.isloading = true
            
            var prefix = kPMAPIUSER
            prefix.append(PMHelper.getCurrentID())
            prefix.append(kPM_PATH_ACTIVITIES_USER)
            prefix.append(String(self.offset))
            
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
                    
                    self.offset = self.offset + 20
                    
                    self.getListSession()
                    
                    self.presentedDateUpdated(self.calendarView.presentedDate)
                    
                    self.updateLayout()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.canLoadMore = false
                }
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
                    return (lastOpen1!.compare(lastOpen2!) == ComparisonResult.orderedAscending)
                } else {
                    return (lastOpen1!.compare(lastOpen2!) == ComparisonResult.orderedDescending)
                }
            }
        }
    }
    
    // MARK: Outlet function
    func rightButtonClicked() {
        let logAction = UIAlertAction(title: kLog, style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "coachLogASession", sender: nil)
        })
        
        let bookAction = UIAlertAction(title: kBook, style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "coachMakeABook", sender: nil)
        })
        
        let cancleAction = UIAlertAction(title: kCancle, style: .cancel, handler: { (UIAlertAction) in
            
        })
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(logAction)
        alertController.addAction(bookAction)
        alertController.addAction(cancleAction)
        
        self.present(alertController, animated: true) { }
        
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
    
    @IBAction func addSessionBTClicked(_ sender: Any) {
        self.rightButtonClicked()
    }

    @IBAction func selecSegmentValueChanged(_ sender: Any) {
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
            self.separateLineView.isHidden = true
            
            // Subtitle no session
            self.noSessionContentLB.text = "Completed appointments from your coach will appear here as well"
            
            // Update session table
            let fullDateFormatter = DateFormatter()
            fullDateFormatter.dateFormat = kFullDateFormat
            fullDateFormatter.timeZone = NSTimeZone.local
            
            var i = 0
            self.selectedSessionList.removeAll()
            while i < self.sessionList.count {
                let session = self.sessionList[i]
                let sessionDate = fullDateFormatter.date(from: session.datetime!)
                
                if NSDate().compare(sessionDate!) == .orderedDescending {
                    self.selectedSessionList.append(session)
                }
                
                i = i + 1
            }
            
            self.sortSession(isUpcoming: false)
            self.sessionTableView.reloadData()
        }
    }
    
    // MARK: Segue
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "coachSessionDetail" {
            let destination = segue.destination as! DetailSessionViewController
            destination.session = sender as! SessionModel
        }
    }
}

extension SessionCoachViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        self.performSegue(withIdentifier: "coachSessionDetail", sender: session)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            if indexPath.row < self.selectedSessionList.count {
                let session = self.selectedSessionList[indexPath.row]
                let sessionID = String(format: "%ld", session.id)
                
                SessionRouter.deleteSession(sessionID: sessionID, completed: { (result, error) in
                    let deleteSessionSuccess = result as! Bool
                    
                    if (deleteSessionSuccess == true) {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Call to show editing action
    }
}

// MARK: CVCalendarViewDelegate
extension SessionCoachViewController: CVCalendarViewDelegate {
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        self.calendarView.contentController.refreshPresentedMonth()
        
        let yearValue = date.year
        let monthValue = date.month
        let dayValue = date.day
        
        // update month label
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "yyyy M"
        let dateString = String(format:"%ld %ld", yearValue, monthValue)
        let convertDate = monthDateFormatter.date(from: dateString)
        
        let convertDateFormatter = DateFormatter()
        convertDateFormatter.dateFormat = "LLLL yyyy"
        self.monthLabel.text = convertDateFormatter.string(from: convertDate!)
        
        // update session list
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = NSTimeZone.local
        //let eventDateString = dateFormatter.string(from: date)
        
        let calendarString = String(format:"%ld%ld%ld%ld%ld", yearValue, monthValue / 10, monthValue % 10, dayValue / 10, dayValue % 10)
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = kFullDateFormat
        fullDateFormatter.timeZone = NSTimeZone.local
        
        var i = 0
        self.selectedSessionList.removeAll()
        while i < self.sessionList.count {
            let session = self.sessionList[i]
            let sessionDate = fullDateFormatter.date(from: session.datetime!)
            let sessionDateString = dateFormatter.string(from: sessionDate!)
            
            if NSDate().compare(sessionDate!) == .orderedAscending && calendarString == sessionDateString {
                self.selectedSessionList.append(session)
            }
            
            i = i + 1
        }
        
        self.sortSession(isUpcoming: true)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = NSTimeZone.local
        //let eventDateString = dateFormatter.string(from: date)
        
        let calendarString = String(format:"%ld%ld%ld%ld%ld", dayView.date.year, dayView.date.month/10, dayView.date.month%10, dayView.date.day/10, dayView.date.day%10)
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = kFullDateFormat
        fullDateFormatter.timeZone = NSTimeZone.local
        
        var i = 0
        var showDotMarker = false
        while i < self.sessionList.count {
            let session = self.sessionList[i]
            let sessionDate = fullDateFormatter.date(from: session.datetime!)
            let sessionDateString = dateFormatter.string(from: sessionDate!)
            
            if NSDate().compare(sessionDate!) == .orderedAscending &&  calendarString == sessionDateString {
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
}

// MARK: LogCellDelegate
extension SessionCoachViewController: LogCellDelegate {
    func LogCellClickAddCalendar(cell: LogTableViewCell) {
        let indexPath = self.sessionTableView.indexPath(for: cell)
        let session = self.sessionList[indexPath!.row]
        
        let eventStore : EKEventStore = EKEventStore()
        
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        
        eventStore.requestAccess(to: .event, completion: {
            (granted, error) in
            
            if (granted) && (error == nil) {
                let event:EKEvent = EKEvent(eventStore: eventStore)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = kFullDateFormat
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
                let startDate = dateFormatter.date(from: session.datetime!)
                
                let longTime = session.longtime > 0 ? session.longtime : 1
                let calendar = NSCalendar.current
                var endDateComponent = DateComponents()
                endDateComponent.minute = longTime
                let endDate = calendar.date(byAdding: endDateComponent, to: startDate!)
                
                event.title = session.type!
                event.startDate = startDate!
                event.endDate = endDate!
                event.notes = session.text!
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .futureEvents, commit: true)
                    let alertController = UIAlertController(title: "", message: "This session has been added to your calendar!", preferredStyle: .alert)
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
}
