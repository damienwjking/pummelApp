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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var settingTableView: UITableView!
   
    let cellHeight10 : CGFloat = 10
    let cellHeight30 : CGFloat = 30
    let cellHeight49 : CGFloat = 49
    let cellHeight50 : CGFloat = 50
    let cellHeight60 : CGFloat = 60
    let cellHeight71 : CGFloat = 71
    let cellHeight100 : CGFloat = 100
    
    let knumberOfRowCoach = 20
    let knumberOfRowUser = 19
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var location: Location? {
        didSet {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kNavSetting
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.translucent = false;
        settingTableView.delegate = self
        settingTableView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: kDone, style: .Plain, target: self, action: #selector(SettingsViewController.done))
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
    }
    
    override func viewDidAppear(animated: Bool) {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            let indexpath = NSIndexPath(forRow: 1, inSection: 0)
            let cellLocation = self.settingTableView.cellForRowAtIndexPath(indexpath) as! SettingLocationTableViewCell
            if self.location != nil {
                if self.location?.name != cellLocation.locationContentLB.text {
                    self.showMsgConfirmUpdateLocation()
                }
            }
            
        }
    }
    
    func showMsgConfirmUpdateLocation() {
        let alertController = UIAlertController(title: pmmNotice, message: confirmChangedLocation, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
            let indexpath = NSIndexPath(forRow: 1, inSection: 0)
            let cellLocation = self.settingTableView.cellForRowAtIndexPath(indexpath) as! SettingLocationTableViewCell
            cellLocation.locationContentLB.text = self.location?.name
            self.updateLocationCoach()
        }
        let CancelAction = UIAlertAction(title: kCancle, style: .Default) { (action) in
        }
        alertController.addAction(OKAction)
        alertController.addAction(CancelAction)
        self.presentViewController(alertController, animated: true) {
        }
    }
    
    func updateLocationCoach() {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            var prefix = kPMAPICOACH
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            Alamofire.request(.PUT, prefix, parameters: [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, kServiceArea:(self.location?.name)!, kLat:(self.location?.coordinate.latitude)!, kLong:(self.location?.coordinate.longitude)!])
                .responseJSON { response in switch response.result {
                case .Success(_): break
                    
                case .Failure(let error):
                    print(error)
                    }
            }
        }
    }
    
    func done() {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            let indexpath = NSIndexPath(forRow: 2, inSection: 0)
            let cellDistance = self.settingTableView.cellForRowAtIndexPath(indexpath) as! SettingMaxDistanceTableViewCell
            
            var prefix = kPMAPICOACH
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            Alamofire.request(.PUT, prefix, parameters: [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String,
                kDistance: cellDistance.slider.value])
                .responseJSON { response in switch response.result {
                case .Success(_):
                    self.navigationController?.popViewControllerAnimated(true)
                    
                case .Failure(let error):
                    print(error)
                    self.navigationController?.popViewControllerAnimated(true)
                    }
            }
            
            let newLeadIndexPath = NSIndexPath(forRow: 4, inSection: 0)
            let newLeadCell = self.settingTableView.cellForRowAtIndexPath(newLeadIndexPath) as! SettingNewConnectionsTableViewCell
            
            let messageIndexPath = NSIndexPath(forRow: 5, inSection: 0)
            let messageCell = self.settingTableView.cellForRowAtIndexPath(messageIndexPath) as! SettingNewConnectionsTableViewCell
            
            let sessionIndexPath = NSIndexPath(forRow: 6, inSection: 0)
            let sessionCell = self.settingTableView.cellForRowAtIndexPath(sessionIndexPath) as! SettingNewConnectionsTableViewCell
            
            self.defaults.setObject(newLeadCell.switchBT.on, forKey: kNewConnections)
            self.defaults.setObject(messageCell.switchBT.on, forKey: kMessage)
            self.defaults.setObject(sessionCell.switchBT.on, forKey: kSessions)
        } else {
            let newLeadIndexPath = NSIndexPath(forRow: 3, inSection: 0)
            let newLeadCell = self.settingTableView.cellForRowAtIndexPath(newLeadIndexPath) as! SettingNewConnectionsTableViewCell
            
            let messageIndexPath = NSIndexPath(forRow: 4, inSection: 0)
            let messageCell = self.settingTableView.cellForRowAtIndexPath(messageIndexPath) as! SettingNewConnectionsTableViewCell
            
            let sessionIndexPath = NSIndexPath(forRow: 5, inSection: 0)
            let sessionCell = self.settingTableView.cellForRowAtIndexPath(sessionIndexPath) as! SettingNewConnectionsTableViewCell
            
            self.defaults.setObject(newLeadCell.switchBT.on, forKey: kNewConnections)
            self.defaults.setObject(messageCell.switchBT.on, forKey: kMessage)
            self.defaults.setObject(sessionCell.switchBT.on, forKey: kSessions)
            
            self.navigationController?.popViewControllerAnimated(true)
        }
        
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
            case 0:
                return cellHeight49
            case 1:
                return cellHeight71
            case 2:
                return 100
            case 3, 7, 13, 17:
                return cellHeight60
            case 4, 5, 6, 8, 10, 12, 14, 16, 18, 19:
                return cellHeight50
            case 9, 11, 15:
                return cellHeight10
            default:
                return cellHeight30
            }
        } else {
            switch indexPath.row {
            case 1, 3, 4, 5, 7, 9, 11, 13, 15, 16, 17, 18:
                return 50
            case 0, 2, 6, 12:
                return cellHeight60
            case 9, 10, 14:
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
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingDiscoveryHeaderTableViewCell, forIndexPath: indexPath) as! SettingDiscoveryHeaderTableViewCell
                    cell.discoveryLB.font = .pmmMonReg11()
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingLocationTableViewCell, forIndexPath: indexPath) as! SettingLocationTableViewCell
                cell.locationLB.font = .pmmMonReg11()
                cell.myCurrentLocationLB.font = .pmmMonReg11()
                cell.locationContentLB.font = .pmmMonReg11()
                self.configLocationCell(cell)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingMaxDistanceTableViewCell, forIndexPath: indexPath) as! SettingMaxDistanceTableViewCell
                cell.maxDistanceLB.font = .pmmMonReg11()
                cell.maxDistanceContentLB.font = .pmmMonReg11()
                cell.slider.maximumValue = 50
                cell.slider.minimumValue = 0
                self.configDistanceCell(cell)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kNotification
                return cell
            case 4:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kNewConnections.uppercaseString
                cell.switchBT.on = self.defaults.objectForKey(kNewConnections) as! Bool
                return cell
            case 5:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kMessage
                cell.switchBT.on = self.defaults.objectForKey(kMessage) as! Bool
                return cell
            case 6:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kSessions
                cell.switchBT.on = self.defaults.objectForKey(kSessions) as! Bool
                return cell
            case 7:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kContactUs
                return cell
            case 8:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kHelpSupport
                return cell
            case 9, 11, 15:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingSmallSeperateTableViewCell, forIndexPath: indexPath) as! SettingSmallSeperateTableViewCell
                return cell
            case 10:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kFeedback
                return cell
            case 12:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kSharePummel
                return cell
            case 13:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kLegal
                return cell
            case 14:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kPrivacy
                return cell
            case 16:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kTermOfService
                return cell
            case 18:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingLogoutTableViewCell, forIndexPath: indexPath) as! SettingLogoutTableViewCell
                cell.logoutLB.font = .pmmMonReg11()
                return cell
            case 19:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = UIApplication.versionBuild()
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
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
                cell.notificationLB.text = kBeccomeATrainer
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kRequestToUpgrade
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kNotification
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kNewConnections.uppercaseString
                cell.switchBT.on = self.defaults.objectForKey(kNewConnections) as! Bool
                return cell
            case 4:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kMessage
                cell.switchBT.on = self.defaults.objectForKey(kMessage) as! Bool
                return cell
            case 5:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kSessions
                cell.switchBT.on = self.defaults.objectForKey(kSessions) as! Bool
                return cell
            case 6:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kContactUs
                return cell
            case 7:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kHelpSupport
                return cell
            case 8, 10, 14:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingSmallSeperateTableViewCell, forIndexPath: indexPath) as! SettingSmallSeperateTableViewCell
                return cell
            case 9:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kFeedback
                return cell
            case 11:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kSharePummel
                return cell
            case 12:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kLegal
                return cell
            case 13:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kPrivacy
                return cell
            case 15:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kTermOfService
                return cell
            case 16:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingBigSeperateTableViewCell, forIndexPath: indexPath) as! SettingBigSeperateTableViewCell
                return cell
            case 17:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingLogoutTableViewCell, forIndexPath: indexPath) as! SettingLogoutTableViewCell
                cell.logoutLB.font = .pmmMonReg11()
                return cell
            case 18:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = UIApplication.versionBuild()
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
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
                self.performSegueWithIdentifier("LocationPicker", sender: nil)
            case 8:
                self.sendSupportEmail()
            case 10:
                self.sendFeedbackEmail()
            case 12:
                self.sharePummel()
            case 14:
                self.openPrivacy()
            case 16:
                self.openTerms()
            case 18:
                self.logOut()
            default: break
            }
        } else {
            switch indexPath.row {
            case 1:
                self.upgradeToCoach()
            case 7:
                self.sendSupportEmail()
            case 9:
                self.sendFeedbackEmail()
            case 11:
                self.sharePummel()
            case 13:
                self.openPrivacy()
            case 15:
                self.openTerms()
            case 17:
                self.logOut()
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
                } else {
                     cell.maxDistanceContentLB.text = k25kms
                     cell.slider.value = 25
                }
                cell.slider.addTarget(self, action:#selector(SettingsViewController.sliderValueDidChange), forControlEvents: .ValueChanged)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func sliderValueDidChange(sender:UISlider!)
    {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            let indexpath = NSIndexPath(forRow: 2, inSection: 0)
            let cellDistance = self.settingTableView.cellForRowAtIndexPath(indexpath) as! SettingMaxDistanceTableViewCell
            var value = String(format:"%0.f", sender.value)
            value.appendContentsOf(" kms")
            cellDistance.maxDistanceContentLB.text = value
        }
    }
    
    func sendSupportEmail() {
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
        self.shareTextImageAndURL(pummelSlogan, sharingImage: UIImage(named: "pummelLogo.png"), sharingURL: NSURL.init(string: kPM))
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
        UIApplication.sharedApplication().openURL(NSURL(string: kPM_PRIVACY)!)
    }
    
    func openTerms() {
        UIApplication.sharedApplication().openURL(NSURL(string: kPM_TERM)!)
    }
    
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: pmmNotice, message: couldNotSendEmailAlert, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true) { }
    }
    
    func logOut() {
        Alamofire.request(.DELETE, kPMAPI_LOGOUT).response { (req, res, data, error) -> Void in
            print(res)
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
    }
    
    func upgradeToCoach() {
        let alertController = UIAlertController(title: pmmNotice, message: kWantToBecomeACoach, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
            var prefix = kPMAPICOACH
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            Alamofire.request(.PUT, prefix, parameters: [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String])
                .responseJSON { response in switch response.result {
                case .Success(_):
                    self.defaults.setBool(true, forKey: k_PM_IS_COACH)
                    self.settingTableView.reloadData()
                    let alertControllerSuccess = UIAlertController(title: pmmNotice, message: kBecomeACoachSuccess, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                    }
                    alertControllerSuccess.addAction(OKAction)
                    
                    self.presentViewController(alertControllerSuccess, animated: true) {
                        // ...
                    }
                case .Failure(_): break
                }
            }
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
    
                locationPicker.completion = { self.location = $0 }
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
