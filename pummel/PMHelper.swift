//
//  PMHelper.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/12/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Mixpanel
import Alamofire
import Foundation


class PMHelper {
    class func getCurrentID() -> String {
        let currentId = NSUserDefaults.standardUserDefaults().objectForKey(k_PM_CURRENT_ID) as? String
        
        if (currentId != nil) {
            return currentId!
        }
        return ""
    }
    
    class func checkVisibleCell(tableView: UITableView, indexPath: NSIndexPath ) -> Bool {
        var visibleCell = false
        for indexP in (tableView.indexPathsForVisibleRows)! {
            if (indexP.row == indexPath.row &&
                indexP.section == indexPath.section) {
                visibleCell = true
                break
            }
        }
        
        return visibleCell
    }
    
    class func showLogoutAlert() {
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alertController = UIAlertController(title: pmmNotice, message: cookieExpiredNotice, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                // LOGOUT
                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "MESSAGE_BADGE_VALUE")
                Alamofire.request(.DELETE, kPMAPI_LOGOUT).response { (req, res, data, error) -> Void in
                    print(res)
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    
                    let outputString = NSString(data: data!, encoding:NSUTF8StringEncoding)
                    if ((outputString?.containsString(kLogoutSuccess)) != nil) {
                        defaults.setObject(false, forKey: k_PM_IS_LOGINED)
                        defaults.setObject(false, forKey: k_PM_IS_COACH)
                        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                        for cookie in storage.cookies! {
                            Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.deleteCookie(cookie)
                            storage.deleteCookie(cookie)
                        }
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        topController.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                
                // Tracker mixpanel
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Navigation Click", "Label":"Logout"]
                mixpanel.track("IOS.Profile.Setting", properties: properties)
            }
            
            alertController.addAction(OKAction)
            
            topController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    class func showDoAgainAlert() {
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                // ...
            }
            
            alertController.addAction(OKAction)
            
            topController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    class func showApplyAlert(message: String) {
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alertController = UIAlertController(title: kApply, message: message, preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                // ...
            }
            
            alertController.addAction(OKAction)
            
            topController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    class func showCoachOrUserView(userID: String, showTestimonial: Bool = false) {
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.view.makeToastActivity()
            
            UserRouter.getUserInfo(userID: userID) { (result, error) in
                if (error == nil) {
                    let userInfo = result as! NSDictionary
                    
                    if let firstName = userInfo[kFirstname] as? String {
                        // Tracker mixpanel
                        let mixpanel = Mixpanel.sharedInstance()
                        let properties = ["Name": "Profile Is Clicked", "Label":"\(firstName.uppercaseString)"]
                        mixpanel.track("IOS.ClickOnProfile", properties: properties)
                    }
                    
                    UserRouter.checkCoachOfUser(userID: userID) { (result, error) in
                        topController.view.hideToastActivity()
                        
                        let isCoach = result as! Bool
                        if (isCoach == true) {
//                            let coachProfileVC = UIStoryboard(name: "CoachProfile", bundle: nil).instantiateInitialViewController() as! CoachProfileViewController
                            
                            let coachProfileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileViewController
                            
                            coachProfileVC.userID = userID
                            
                            coachProfileVC.coachDetail = userInfo
                            
                            if (showTestimonial == true) {
                                topController.presentViewController(coachProfileVC, animated: true, completion: {
                                    coachProfileVC.showPostTestimonialViewController()
                                })
                            } else {
                                topController.presentViewController(coachProfileVC, animated: true, completion: nil)
                            }
                        } else {
                            let userProfileVC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateInitialViewController() as! UserProfileViewController
                            
                            userProfileVC.userDetail = userInfo
                            userProfileVC.userId = userID
                            
                            if (showTestimonial == true) {
                                topController.presentViewController(userProfileVC, animated: true, completion: { 
                                    userProfileVC.showPostTestimonialViewController()
                                })
                            } else {
                                topController.presentViewController(userProfileVC, animated: true, completion: nil)
                            }
                        }
                        }.fetchdata()
                } else {
                    print("Request failed with error: \(error)")
                }
                }.fetchdata()
        }
    }
    
    class func actionWithDelaytime(delayTime: Double, delayAction: Void -> Void) {
        let delay = delayTime * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            delayAction()
        })
    }
    
}
