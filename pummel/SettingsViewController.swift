//
//  SettingsViewController.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import MessageUI
import Alamofire
import LocationPicker
import CoreLocation
import MapKit
import Mixpanel

class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var settingTableView: UITableView!
   
    let cellHeight10 : CGFloat = 10
    let cellHeight30 : CGFloat = 30
    let cellHeight49 : CGFloat = 49
    let cellHeight50 : CGFloat = 50
    let cellHeight60 : CGFloat = 60
    let cellHeight71 : CGFloat = 71
    let cellHeight100 : CGFloat = 100
    
    let knumberOfRowCoach = 24
    let knumberOfRowUser = 23
    var userInfo: NSDictionary!
    
    var mapState = ""
    var mapCity = ""
    var distanceSliderValue : CGFloat = 0.0
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var location: Location? {
        didSet {
        }
    }
    
    var newLeadCell = SettingNewConnectionsTableViewCell()
    var messageCell = SettingNewConnectionsTableViewCell()
    var sessionCell = SettingNewConnectionsTableViewCell()
    var backFromOther : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kNavSetting
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.translucent = false;
       
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "DONE", style: .Plain, target: self, action: #selector(SettingsViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        if self.defaults.objectForKey(kNewConnections) == nil {
            self.defaults.setObject(true, forKey: kNewConnections)
        }
        if self.defaults.objectForKey(kMessage) == nil {
            self.defaults.setObject(true, forKey: kMessage)
        }
        if self.defaults.objectForKey(kSessions) == nil {
            self.defaults.setObject(true, forKey: kSessions)
        }
        if self.defaults.objectForKey(kUnit) == nil {
            self.defaults.setObject(metric, forKey: kUnit)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        settingTableView.delegate = self
        settingTableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true && self.backFromOther == false) {
            let indexpath = NSIndexPath(forRow: 3, inSection: 0)
            let cellLocation = self.settingTableView.cellForRowAtIndexPath(indexpath) as! SettingLocationTableViewCell
            if self.location != nil {
                if self.location?.name != cellLocation.locationContentLB.text {
                    let indexpath = NSIndexPath(forRow: 3, inSection: 0)
                    let cellLocation = self.settingTableView.cellForRowAtIndexPath(indexpath) as! SettingLocationTableViewCell
                    
                    var locationName = ""
                    if (self.location?.name?.isEmpty == false) {
                        locationName = (self.location?.name)!
                    }
                    
                    cellLocation.locationContentLB.text = locationName
                    self.updateLocationCoach()
                }
            }
        }
        
        if (self.backFromOther == true) {
            self.backFromOther = false
        }
    }
    
    
    
    func updateLocationCoach() {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            var prefix = kPMAPICOACH
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            
            var locationName = ""
            if (self.location?.name?.isEmpty == false) {
                locationName = (self.location?.name)!
            }
            
            let param = [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String,
                         kServiceArea:locationName,
                         kLat:(self.location?.coordinate.latitude)!,
                         kLong:(self.location?.coordinate.longitude)!]
            Alamofire.request(.PUT, prefix, parameters: param as? [String : AnyObject])
                .responseJSON { response in switch response.result {
                case .Success(_): break
                    
                case .Failure(let error):
                    print(error)
                    }
            }
            
            self.getCityStageOfUser((self.location?.coordinate.latitude)!, long: (self.location?.coordinate.longitude)!)
        }
    }
    
    func done() {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            self.defaults.setObject(self.newLeadCell.switchBT.on, forKey: kNewConnections)
            self.defaults.setObject(self.messageCell.switchBT.on, forKey: kMessage)
            self.defaults.setObject(self.sessionCell.switchBT.on, forKey: kSessions)
            var prefix = kPMAPICOACH
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            self.view.makeToastActivity(message: "Saving")
            
            let param = [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String,
                         kDistance: self.distanceSliderValue,
                         kState: self.mapState,
                         kCity: self.mapCity]
            Alamofire.request(.PUT, prefix, parameters: param as? [String : AnyObject])
                .responseJSON { response in switch response.result {
                case .Success(_):
                    var prefixUser = kPMAPIUSER
                    prefixUser.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
                    prefixUser.appendContentsOf("/notification")
                    let paramUser = [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, "messageNotification": self.messageCell.switchBT.on ? "1" : "0", "newleadNotification": self.newLeadCell.switchBT.on ? "1" : "0", "sessionNotification": self.sessionCell.switchBT.on ? "1" : "0"]
                    
                    Alamofire.request(.PUT, prefixUser, parameters: paramUser)
                        .responseJSON { response in
                            self.navigationController?.popViewControllerAnimated(true)
                            self.view.hideToastActivity()
                    }
                case .Failure(let error):
                    print(error)
                    self.navigationController?.popViewControllerAnimated(true)
                    self.view.hideToastActivity()
                    }
            }
        } else {
            self.defaults.setObject(self.messageCell.switchBT.on, forKey: kMessage)
            self.defaults.setObject(self.sessionCell.switchBT.on, forKey: kSessions)
            self.view.makeToastActivity(message: "Saving")
            var prefixUser = kPMAPIUSER
            prefixUser.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefixUser.appendContentsOf("/notification")
            let paramUser = [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, "messageNotification": self.messageCell.switchBT.on ? "1" : "0", "sessionNotification": self.sessionCell.switchBT.on ? "1" : "0"]
            
            Alamofire.request(.PUT, prefixUser, parameters: paramUser)
                .responseJSON { response in
                    self.navigationController?.popViewControllerAnimated(true)
                    self.view.hideToastActivity()
            }
        }
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Save Setting"]
        mixpanel.track("IOS.Profile.Setting", properties: properties)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            return knumberOfRowCoach
        } else {
            return knumberOfRowUser
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            switch indexPath.row {
            case 2:
                return cellHeight49
            case 3:
                return cellHeight71
            case 4:
                return 100
            case 0, 1, 5, 9, 15:
                return cellHeight60
            case 6, 7, 8, 10, 12, 14, 16, 18, 20, 21, 22, 23:
                return cellHeight50
            case 11, 13, 17, 19:
                return cellHeight10
            default:
                return cellHeight30
            }
        } else {
            switch indexPath.row {
            case 4, 6, 7, 9, 11, 13, 15, 17, 19, 20, 21, 22, 23:
                return cellHeight50
            case 0, 1, 2, 3, 5, 8, 14:
                return cellHeight60
            case 10, 12, 16, 18:
                return cellHeight10
            default:
                return cellHeight30
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kUnitMeasure
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = self.defaults.objectForKey(kUnit) as? String
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingDiscoveryHeaderTableViewCell, forIndexPath: indexPath) as! SettingDiscoveryHeaderTableViewCell
                    cell.discoveryLB.font = .pmmMonReg11()
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingLocationTableViewCell, forIndexPath: indexPath) as! SettingLocationTableViewCell
                cell.locationLB.font = .pmmMonReg11()
                cell.myCurrentLocationLB.font = .pmmMonReg11()
                cell.locationContentLB.font = .pmmMonReg11()
                self.configLocationCell(cell)
                return cell
            case 4:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingMaxDistanceTableViewCell, forIndexPath: indexPath) as! SettingMaxDistanceTableViewCell
                cell.maxDistanceLB.font = .pmmMonReg11()
                cell.maxDistanceContentLB.font = .pmmMonReg11()
                cell.slider.maximumValue = 50
                cell.slider.minimumValue = 0
                self.configDistanceCell(cell)
                return cell
            case 5:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kNotification
                return cell
            case 6:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kNewConnections.uppercaseString
                cell.switchBT.on = self.defaults.objectForKey(kNewConnections) as! Bool
                self.newLeadCell = cell
                return cell
            case 7:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kMessage
                cell.switchBT.on = self.defaults.objectForKey(kMessage) as! Bool
                self.messageCell = cell
                return cell
            case 8:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kSessions
                cell.switchBT.on = self.defaults.objectForKey(kSessions) as! Bool
                self.sessionCell = cell
                return cell
            case 9:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kContactUs
                return cell
            case 10:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kHelpSupport
                return cell
            case 11, 13, 17:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingSmallSeperateTableViewCell, forIndexPath: indexPath) as! SettingSmallSeperateTableViewCell
                return cell
            case 12:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kFeedback
                return cell
            case 14:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kSharePummel
                return cell
            case 15:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kLegal
                return cell
            case 16:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kPrivacy
                return cell
            case 18:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kTermOfService
                return cell
            case 20:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kChangePassword
                return cell
            case 22:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingLogoutTableViewCell, forIndexPath: indexPath) as! SettingLogoutTableViewCell
                cell.logoutLB.font = .pmmMonReg11()
                return cell
            case 23:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = UIApplication.versionBuild()
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
                cell.selectionStyle = .None
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingBigSeperateTableViewCell, forIndexPath: indexPath) as! SettingBigSeperateTableViewCell
                return cell
            }
        } else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kUnitMeasure
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = self.defaults.objectForKey(kUnit) as? String
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kIAmFitnessProfessional
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.selectionStyle = .None
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kVerifiedFitnessProfessional
                return cell
            case 4:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.textColor = .pmmBrightOrangeColor()
                cell.helpAndSupportLB.text = kApplyNow
                return cell
            case 5:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kNotification
                return cell
            case 6:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kMessage
                cell.switchBT.on = self.defaults.objectForKey(kMessage) as! Bool
                self.messageCell = cell
                return cell
            case 7:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kSessions
                cell.switchBT.on = self.defaults.objectForKey(kSessions) as! Bool
                self.sessionCell = cell
                return cell
            case 8:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kContactUs
                return cell
            case 9:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kHelpSupport
                return cell
            case 10, 12, 16:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingSmallSeperateTableViewCell, forIndexPath: indexPath) as! SettingSmallSeperateTableViewCell
                return cell
            case 11:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kFeedback
                return cell
            case 13:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kSharePummel
                return cell
            case 14:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kLegal
                return cell
            case 15:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kPrivacy
                return cell
            case 17:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kTermOfService
                return cell
            case 19:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = kChangePassword
                return cell
            case 21:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingLogoutTableViewCell, forIndexPath: indexPath) as! SettingLogoutTableViewCell
                cell.logoutLB.font = .pmmMonReg11()
                return cell
            case 22:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.textColor = UIColor.blackColor()
                cell.helpAndSupportLB.text = UIApplication.versionBuild()
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
                cell.selectionStyle = .None
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingBigSeperateTableViewCell, forIndexPath: indexPath) as! SettingBigSeperateTableViewCell
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            switch indexPath.row {
            case 1:
                self.selectMeasure()
            case 3:
                self.performSegueWithIdentifier("LocationPicker", sender: nil)
                // Tracker mixpanel
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Navigation Click", "Label":"Go Set Location"]
                mixpanel.track("IOS.Profile.Setting", properties: properties)
            case 10:
                self.sendSupportEmail()
            case 12:
                self.sendFeedbackEmail()
            case 14:
                self.sharePummel()
            case 16:
                self.openPrivacy()
            case 18:
                self.openTerms()
            case 20:
                self.performSegueWithIdentifier("changePassword", sender: nil)
            case 22:
                self.showMsgConfirmLogout()
            default: break
            }
        } else {
            switch indexPath.row {
            case 1:
                self.selectMeasure()
            case 4:
                self.upgradeToCoach()
            case 9:
                self.sendSupportEmail()
            case 11:
                self.sendFeedbackEmail()
            case 13:
                self.sharePummel()
            case 15:
                self.openPrivacy()
            case 17:
                self.openTerms()
            case 19:
                self.performSegueWithIdentifier("changePassword", sender: nil)
            case 21:
                self.showMsgConfirmLogout()
            default: break
            }
        }
    }
    
    func configLocationCell(cell: SettingLocationTableViewCell) {
        var prefix = kPMAPICOACH
        prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetailFull = JSON as! NSDictionary
                if !(userDetailFull[kServiceArea] is NSNull) {
                    cell.locationContentLB.text = userDetailFull[kServiceArea] as? String
                    if !(userDetailFull[kLat] is NSNull) && !(userDetailFull[kLong] is NSNull) {
                        if let lat = userDetailFull[kLat] as? Double {
                            if let long = userDetailFull[kLong] as? Double {
                                let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                self.location = Location(name: userDetailFull[kServiceArea] as? String, location: nil,
                                    placemark: MKPlacemark(coordinate: coordinates, addressDictionary: [:]))
                            }
                        }
                    }
                } else {
                    cell.locationContentLB.text = "..."
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func configDistanceCell(cell: SettingMaxDistanceTableViewCell) {
        var prefix = kPMAPICOACH
        prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetailFull = JSON as! NSDictionary
                if !(userDetailFull[kDistance] is NSNull) {
                    var distance = String(format:"%0.f", userDetailFull[kDistance]!.doubleValue)
                    distance.appendContentsOf(" kms")
                    cell.maxDistanceContentLB.text = distance
                    cell.slider.value = userDetailFull[kDistance] as! Float
                    self.distanceSliderValue = userDetailFull[kDistance] as! CGFloat
                } else {
                    cell.maxDistanceContentLB.text = k25kms
                    self.distanceSliderValue = 25.0
                    cell.slider.value = 25.0
                }
                cell.slider.addTarget(self, action:#selector(SettingsViewController.sliderValueDidChange), forControlEvents: .ValueChanged)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func sliderValueDidChange(sender:UISlider!) {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            let indexpath = NSIndexPath(forRow: 4, inSection: 0)
            let cellDistance = self.settingTableView.cellForRowAtIndexPath(indexpath) as! SettingMaxDistanceTableViewCell
            var value = String(format:"%0.f", sender.value)
            value.appendContentsOf(" kms")
            cellDistance.maxDistanceContentLB.text = value
            self.distanceSliderValue = CGFloat(sender.value)
        }
    }
    
    func sendSupportEmail() {
        self.backFromOther = true
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([kPMSUPPORT_EMAIL])
            mailComposerVC.setSubject(kReportAProblem)
            self.presentViewController(mailComposerVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func sendFeedbackEmail() {
        self.backFromOther = true
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([kPMHELLO_EMAIL])
            mailComposerVC.setSubject(kSendaFeedback)
            self.presentViewController(mailComposerVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func sharePummel() {
        self.shareTextImageAndURL(pummelSlogan, sharingImage: UIImage(named: "shareLogo.png"), sharingURL: NSURL.init(string: kPM))
    }
    
    func shareTextImageAndURL(sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func openPrivacy() {
        let alertController = UIAlertController(title: pmmNotice, message: openLink, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
            UIApplication.sharedApplication().openURL(NSURL(string: kPM_PRIVACY)!)
        }
        alertController.addAction(OKAction)
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true) {}
    }
    
    func openTerms() {
        let alertController = UIAlertController(title: pmmNotice, message: openLink, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
             UIApplication.sharedApplication().openURL(NSURL(string: kPM_TERM)!)
        }
        alertController.addAction(OKAction)
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true) {}
    }
    
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: pmmNotice, message: couldNotSendEmailAlert, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true) { }
    }
    
    func logOut() {
        self.view.makeToastActivity(message: "Logging Out")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "MESSAGE_BADGE_VALUE")
        Alamofire.request(.DELETE, kPMAPI_LOGOUT).response { (req, res, data, error) -> Void in
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            print(res)
            self.view.hideToastActivity()
            
            let outputString = NSString(data: data!, encoding:NSUTF8StringEncoding)
            if ((outputString?.containsString(kLogoutSuccess)) != nil) {
                self.defaults.setObject(false, forKey: k_PM_IS_LOGINED)
                self.defaults.setObject(false, forKey: k_PM_IS_COACH)
                let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for cookie in storage.cookies! {
                    Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.deleteCookie(cookie)
                    storage.deleteCookie(cookie)
                }
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.performSegueWithIdentifier("backToRegister", sender: nil)
            } else {
                let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
            }
        }
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Logout"]
        mixpanel.track("IOS.Profile.Setting", properties: properties)
    }
    
    func showMsgConfirmLogout() {
        let confirmLogout = { (action:UIAlertAction!) -> Void in
            self.logOut()
        }
        
        let alertController = UIAlertController(title: nil, message: kMessConfirmLogout, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Log out", style: UIAlertActionStyle.Destructive, handler: confirmLogout))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func selectMeasure() {
        let selectMetric = { (action:UIAlertAction!) -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.view.makeToastActivity(message: "Saving")
            
            self.defaults.setObject(metric, forKey: kUnit)
            
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            
            Alamofire.request(.PUT, prefix, parameters:
                [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String,
                    kFirstname:self.defaults.objectForKey(kFirstname) as! String,
                    kUnits: metric,
                ])
                .responseJSON { response in
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    self.view.hideToastActivity()
                    self.settingTableView.reloadData()
            }
        }
        
        let selectImperial = { (action:UIAlertAction!) -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.view.makeToastActivity(message: "Saving")
            
            self.defaults.setObject(imperial, forKey: kUnit)
            
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            
            Alamofire.request(.PUT, prefix, parameters:
                [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String,
                    kFirstname:self.defaults.objectForKey(kFirstname) as! String,
                    kUnits: imperial,
                ])
                .responseJSON { response in
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    self.view.hideToastActivity()
                    self.settingTableView.reloadData()
            }
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: metric, style: UIAlertActionStyle.Default, handler: selectMetric))
        alertController.addAction(UIAlertAction(title: imperial, style: UIAlertActionStyle.Default, handler: selectImperial))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func upgradeToCoach() {
        let alertController = UIAlertController(title: kApply, message: kWantToBecomeACoach, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: kContinue, style: .Default) { (action) in
            var prefix = kPMAPICOACH
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            
            self.performSegueWithIdentifier("upgradeCoach", sender: nil)
        }
        let cancelAction = UIAlertAction(title: kCancle, style: .Default) { (action) in
        }
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        

        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            if segue.identifier == "LocationPicker" {
                let locationPicker = segue.destinationViewController as! LocationPickerViewController
                locationPicker.location = self.location
                locationPicker.showCurrentLocationButton = true
                locationPicker.useCurrentLocationAsHint = true
                locationPicker.showCurrentLocationInitially = true
                locationPicker.mapType = .Standard
                
                let backItem = UIBarButtonItem()
                backItem.title = "BACK        "
                backItem.setTitleTextAttributes([NSFontAttributeName: UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], forState: .Normal)

                navigationItem.backBarButtonItem = backItem
                self.navigationController?.navigationBar.backIndicatorImage = UIImage()
                self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
    
                locationPicker.completion = {
                    if let placeMark = $0?.placemark {
                        // City
                        var city = "..."
                        if ((placeMark.administrativeArea) != nil) {
                            if placeMark.subAdministrativeArea != nil {
                                city = "\(placeMark.subAdministrativeArea!), \(placeMark.administrativeArea!)"
                            } else if placeMark.locality != nil {
                                city = "\(placeMark.locality!), \(placeMark.administrativeArea!)"
                            } else {
                                city = placeMark.administrativeArea!
                            }
                        }
                        
                        self.location = Location(name: city, location: $0?.location, placemark: placeMark)
                    }
                    
                    self.getCityStageOfUser((self.location?.coordinate.latitude)!, long: (self.location?.coordinate.longitude)!)
                }
        } else if (segue.identifier == "upgradeCoach") {
            self.backFromOther = true
            let destinationVC = segue.destinationViewController as! EditCoachProfileForUpgradeViewController
            destinationVC.userInfo = self.userInfo
            destinationVC.settingCV = self
        } else if (segue.identifier == "changePassword") {
            self.backFromOther = true
        }
    }
    
    func getCityStageOfUser(lat:CLLocationDegrees, long:CLLocationDegrees) {
        let latlngLocationString = String(format: "%f,%f", lat, long)
        
        let prefix = "http://maps.googleapis.com/maps/api/geocode/json"
        let param = ["latlng":latlngLocationString,
                     "sensor":"true",]
        
        Alamofire.request(.GET, prefix, parameters: param)
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    let googleMapJSON = JSON as! NSDictionary
                    let locationArr = ((googleMapJSON["results"] as! NSArray)[0]  as! NSDictionary)["address_components"]  as! NSArray
                    
                    var i = 0
                    while (i < locationArr.count) {
                        let dictionary = locationArr[i] as! NSDictionary
                        
                        let types = dictionary["types"] as! NSArray
                        var typeIndex = 0
                        var isAreaLevel1 = false
                        var isAreaLevel2 = false
                        while (typeIndex < types.count) {
                            let type = types[typeIndex]
                            
                            if type as! String == "administrative_area_level_1" {
                                isAreaLevel1 = true
                                break
                            } else if type as! String == "administrative_area_level_2" {
                                isAreaLevel2 = true
                                break
                            }
                            
                            typeIndex = typeIndex + 1;
                        }
                        
                        if isAreaLevel1 {
                            self.mapState = dictionary["short_name"] as! String
                        }
                        
                        if isAreaLevel2 {
                            self.mapCity = dictionary["short_name"] as! String
                        }
                        
                        i = i + 1;
                    }
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension UIApplication {
    
    class func appVersion() -> String {
        var appversion = "Pummel "
appversion.appendContentsOf(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String)
        return appversion
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        return version == build ? "\(version)" : "\(version)(\(build))"
    }
}
