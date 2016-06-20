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
    
    let numberOfSection = 4
    let rowArray: [String] = ["Report a problem", "Terms and conditions", "Testing"]
    let rowArrayFinalSession: [String] = ["Rate this App", "Logout"]
    let headerArray: [String] = ["Support", "Legal", "About", " "]
    let cellId = "cell"
    let viewControllerBuildNumberId = "BuildNumber"
    let alertRateMessage = "if you enjoy using devdactic-rateme, would you mind taking a moment to rate it? It won’t take more than a minute. Thanks for your support!"
    
    @IBOutlet weak var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Setting"
        settingTableView.delegate = self
        settingTableView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSection
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArray[section]
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40.0
        }
        return 0.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        self.settingTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellId)
        if indexPath.section == 3 {
            cell.textLabel?.text = rowArrayFinalSession[indexPath.row]
        } else {
            cell.textLabel?.text = rowArray[indexPath.section]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        switch indexPath.section {
        case 0:
            self.sendEmail()
        case 1:
            self.openWebView()
        case 2:
            self.openBuildNumberView()
        case 3:
            if indexPath.row == 0 {
                self.showRateDialog()
            }
            else
            {
                self.logOut()
            }
            
        default: break
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients(["support@pummel.fit"])
            mailComposerVC.setSubject("Report a problem")
            self.presentViewController(mailComposerVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true) { }
    }
    
    func openWebView() {
        let url = NSURL (string: "http://www.google.com")
        UIApplication.sharedApplication().openURL(url!)
    }
    func openBuildNumberView() {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier(viewControllerBuildNumberId) as! BuildNumberViewController
        guard let navigation = self.navigationController else {
            return
        }
        viewController.title = "Testing"
        navigation.pushViewController(viewController, animated: true)
    }
    
    func showRateDialog() {
        let alertController = UIAlertController(title: "RateDevDactic-rateme", message: alertRateMessage, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "No, Thanks", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Remind Me Later", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Rate It Now", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
        
    }
    
    func logOut() {
        Alamofire.request(.DELETE, "http://api.pummel.fit/api/logout").response { (req, res, data, error) -> Void in
            print(res)
            let outputString = NSString(data: data!, encoding:NSUTF8StringEncoding)
            if ((outputString?.containsString("Logout successful")) != nil) {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(false, forKey: "isLogined")
                let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for cookie in storage.cookies! {
                    storage.deleteCookie(cookie)
                }
                NSUserDefaults.standardUserDefaults().synchronize()
                self.performSegueWithIdentifier("backToRegister", sender: nil)
            } else {
                let alertController = UIAlertController(title: "Logout Issues", message: "Please do it again", preferredStyle: .Alert)
                
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
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