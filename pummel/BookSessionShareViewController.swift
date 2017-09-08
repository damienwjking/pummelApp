//
//  BookSessionShareViewController.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class BookSessionShareViewController: BaseViewController, GroupLeadTableViewCellDelegate, LeadAddedTableViewCellDelegate {

    @IBOutlet weak var tbView: UITableView!
    var image:UIImage?
    var tag:Tag?
    var textToPost = ""
    var dateToPost = ""
    var userIdSelected = ""
    let defaults = NSUserDefaults.standardUserDefaults()
    var forceUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BookSessionViewController.cancel))
        
        // TODO: add right invite button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kInvite.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.invite))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        let nibName = UINib(nibName: "GroupLeadTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName, forCellReuseIdentifier: "GroupLeadTableViewCell")
        
        let nibName2 = UINib(nibName: "LeadAddedTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName2, forCellReuseIdentifier: "LeadAddedTableViewCell")
        self.tbView.allowsSelection = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kClients.uppercaseString
        
        self.resetLBadge()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func invite() {
        let inviteSMSAction = UIAlertAction(title: kInviteSMS, style: .Destructive) { (_) in
            self.performSegueWithIdentifier("inviteContactUser", sender: kSMS)
        }
        
        let inviteMailAction = UIAlertAction(title: kInviteEmail, style: .Destructive) { (_) in
            self.performSegueWithIdentifier("inviteContactUser", sender: kEmail)
        }
        
        let cancelAction = UIAlertAction(title: kCancle, style: .Cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(inviteSMSAction)
        alertController.addAction(inviteMailAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func selectUserWithID(userId: String, typeGroup: Int) {
        self.view.makeToastActivity()
        
        UserRouter.getUserInfo(userID: userId) { (result, error) in
            self.view.hideToastActivity()
            
            if (error == nil) {
                let userInfo = result as! NSDictionary
                
                if typeGroup == TypeGroup.Current.rawValue {
                    self.showAlertMovetoOldAction(userInfo)
                } else {
                    self.showAlertMovetoCurrentAction(userInfo, typeGroup: typeGroup)
                }
            } else {
                print("Request failed with error: \(error)")
            }
            }.fetchdata()
    }
    
    func removeUserWithID(userId:String) {
        userIdSelected = ""
        self.tbView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kGoUserProfile {
            let destination = segue.destinationViewController as! UserProfileViewController
//            let feed = arrayFeeds[sender.tag]
//            currentFeedDetail = feed[kUser] as! NSDictionary
//            destination.userDetail = currentFeedDetail
            destination.userId = String(format:"%0.f", sender!.doubleValue)
        } else if (segue.identifier == "inviteContactUser") {
            let destination = segue.destinationViewController as! ContactUserViewController
            
            let styleInvite = sender as! String
            destination.styleInvite = styleInvite
        }
    }
}

//MARK: TableView
extension BookSessionShareViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupLeadTableViewCell") as! GroupLeadTableViewCell
        if indexPath.row == 0 {
            cell.titleHeader.text = "NEW LEADS"
            cell.typeGroup = TypeGroup.NewLead
        } else if indexPath.row == 1 {
            cell.titleHeader.text = "EXISTING CLIENTS"
            cell.typeGroup = TypeGroup.Current
        } else if indexPath.row == 2 {
            cell.titleHeader.text = "PAST CLIENTS"
            cell.typeGroup = TypeGroup.Old
        }
        cell.userIdSelected = self.userIdSelected
        cell.delegateGroupLeadTableViewCell = self
        if cell.arrayMessages.count <= 0 || self.forceUpdate == true {
            cell.getMessage()
        } else {
            cell.cv.reloadData()
        }
        return cell
    }
}

extension BookSessionShareViewController {
    func showAlertMovetoOldAction(userInfo:NSDictionary) {
        let userID = String(format:"%0.f", userInfo[kId]!.doubleValue)
        
        let clickMoveToOld = { (action:UIAlertAction!) -> Void in
            var prefix = kPMAPICOACHES
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPMAPICOACH_OLD)
            prefix.appendContentsOf("/")
            Alamofire.request(.PUT, prefix, parameters: [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, kUserIdRequest:userID])
                .responseJSON { response in
                    self.view.hideToastActivity()
                    if response.response?.statusCode == 200 {
                        self.forceUpdate = true
                        self.tbView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 0),NSIndexPath(forItem: 2, inSection: 0)], withRowAnimation: .None)
                        self.forceUpdate = false
                    }
            }
        }
        
        // Email action
        let userMail = userInfo[kEmail] as! String
        let emailClientAction = { (action:UIAlertAction!) -> Void in
            UserRouter.getCurrentUserInfo(completed: { (result, error) in
                if (error == nil) {
                    let currentInfo = result as! NSDictionary
                    let currentMail = currentInfo[kEmail] as! String
                    let coachFirstName = currentInfo[kFirstname] as! String
                    let userFirstName = userInfo[kFirstname] as! String
                    
//                    if MFMailComposeViewController.canSendMail() {
//                        let mail = MFMailComposeViewController()
//                        mail.mailComposeDelegate = self
//                        mail.setToRecipients(["hello@pummel.fit"])
//                        mail.setMessageBody("Hey \(userFirstName),\n\nCome join me on the Pummel Fitness app, where we can book appointments, log workouts, save transformation photos and chat for free.\n\nDownload the app at http://get.pummel.fit\n\nThanks,\n\nCoach\n\(coachFirstName)", isHTML: true)
//                        mail.setSubject("Come join me on Pummel Fitness")
//                        self.presentViewController(mail, animated: true, completion: nil)
//                    }
                    
                    var urlString = "mailto:"
                    urlString = urlString.stringByAppendingString(userMail)
                    
                    urlString = urlString.stringByAppendingString("?subject=")
                    urlString = urlString.stringByAppendingString("Come%20join%20me%20on%20Pummel%20Fitness")
                    
                    urlString = urlString.stringByAppendingString("&from=")
                    urlString = urlString.stringByAppendingString(currentMail)
                    
                    urlString = urlString.stringByAppendingString("&body=")
                    urlString = urlString.stringByAppendingString("Hey%20\(userFirstName),%0A%0ACome%20join%20me%20on%20the%20Pummel%20Fitness%20app,%20where%20we%20can%20book%20appointments,%20log%20workouts,%20save%20transformation%20photos%20and%20chat%20for%20free.%0A%0ADownload%20the%20app%20at%20http://get.pummel.fit%0A%0AThanks,%0A%0ACoach%0A\(coachFirstName)")
                    
                    let mailURL = NSURL(string: urlString)
                    if (UIApplication.sharedApplication().canOpenURL(mailURL!)) {
                        UIApplication.sharedApplication().openURL(mailURL!)
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
        
        // Call action
        let phoneNumber = userInfo[kMobile] as! String
        let callClientAction = { (action:UIAlertAction!) -> Void in
            var urlString = "tel:///"
            urlString = urlString.stringByAppendingString(phoneNumber)
            
            let tellURL = NSURL(string: urlString)
            if (UIApplication.sharedApplication().canOpenURL(tellURL!)) {
                UIApplication.sharedApplication().openURL(tellURL!)
            }
        }
        
        // Send message action
        let sendMessageClientAction = { (action:UIAlertAction!) -> Void in
            // Special case: can not call tabbarviewcontroller
            NSUserDefaults.standardUserDefaults().setObject(k_PM_MOVE_SCREEN_MESSAGE_DETAIL, forKey: k_PM_MOVE_SCREEN)
            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: k_PM_MOVE_SCREEN_MESSAGE_DETAIL)
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        let viewProfileAction = { (action:UIAlertAction!) -> Void in
            self.performSegueWithIdentifier(kGoUserProfile, sender:userID)
            
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        
        
        alertController.addAction(UIAlertAction(title: kViewProfile, style: UIAlertActionStyle.Destructive, handler: viewProfileAction))
        
        alertController.addAction(UIAlertAction(title: kSendMessage, style: UIAlertActionStyle.Destructive, handler: sendMessageClientAction))
        
        // Check exist phone number
        if (phoneNumber.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kCallClient, style: UIAlertActionStyle.Destructive, handler: callClientAction))
        }
        
        // Check exist email
        if (userMail.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kEmailClient, style: UIAlertActionStyle.Destructive, handler: emailClientAction))
        }
        
        alertController.addAction(UIAlertAction(title: kRemoveClient, style: UIAlertActionStyle.Destructive, handler: clickMoveToOld))
        
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func showAlertMovetoCurrentAction(userInfo: NSDictionary, typeGroup: Int) {
        let userID = String(format:"%0.f", userInfo[kId]!.doubleValue)
        
        let clickMoveToCurrent = { (action:UIAlertAction!) -> Void in
            var prefix = kPMAPICOACHES
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPMAPICOACH_CURRENT)
            prefix.appendContentsOf("/")
            print(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            Alamofire.request(.PUT, prefix, parameters: [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, kUserIdRequest:userID])
                .responseJSON { response in
                    self.view.hideToastActivity()
                    if response.response?.statusCode == 200 {
                        self.forceUpdate = true
                        if typeGroup == TypeGroup.NewLead.rawValue {
                            self.tbView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0),NSIndexPath(forItem: 1, inSection: 0)], withRowAnimation: .None)
                        } else {
                            self.tbView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 0),NSIndexPath(forItem: 2, inSection: 0)], withRowAnimation: .None)
                        }
                        self.forceUpdate = false
                    }
            }
        }
        
        // Email action
        let userMail = userInfo[kEmail] as! String
        let emailClientAction = { (action:UIAlertAction!) -> Void in
            UserRouter.getCurrentUserInfo(completed: { (result, error) in
                if (error == nil) {
                    let currentInfo = result as! NSDictionary
                    let currentMail = currentInfo[kEmail] as! String
                    let coachFirstName = currentInfo[kFirstname] as! String
                    let userFirstName = userInfo[kFirstname] as! String
                    
                    var urlString = "mailto:"
                    urlString = urlString.stringByAppendingString(userMail)
                    
                    urlString = urlString.stringByAppendingString("?subject=")
                    urlString = urlString.stringByAppendingString("Come%20join%20me%20on%20Pummel%20Fitness")
                    
                    urlString = urlString.stringByAppendingString("&from=")
                    urlString = urlString.stringByAppendingString(currentMail)
                    
                    urlString = urlString.stringByAppendingString("&body=")
                    urlString = urlString.stringByAppendingString("Hey%20\(userFirstName),%0A%0ACome%20join%20me%20on%20the%20Pummel%20Fitness%20app,%20where%20we%20can%20book%20appointments,%20log%20workouts,%20save%20transformation%20photos%20and%20chat%20for%20free.%0A%0ADownload%20the%20app%20at%20http://get.pummel.fit%0A%0AThanks,%0A%0ACoach%0A\(coachFirstName)")
                    
                    let mailURL = NSURL(string: urlString)
                    if (UIApplication.sharedApplication().canOpenURL(mailURL!)) {
                        UIApplication.sharedApplication().openURL(mailURL!)
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
        
        // Call action
        let phoneNumber = userInfo[kMobile] as! String
        let callClientAction = { (action:UIAlertAction!) -> Void in
            let phoneNumber = userInfo[kMobile] as! String
            var urlString = "tel:///"
            urlString = urlString.stringByAppendingString(phoneNumber)
            
            let tellURL = NSURL(string: urlString)
            if (UIApplication.sharedApplication().canOpenURL(tellURL!)) {
                UIApplication.sharedApplication().openURL(tellURL!)
            }
        }
        
        // Send message action
        let sendMessageClientAction = { (action:UIAlertAction!) -> Void in
            // Special case: can not call tabbarviewcontroller
            NSUserDefaults.standardUserDefaults().setObject(k_PM_MOVE_SCREEN_MESSAGE_DETAIL, forKey: k_PM_MOVE_SCREEN)
            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: k_PM_MOVE_SCREEN_MESSAGE_DETAIL)
            
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        let viewProfileAction = { (action:UIAlertAction!) -> Void in
            self.performSegueWithIdentifier(kGoUserProfile, sender:userID)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: kViewProfile, style: UIAlertActionStyle.Destructive, handler: viewProfileAction))
        
        alertController.addAction(UIAlertAction(title: kSendMessage, style: UIAlertActionStyle.Destructive, handler: sendMessageClientAction))
        
        // Check exist phone number
        if (phoneNumber.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kCallClient, style: UIAlertActionStyle.Destructive, handler: callClientAction))
        }
        
        // Check exist email
        if (userMail.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kEmailClient, style: UIAlertActionStyle.Destructive, handler: emailClientAction))
        }
        
        alertController.addAction(UIAlertAction(title: kAcceptClient, style: UIAlertActionStyle.Destructive, handler: clickMoveToCurrent))
        
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
}
