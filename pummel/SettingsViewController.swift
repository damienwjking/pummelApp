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
    let knumberOfRowUser = 16
    
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
    }
    
    func done() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
            return knumberOfRowCoach
        } else {
            return knumberOfRowUser
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
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
            case 0, 1, 2, 4, 6, 8, 10, 12, 13, 14, 15:
                return 50
            case 3, 9:
                return cellHeight60
            case 5, 7, 11:
                return cellHeight10
            default:
                return cellHeight30
            }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
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
                cell.newConnectionsLB.text = kNewConnections
                return cell
            case 5:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kMessage
                return cell
            case 6:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kSessions
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
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kNewConnections
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kMessage
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNewConnectionsTableViewCell, forIndexPath: indexPath) as! SettingNewConnectionsTableViewCell
                cell.newConnectionsLB.font = .pmmMonReg11()
                cell.newConnectionsLB.text = kSessions
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kContactUs
                return cell
            case 4:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kHelpSupport
                return cell
            case 5, 7, 11:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingSmallSeperateTableViewCell, forIndexPath: indexPath) as! SettingSmallSeperateTableViewCell
                return cell
            case 6:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kFeedback
                return cell
            case 8:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kSharePummel
                return cell
            case 9:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingNotificationHeaderTableViewCell, forIndexPath: indexPath) as! SettingNotificationHeaderTableViewCell
                cell.notificationLB.font = .pmmMonReg11()
                cell.notificationLB.text = kLegal
                return cell
            case 10:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kPrivacy
                return cell
            case 12:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingHelpSupportTableViewCell, forIndexPath: indexPath) as! SettingHelpSupportTableViewCell
                cell.helpAndSupportLB.font = .pmmMonReg11()
                cell.helpAndSupportLB.text = kTermOfService
                return cell
            case 13:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingBigSeperateTableViewCell, forIndexPath: indexPath) as! SettingBigSeperateTableViewCell
                return cell
            case 14:
                let cell = tableView.dequeueReusableCellWithIdentifier(kSettingLogoutTableViewCell, forIndexPath: indexPath) as! SettingLogoutTableViewCell
                cell.logoutLB.font = .pmmMonReg11()
                return cell
            case 15:
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
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
            switch indexPath.row {
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
            case 4:
                self.sendSupportEmail()
            case 6:
                self.sendFeedbackEmail()
            case 8:
                self.sharePummel()
            case 10:
                self.openPrivacy()
            case 12:
                self.openTerms()
            case 14:
                self.logOut()
            default: break
            }
        }
       
    }
    
    func configLocationCell(cell: SettingLocationTableViewCell) {
        var prefix = kPMAPICOACH
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetailFull = JSON as! NSDictionary
                if !(userDetailFull[kServiceArea] is NSNull) {
                    cell.locationContentLB.text = userDetailFull[kServiceArea] as? String
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
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetailFull = JSON as! NSDictionary
                if !(userDetailFull[kDistance] is NSNull) {
                    var distance = String(format:"%0.f", userDetailFull[kDistance]!.doubleValue)
                    distance.appendContentsOf(" kms")
                    cell.maxDistanceContentLB.text = distance

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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
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
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(false, forKey: k_PM_IS_LOGINED)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
