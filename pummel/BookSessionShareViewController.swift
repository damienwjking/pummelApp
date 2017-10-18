//
//  BookSessionShareViewController.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import MessageUI

class BookSessionShareViewController: BaseViewController, GroupLeadTableViewCellDelegate, LeadAddedTableViewCellDelegate {

    @IBOutlet weak var tbView: UITableView!
    var image:UIImage?
    var tag:TagModel?
    var textToPost = ""
    var dateToPost = ""
    var userIdSelected = ""
    let defaults = UserDefaults.standard
    var forceUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancel))
        
        // add right invite button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kInvite.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.invite))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        
        let nibName = UINib(nibName: "GroupLeadTableViewCell", bundle:nil)
        self.tbView.register(nibName, forCellReuseIdentifier: "GroupLeadTableViewCell")
        
        let nibName2 = UINib(nibName: "LeadAddedTableViewCell", bundle:nil)
        self.tbView.register(nibName2, forCellReuseIdentifier: "LeadAddedTableViewCell")
        self.tbView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kClients.uppercased()
        
        self.resetLBadge()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func invite() {
        let inviteSMSAction = UIAlertAction(title: kInviteSMS, style: .destructive) { (_) in
            self.performSegue(withIdentifier: "inviteContactUser", sender: kSMS)
        }
        
        let inviteMailAction = UIAlertAction(title: kInviteEmail, style: .destructive) { (_) in
            self.performSegue(withIdentifier: "inviteContactUser", sender: kEmail)
        }
        
        let cancelAction = UIAlertAction(title: kCancle, style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(inviteSMSAction)
        alertController.addAction(inviteMailAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func selectUserWithID(userId: String, typeGroup: Int) {
        self.view.makeToastActivity()
        
        UserRouter.getUserInfo(userID: userId) { (result, error) in
            self.view.hideToastActivity()
            
            if (error == nil) {
                let userInfo = result as! NSDictionary
                
                if typeGroup == TypeGroup.Current.rawValue {
                    self.showAlertMovetoOldAction(userInfo: userInfo)
                } else {
                    self.showAlertMovetoCurrentAction(userInfo: userInfo, typeGroup: typeGroup)
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func removeUserWithID(userId:String) {
        userIdSelected = ""
        self.tbView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "inviteContactUser") {
            let destination = segue.destination as! ContactUserViewController
            
            let styleInvite = sender as! String
            destination.styleInvite = styleInvite
        }
    }
}

//MARK: TableView
extension BookSessionShareViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupLeadTableViewCell") as! GroupLeadTableViewCell
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
        let userID = String(format:"%0.f", (userInfo[kId]! as AnyObject).doubleValue)
        
        let clickMoveToOld = { (action:UIAlertAction!) -> Void in
            self.view.makeToastActivity()
            
            UserRouter.setOldLead(requestID: userID, completed: { (result, error) in
                self.view.hideToastActivity()
                
                let isChangeSuccess = result as! Bool
                if (isChangeSuccess) {
                    self.forceUpdate = true
                    
//                    self.tbView.reloadRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .fade)
                    self.tbView.reloadData()
                    
                    self.forceUpdate = false
                }
                
            }).fetchdata()
        }
        
        // Email action
        let userMail = userInfo[kEmail] as! String
        let emailClientAction = { (action:UIAlertAction!) -> Void in
            UserRouter.getCurrentUserInfo(completed: { (result, error) in
                if (error == nil) {
                    let currentInfo = result as! NSDictionary
                    let coachFirstName = currentInfo[kFirstname] as! String
                    let userFirstName = userInfo[kFirstname] as! String
                    
                    if MFMailComposeViewController.canSendMail() {
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = self
                        
                        mail.setSubject("Come join me on Pummel Fitness")
                        mail.setMessageBody("Hey \(userFirstName),\n\nCome join me on the Pummel Fitness app, where we can book appointments, log workouts, save transformation photos and chat for free.\n\nDownload the app at http://get.pummel.fit\n\nThanks,\n\nCoach\n\(coachFirstName)", isHTML: true)
                        self.present(mail, animated: true, completion: nil)
                    } else {
                        PMHelper.showDoAgainAlert()
                    }
                    
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
        // Call action
        let phoneNumber = userInfo[kMobile] as? String
        let callClientAction = { (action:UIAlertAction!) -> Void in
            let urlString = "tel:///" + phoneNumber!
            
            let tellURL = NSURL(string: urlString)
            if (UIApplication.shared.canOpenURL(tellURL! as URL)) {
                UIApplication.shared.openURL(tellURL! as URL)
            }
        }
        
        // Send message action
        let sendMessageClientAction = { (action:UIAlertAction!) -> Void in
            // Special case: can not call tabbarviewcontroller
            UserDefaults.standard.set(k_PM_MOVE_SCREEN_MESSAGE_DETAIL, forKey: k_PM_MOVE_SCREEN)
            UserDefaults.standard.set(userID, forKey: k_PM_MOVE_SCREEN_MESSAGE_DETAIL)
            
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        let viewProfileAction = { (action:UIAlertAction!) -> Void in
            PMHelper.showCoachOrUserView(userID: userID)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: kViewProfile, style: UIAlertActionStyle.destructive, handler: viewProfileAction))
        
        alertController.addAction(UIAlertAction(title: kSendMessage, style: UIAlertActionStyle.destructive, handler: sendMessageClientAction))
        
        // Check exist phone number
        if (phoneNumber != nil && phoneNumber!.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kCallClient, style: UIAlertActionStyle.destructive, handler: callClientAction))
        }
        
        // Check exist email
        if (userMail.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kEmailClient, style: UIAlertActionStyle.destructive, handler: emailClientAction))
        }
        
        alertController.addAction(UIAlertAction(title: kRemoveClient, style: UIAlertActionStyle.destructive, handler: clickMoveToOld))
        
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    func showAlertMovetoCurrentAction(userInfo: NSDictionary, typeGroup: Int) {
        let userID = String(format:"%0.f", (userInfo[kId]! as AnyObject).doubleValue)
        
        let clickMoveToCurrent = { (action:UIAlertAction!) -> Void in
            self.view.makeToastActivity()
            
            UserRouter.setCurrentLead(requestID: userID, completed: { (result, error) in
                self.view.hideToastActivity()
                
                let isChangeSuccess = result as! Bool
                if (isChangeSuccess) {
                    self.forceUpdate = true
                    
//                    self.tbView.reloadRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .fade)
                    self.tbView.reloadData()
                    
                    self.forceUpdate = false
                }
                
            }).fetchdata()
        }
        
        // Email action
        let userMail = userInfo[kEmail] as! String
        let emailClientAction = { (action:UIAlertAction!) -> Void in
            UserRouter.getCurrentUserInfo(completed: { (result, error) in
                if (error == nil) {
                    let currentInfo = result as! NSDictionary
                    let coachFirstName = currentInfo[kFirstname] as! String
                    let userFirstName = userInfo[kFirstname] as! String
                    
                    if MFMailComposeViewController.canSendMail() {
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = self
                        
                        mail.setSubject("Come join me on Pummel Fitness")
                        mail.setMessageBody("Hey \(userFirstName),\n\nCome join me on the Pummel Fitness app, where we can book appointments, log workouts, save transformation photos and chat for free.\n\nDownload the app at http://get.pummel.fit\n\nThanks,\n\nCoach\n\(coachFirstName)", isHTML: true)
                        self.present(mail, animated: true, completion: nil)
                    } else {
                        PMHelper.showDoAgainAlert()
                    }
                    
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
        // Call action
        let phoneNumber = userInfo[kMobile] as? String
        var callClientAction:((UIAlertAction) -> Void)? = nil
        if (phoneNumber != nil) {
            callClientAction = { (action:UIAlertAction!) -> Void in
                let phoneNumber = userInfo[kMobile] as! String
                let urlString = "tel:///" + phoneNumber
                
                let tellURL = NSURL(string: urlString)
                if (UIApplication.shared.canOpenURL(tellURL! as URL)) {
                    UIApplication.shared.openURL(tellURL! as URL)
                }
            }
        }
        
        
        // Send message action
        let sendMessageClientAction = { (action:UIAlertAction!) -> Void in
            // Special case: can not call tabbarviewcontroller
            UserDefaults.standard.set(k_PM_MOVE_SCREEN_MESSAGE_DETAIL, forKey: k_PM_MOVE_SCREEN)
            UserDefaults.standard.set(userID, forKey: k_PM_MOVE_SCREEN_MESSAGE_DETAIL)
            
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        let viewProfileAction = { (action:UIAlertAction!) -> Void in
            PMHelper.showCoachOrUserView(userID: userID)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: kViewProfile, style: UIAlertActionStyle.destructive, handler: viewProfileAction))
        
        alertController.addAction(UIAlertAction(title: kSendMessage, style: UIAlertActionStyle.destructive, handler: sendMessageClientAction))
        
        // Check exist phone number
        if (phoneNumber != nil && phoneNumber?.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kCallClient, style: UIAlertActionStyle.destructive, handler: callClientAction))
        }
        
        // Check exist email
        if (userMail.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kEmailClient, style: UIAlertActionStyle.destructive, handler: emailClientAction))
        }
        
        alertController.addAction(UIAlertAction(title: kAcceptClient, style: UIAlertActionStyle.destructive, handler: clickMoveToCurrent))
        
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
}

extension BookSessionShareViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
