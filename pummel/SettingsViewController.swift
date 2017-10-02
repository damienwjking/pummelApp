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

enum SettingCellIndex: Int {
    case unitOfMeasure_Title
    case unitOfMeasure_Value
    
    case discovery_Title
    case discovery_Location
    case discovery_Distance
    
    case fitnessProfessional_Title
    case fitnessProfessional_Message
    
    case applyNow_Button
    
    case notification_Title
    case notification_NewLead
    case notification_Message
    case notification_Session
    
    case contactUs_Title
    case contactUs_HelpSupport
    case contactUs_FeedBack
    case contactUs_SharePummel
    case contactUs_InviteFriend
    
    case legal_Title
    case legal_PrivacyPolicy
    case legal_TermService
    case legal_ChangePassword
    
    case logout_Button
    
    case pummel_Version
    
    case space_SmallSeparateLine
    case space_BigSeparateLine
}


class SettingsViewController: BaseViewController {

    @IBOutlet weak var settingTableView: UITableView!
   
    let cellHeight10 : CGFloat = 10
    let cellHeight30 : CGFloat = 30
    let cellHeight49 : CGFloat = 49
    let cellHeight50 : CGFloat = 50
    let cellHeight60 : CGFloat = 60
    let cellHeight71 : CGFloat = 71
    let cellHeight100 : CGFloat = 100
    
    let knumberOfRowCoach = 26
    let knumberOfRowUser = 25
    var userInfo: NSDictionary!
    
    var mapState = ""
    var mapCity = ""
    var distanceSliderValue : CGFloat = 0.0
    
    var settingCellArray : [SettingCellIndex] = []
    
    let defaults = UserDefaults.standard
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
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.isTranslucent = false;
       
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(SettingsViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], for: .normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        if self.defaults.object(forKey: kNewConnections) == nil {
            self.defaults.set(true, forKey: kNewConnections)
        }
        if self.defaults.object(forKey: kMessage) == nil {
            self.defaults.set(true, forKey: kMessage)
        }
        if self.defaults.object(forKey: kSessions) == nil {
            self.defaults.set(true, forKey: kSessions)
        }
        if self.defaults.object(forKey: kUnit) == nil {
            self.defaults.set(metric, forKey: kUnit)
        }
        
        self.getSettingCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingTableView.delegate = self
        settingTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated: animated)
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true && self.backFromOther == false) {
            let indexpath = NSIndexPath(forRow: 3, inSection: 0)
            let cellLocation = self.settingTableView.cellForRowAtIndexPath(indexpath) as? SettingLocationTableViewCell
            if (cellLocation != nil) {
                if self.location != nil {
                    if self.location?.name != cellLocation!.locationContentLB.text {
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
        }
        
        if (self.backFromOther == true) {
            self.backFromOther = false
        }
    }
    
    func getSettingCell() {
        self.settingCellArray.append(.unitOfMeasure_Title)
        self.settingCellArray.append(.unitOfMeasure_Value)
        
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            self.settingCellArray.append(.discovery_Title)
            self.settingCellArray.append(.discovery_Location)
            self.settingCellArray.append(.discovery_Distance)
        } else {
            self.settingCellArray.append(.fitnessProfessional_Title)
            self.settingCellArray.append(.fitnessProfessional_Message)
            
            self.settingCellArray.append(.applyNow_Button)
        }
        
        self.settingCellArray.append(.notification_Title)
        // Only show in coach
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            self.settingCellArray.append(.notification_NewLead)
        }
        
        self.settingCellArray.append(.notification_Message)
        self.settingCellArray.append(.notification_Session)
        self.settingCellArray.append(.contactUs_Title)
        self.settingCellArray.append(.contactUs_HelpSupport)
        self.settingCellArray.append(.space_SmallSeparateLine)
        self.settingCellArray.append(.contactUs_FeedBack)
        self.settingCellArray.append(.space_SmallSeparateLine)
        self.settingCellArray.append(.contactUs_SharePummel)
        self.settingCellArray.append(.space_SmallSeparateLine)
        self.settingCellArray.append(.contactUs_InviteFriend)
        self.settingCellArray.append(.legal_Title)
        self.settingCellArray.append(.legal_PrivacyPolicy)
        self.settingCellArray.append(.space_SmallSeparateLine)
        self.settingCellArray.append(.legal_TermService)
        self.settingCellArray.append(.space_SmallSeparateLine)
        self.settingCellArray.append(.legal_ChangePassword)
        self.settingCellArray.append(.space_BigSeparateLine)
        self.settingCellArray.append(.logout_Button)
        self.settingCellArray.append(.pummel_Version)
    }

    func updateLocationCoach() {
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            var prefix = kPMAPICOACH
            prefix.append(PMHelper.getCurrentID())
            
            var locationName = ""
            if (self.location?.name?.isEmpty == false) {
                locationName = (self.location?.name)!
            }
            
            let param = [kUserId:PMHelper.getCurrentID(),
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
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            self.defaults.set(self.newLeadCell.switchBT.on, forKey: kNewConnections)
            self.defaults.set(self.messageCell.switchBT.on, forKey: kMessage)
            self.defaults.set(self.sessionCell.switchBT.on, forKey: kSessions)
            
            var prefix = kPMAPICOACH
            prefix.append(PMHelper.getCurrentID())
            
            self.view.makeToastActivity(message: "Saving")
            
            let param = [kUserId:PMHelper.getCurrentID(),
                         kDistance: self.distanceSliderValue,
                         kState: self.mapState,
                         kCity: self.mapCity]
            
            Alamofire.request(.PUT, prefix, parameters: param as? [String : AnyObject])
                .responseJSON { response in switch response.result {
                case .Success(_):
                    var prefixUser = kPMAPIUSER
                    prefixUser.append(PMHelper.getCurrentID())
                    prefixUser.append("/notification")
                    
                    let paramUser = [kUserId:PMHelper.getCurrentID(),
                        "messageNotification": self.messageCell.switchBT.on ? "1" : "0",
                        "newleadNotification": self.newLeadCell.switchBT.on ? "1" : "0",
                        "sessionNotification": self.sessionCell.switchBT.on ? "1" : "0"]
                    
                    Alamofire.request(.PUT, prefixUser, parameters: paramUser)
                        .responseJSON { response in
                            self.navigationController?.popViewController(animated: true)
                            self.view.hideToastActivity()
                    }
                case .Failure(let error):
                    print(error)
                    self.navigationController?.popViewController(animated: true)
                    self.view.hideToastActivity()
                    }
            }
        } else {
            self.defaults.set(self.messageCell.switchBT.on, forKey: kMessage)
            self.defaults.set(self.sessionCell.switchBT.on, forKey: kSessions)
            
            self.view.makeToastActivity(message: "Saving")
            
            var prefixUser = kPMAPIUSER
            prefixUser.append(PMHelper.getCurrentID())
            prefixUser.append("/notification")
            
            let paramUser = [kUserId:PMHelper.getCurrentID(),
                             "messageNotification": self.messageCell.switchBT.on ? "1" : "0",
                             "sessionNotification": self.sessionCell.switchBT.on ? "1" : "0"]
            
            Alamofire.request(.PUT, prefixUser, parameters: paramUser)
                .responseJSON { response in
                    self.navigationController?.popViewController(animated: true)
                    self.view.hideToastActivity()
            }
        }
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Save Setting"]
        mixpanel.track("IOS.Profile.Setting", properties: properties)
    }
    
    func sliderValueDidChange(sender:UISlider!) {
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            let indexpath = NSIndexPath(forRow: 4, inSection: 0)
            let cellDistance = self.settingTableView.cellForRowAtIndexPath(indexpath) as! SettingMaxDistanceTableViewCell
            var value = String(format:"%0.f", sender.value)
            value.append(" kms")
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
            self.present(mailComposerVC, animated: true, completion: nil)
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
            self.present(mailComposerVC, animated: true, completion: nil)
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
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func openPrivacy() {
        let alertController = UIAlertController(title: pmmNotice, message: openLink, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
            UIApplication.sharedApplication().openURL(NSURL(string: kPM_PRIVACY)!)
        }
        alertController.addAction(OKAction)
        alertController.addAction(UIAlertAction(title: kCancle, style: .default, handler: nil))
        self.present(alertController, animated: true) {}
    }
    
    func openTerms() {
        let alertController = UIAlertController(title: pmmNotice, message: openLink, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
             UIApplication.sharedApplication().openURL(NSURL(string: kPM_TERM)!)
        }
        alertController.addAction(OKAction)
        alertController.addAction(UIAlertAction(title: kCancle, style: .default, handler: nil))
        self.present(alertController, animated: true) {}
    }
    
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: pmmNotice, message: couldNotSendEmailAlert, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: kCancle, style: .default, handler: nil))
        self.present(alertController, animated: true) { }
    }
    
    func logOut() {
        self.view.makeToastActivity(message: "Logging Out")
        UserDefaults.standard.setInteger(0, forKey: "MESSAGE_BADGE_VALUE")
        Alamofire.request(.DELETE, kPMAPI_LOGOUT).response { (req, res, data, error) -> Void in
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            print(res)
            self.view.hideToastActivity()
            
            let outputString = NSString(data: data!, encoding:NSUTF8StringEncoding)
            if ((outputString?.containsString(kLogoutSuccess)) != nil) {
                self.defaults.set(false, forKey: k_PM_IS_LOGINED)
                self.defaults.set(false, forKey: k_PM_IS_COACH)
                let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for cookie in storage.cookies! {
                    Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.deleteCookie(cookie)
                    storage.deleteCookie(cookie)
                }
                UserDefaults.standard.synchronize()
                
                self.performSegue(withIdentifier: "backToRegister", sender: nil)
            } else {
                let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true) {
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
        
        let alertController = UIAlertController(title: nil, message: kMessConfirmLogout, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log out", style: UIAlertActionStyle.destructive, handler: confirmLogout))
        alertController.addAction(UIAlertAction(title: kCancle, style: .default, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    func selectMeasure() {
        let selectMetric = { (action:UIAlertAction!) -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.view.makeToastActivity(message: "Saving")
            
            self.defaults.set(metric, forKey: kUnit)
            
            var prefix = kPMAPIUSER
            prefix.append(PMHelper.getCurrentID())
            
            let param = [kUserId:PMHelper.getCurrentID(),
                         kFirstname:self.defaults.object(forKey: kFirstname) as! String,
                         kUnits: metric]
            
            Alamofire.request(.PUT, prefix, parameters: param)
                .responseJSON { response in
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    self.view.hideToastActivity()
                    self.settingTableView.reloadData()
            }
        }
        
        let selectImperial = { (action:UIAlertAction!) -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.view.makeToastActivity(message: "Saving")
            
            self.defaults.set(imperial, forKey: kUnit)
            
            var prefix = kPMAPIUSER
            prefix.append(PMHelper.getCurrentID())
            
            let param = [kUserId:PMHelper.getCurrentID(),
                         kFirstname:self.defaults.object(forKey: kFirstname) as! String,
                         kUnits: imperial]
            
            Alamofire.request(.PUT, prefix, parameters: param)
                .responseJSON { response in
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    self.view.hideToastActivity()
                    self.settingTableView.reloadData()
            }
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: metric, style: .default, handler: selectMetric))
        alertController.addAction(UIAlertAction(title: imperial, style: .default, handler: selectImperial))
        
        self.present(alertController, animated: true) { }
    }
    
    func upgradeToCoach() {
        let alertController = UIAlertController(title: kApply, message: kWantToBecomeACoach, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: kContinue, style: .default) { (action) in
            var prefix = kPMAPICOACH
            prefix.append(PMHelper.getCurrentID())
            
            self.performSegue(withIdentifier: "upgradeCoach", sender: nil)
        }
        let cancelAction = UIAlertAction(title: kCancle, style: .default) { (action) in
        }
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        

        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            if segue.identifier == "LocationPicker" {
                let locationPicker = segue.destination as! LocationPickerViewController
                locationPicker.location = self.location
                locationPicker.showCurrentLocationButton = true
                locationPicker.useCurrentLocationAsHint = true
                locationPicker.showCurrentLocationInitially = true
                locationPicker.mapType = .Standard
                
                let backItem = UIBarButtonItem()
                backItem.title = "BACK        "
                backItem.setTitleTextAttributes([NSFontAttributeName: UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], for: .normal)

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
            let destinationVC = segue.destination as! EditCoachProfileForUpgradeViewController
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
        self.dismissViewControllerAnimated(animated: true, completion: nil)
    }
}

extension UIApplication {
    
    class func appVersion() -> String {
        var appversion = "Pummel "
appversion.append(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String)
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingCellArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        switch self.settingCellArray[indexPath.row] {
        case .discovery_Title:
            return cellHeight49
            
        case .unitOfMeasure_Title,
             .unitOfMeasure_Value,
             .fitnessProfessional_Title,
             .fitnessProfessional_Message,
             .notification_Title,
             .contactUs_Title,
             .legal_Title:
            return cellHeight60
            
        case .discovery_Location:
            return cellHeight71
            
        case .discovery_Distance:
            return cellHeight100
            
        case .space_SmallSeparateLine:
            return cellHeight10
            
        default:
            return cellHeight50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.settingCellArray[indexPath.row] {
        case .unitOfMeasure_Title:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingNotificationHeaderTableViewCell, for: indexPath) as! SettingNotificationHeaderTableViewCell
            cell.notificationLB.font = .pmmMonReg11()
            cell.notificationLB.text = kUnitMeasure
            return cell
        case .unitOfMeasure_Value:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = self.defaults.object(forKey: kUnit) as? String
            return cell
            
        case .discovery_Title:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingDiscoveryHeaderTableViewCell, for: indexPath) as! SettingDiscoveryHeaderTableViewCell
            cell.discoveryLB.font = .pmmMonReg11()
            return cell
        case .discovery_Location:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingLocationTableViewCell, for: indexPath) as! SettingLocationTableViewCell
            cell.locationLB.font = .pmmMonReg11()
            cell.myCurrentLocationLB.font = .pmmMonReg11()
            cell.locationContentLB.font = .pmmMonReg11()
            self.configLocationCell(cell)
            return cell
        case .discovery_Distance:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingMaxDistanceTableViewCell, for: indexPath) as! SettingMaxDistanceTableViewCell
            cell.maxDistanceLB.font = .pmmMonReg11()
            cell.maxDistanceContentLB.font = .pmmMonReg11()
            cell.slider.maximumValue = 50
            cell.slider.minimumValue = 0
            self.configDistanceCell(cell)
            return cell
            
        case .fitnessProfessional_Title:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingNotificationHeaderTableViewCell, for: indexPath) as! SettingNotificationHeaderTableViewCell
            cell.notificationLB.font = .pmmMonReg11()
            cell.notificationLB.text = kIAmFitnessProfessional
            return cell
        case .fitnessProfessional_Message:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.selectionStyle = .None
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = kVerifiedFitnessProfessional
            return cell
            
        case .applyNow_Button:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.textColor = .pmmBrightOrangeColor()
            cell.helpAndSupportLB.text = kApplyNow
            return cell
            
        case .notification_Title:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingNotificationHeaderTableViewCell, for: indexPath) as! SettingNotificationHeaderTableViewCell
            cell.notificationLB.font = .pmmMonReg11()
            cell.notificationLB.text = kNotification
            return cell
        case .notification_NewLead:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingNewConnectionsTableViewCell, for: indexPath) as! SettingNewConnectionsTableViewCell
            cell.newConnectionsLB.font = .pmmMonReg11()
            cell.newConnectionsLB.text = kNewConnections.uppercased()
            cell.switchBT.on = self.defaults.object(forKey: kNewConnections) as! Bool
            self.newLeadCell = cell
            return cell
        case .notification_Message:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingNewConnectionsTableViewCell, for: indexPath) as! SettingNewConnectionsTableViewCell
            cell.newConnectionsLB.font = .pmmMonReg11()
            cell.newConnectionsLB.text = kMessage
            cell.switchBT.on = self.defaults.object(forKey: kMessage) as! Bool
            self.messageCell = cell
            return cell
        case .notification_Session:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingNewConnectionsTableViewCell, for: indexPath) as! SettingNewConnectionsTableViewCell
            cell.newConnectionsLB.font = .pmmMonReg11()
            cell.newConnectionsLB.text = kSessions
            cell.switchBT.on = self.defaults.object(forKey: kSessions) as! Bool
            self.sessionCell = cell
            return cell
            
        case .contactUs_Title:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingNotificationHeaderTableViewCell, for: indexPath) as! SettingNotificationHeaderTableViewCell
            cell.notificationLB.font = .pmmMonReg11()
            cell.notificationLB.text = kContactUs
            return cell
        case .contactUs_HelpSupport:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = kHelpSupport
            return cell
        case .contactUs_FeedBack:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = kFeedback
            return cell
        case .contactUs_SharePummel:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = kSharePummel
            return cell
        case .contactUs_InviteFriend:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = kInviteFriend
            return cell
            
        case .legal_Title:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingNotificationHeaderTableViewCell, for: indexPath) as! SettingNotificationHeaderTableViewCell
            cell.notificationLB.font = .pmmMonReg11()
            cell.notificationLB.text = kLegal
            return cell
        case .legal_PrivacyPolicy:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = kPrivacy
            return cell
        case .legal_TermService:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = kTermOfService
            return cell
        case .legal_ChangePassword:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = kChangePassword
            return cell
            
        case .logout_Button:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingLogoutTableViewCell, for: indexPath) as! SettingLogoutTableViewCell
            cell.logoutLB.font = .pmmMonReg11()
            return cell
            
        case .pummel_Version:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingHelpSupportTableViewCell, for: indexPath) as! SettingHelpSupportTableViewCell
            cell.helpAndSupportLB.font = .pmmMonReg11()
            cell.helpAndSupportLB.textColor = UIColor.black
            cell.helpAndSupportLB.text = UIApplication.versionBuild()
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
            cell.selectionStyle = .None
            return cell
            
        case .space_SmallSeparateLine:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingSmallSeperateTableViewCell, for: indexPath) as! SettingSmallSeperateTableViewCell
            return cell
            
        case .space_BigSeparateLine:
            let cell = tableView.dequeueReusableCell(withIdentifier: kSettingSmallSeperateTableViewCell, for: indexPath) as! SettingSmallSeperateTableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        
        switch self.settingCellArray[indexPath.row] {
        case .unitOfMeasure_Value:
            self.selectMeasure()
            
        case .discovery_Location:
            self.performSegue(withIdentifier: "LocationPicker", sender: nil)
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Navigation Click", "Label":"Go Set Location"]
            mixpanel.track("IOS.Profile.Setting", properties: properties)
            
        case .applyNow_Button:
            self.upgradeToCoach()
            
        case .contactUs_HelpSupport:
            self.sendSupportEmail()
        case .contactUs_FeedBack:
            self.sendFeedbackEmail()
        case .contactUs_SharePummel:
            self.sharePummel()
        case .contactUs_InviteFriend:
            self.inviteFriend()
            
        case .legal_PrivacyPolicy:
            self.openPrivacy()
        case .legal_TermService:
            self.openTerms()
        case .legal_ChangePassword:
            self.performSegue(withIdentifier: "changePassword", sender: nil)
            
        case .logout_Button:
            self.showMsgConfirmLogout()
            
        default: break
        }
    }
    
    func configLocationCell(cell: SettingLocationTableViewCell) {
        var prefix = kPMAPICOACH
        prefix.append(PMHelper.getCurrentID())
        
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
        prefix.append(PMHelper.getCurrentID())
        
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetailFull = JSON as! NSDictionary
                if !(userDetailFull[kDistance] is NSNull) {
                    var distance = String(format:"%0.f", userDetailFull[kDistance]!.doubleValue)
                    distance.append(" kms")
                    cell.maxDistanceContentLB.text = distance
                    cell.slider.value = userDetailFull[kDistance] as! Float
                    self.distanceSliderValue = userDetailFull[kDistance] as! CGFloat
                } else {
                    cell.maxDistanceContentLB.text = k25kms
                    self.distanceSliderValue = 25.0
                    cell.slider.value = 25.0
                }
                cell.slider.addTarget(self, action:#selector(SettingsViewController.sliderValueDidChange), for: .valueChanged)
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func inviteFriend() {
        let inviteSMSAction = UIAlertAction(title: kInviteSMS, style: .Destructive) { (_) in
            if MFMessageComposeViewController.canSendText() {
                let messageCompose = MFMessageComposeViewController()
                messageCompose.body = kMessageInviteContactSetting
                
                messageCompose.messageComposeDelegate = self
                self.present(messageCompose, animated: true, completion: nil)
            }
        }
        
        let inviteMailAction = UIAlertAction(title: kInviteEmail, style: .Destructive) { (_) in
            var urlString = "mailto:"
            urlString = urlString.stringByAppendingString("")
            
            urlString = urlString.stringByAppendingString("?subject=")
            urlString = urlString.stringByAppendingString("Pummel%20Fitness%20App")
            
            urlString = urlString.stringByAppendingString("&body=")
            urlString = urlString.stringByAppendingString("Check%20out%20this%20Pummel%20Fitness%20App,%20think%20it%20will%20be%20great%20for%20you.%20Helps%20you%20find%20personal%20trainers%20and%20fitness%20experts%20in%20your%20area.%20Connect,%20message%20and%20track%20workouts.%0A%0ADownload%20here%20http://get.pummel.fit")
            
            let mailURL = NSURL(string: urlString)
            if (UIApplication.sharedApplication().canOpenURL(mailURL!)) {
                UIApplication.sharedApplication().openURL(mailURL!)
            }
        }
        
        let cancelAction = UIAlertAction(title: kCancle, style: .Cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(inviteSMSAction)
        alertController.addAction(inviteMailAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension SettingsViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(animated: true, completion: nil)
    }
}
