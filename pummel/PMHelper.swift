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


class PMHeler {
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
    
    class func logout() {
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alertController = UIAlertController(title: pmmNotice, message: cookieExpiredNotice, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
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
}
