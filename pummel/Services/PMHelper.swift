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
        let currentId = UserDefaults.standard.object(forKey: k_PM_CURRENT_ID) as? String
        
        if (currentId != nil) {
            return currentId!
        }
        return ""
    }
    
    class func checkVisibleCell(tableView: UITableView, indexPath: IndexPath ) -> Bool {
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
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alertController = UIAlertController(title: pmmNotice, message: cookieExpiredNotice, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                
                topController.view.makeToastActivity(message: "Logging Out")
                
                // LOGOUT
                UserDefaults.standard.set(0, forKey: "MESSAGE_BADGE_VALUE")
                Alamofire.request(kPMAPI_LOGOUT, method: .delete).responseData(completionHandler: { (response) in
                    topController.view.hideToastActivity()

                    // Logout facebook
                    let loginManager: FBSDKLoginManager = FBSDKLoginManager()
                    loginManager.logOut()
                    
                    // Logout app
                    let defaults = UserDefaults.standard
                    
                    let data = response.result.value!
                    let outputString = NSString(data: data, encoding:String.Encoding.utf8.rawValue)
                    if ((outputString?.contains(kLogoutSuccess)) != nil) {
                        defaults.set(false, forKey: k_PM_IS_LOGINED)
                        defaults.set(false, forKey: k_PM_IS_COACH)
                        let storage = HTTPCookieStorage.shared
                        for cookie in storage.cookies! {
                            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.deleteCookie(cookie)
                            storage.deleteCookie(cookie)
                        }
                        UserDefaults.standard.synchronize()
                        
                        topController.dismiss(animated: true, completion: nil)
                    }
                })
                
                // Tracker mixpanel
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Navigation Click", "Label":"Logout"]
                mixpanel?.track("IOS.Profile.Setting", properties: properties)
            }
            
            alertController.addAction(OKAction)
            
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func showApplyAlert(message: String) {
        PMHelper.showAlert(title: kApply, message: message)
    }
    
    class func showDoAgainAlert() {
        PMHelper.showAlert(title: pmmNotice, message: pleaseDoItAgain)
    }
    
    class func showNoticeAlert(message: String) {
        PMHelper.showAlert(title: pmmNotice, message: message)
    }

    class func showAlert(title: String, message: String) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                // ...
            }
            
            alertController.addAction(OKAction)
            
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func showCoachOrUserView(userID: String, showTestimonial: Bool = false, isFromChat:Bool = false) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let currentUser = PMHelper.getCurrentID()
            
            if (userID == currentUser) {
                UserDefaults.standard.set(k_PM_MOVE_SCREEN_CURRENT_PROFILE, forKey: k_PM_MOVE_SCREEN)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_MOVE_SCREEN_NOTIFICATION), object: nil)
            } else {
                topController.view.makeToastActivity()
                
                UserRouter.getUserInfo(userID: userID) { (result, error) in
                    if (error == nil) {
                        let userInfo = result as! NSDictionary
                        
                        if let firstName = userInfo[kFirstname] as? String {
                            // Tracker mixpanel
                            let mixpanel = Mixpanel.sharedInstance()
                            let properties = ["Name": "Profile Is Clicked", "Label":"\(firstName.uppercased())"]
                            mixpanel?.track("IOS.ClickOnProfile", properties: properties)
                        }
                        
                        UserRouter.checkCoachOfUser(userID: userID) { (result, error) in
                            topController.view.hideToastActivity()
                            
                            let isCoach = result as! Bool
                            
                            let coachProfileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileViewController
                            
                            coachProfileVC.isCoach = isCoach
                            coachProfileVC.userID = userID
                            coachProfileVC.coachDetail = userInfo
                            coachProfileVC.profileStyle = .otherUser
                            coachProfileVC.isFromChat = isFromChat
                            
                            if (showTestimonial == true) {
                                topController.present(coachProfileVC, animated: true, completion: {
                                    coachProfileVC.showPostTestimonialViewController()
                                })
                            } else {
                                topController.present(coachProfileVC, animated: true, completion: nil)
                            }
                            
                            
//                            if (isCoach == true) {
//                                //                            let coachProfileVC = UIStoryboard(name: "CoachProfile", bundle: nil).instantiateInitialViewController() as! CoachProfileViewController
//                                
//                                let coachProfileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileViewController
//                                
//                                coachProfileVC.isCoach = true
//                                coachProfileVC.userID = userID
//                                coachProfileVC.coachDetail = userInfo
//                                coachProfileVC.profileStyle = .otherUser
//                                coachProfileVC.isFromChat = isFromChat
//                                
//                                if (showTestimonial == true) {
//                                    topController.present(coachProfileVC, animated: true, completion: {
//                                        coachProfileVC.showPostTestimonialViewController()
//                                    })
//                                } else {
//                                    topController.present(coachProfileVC, animated: true, completion: nil)
//                                }
//                            } else {
//                                let userProfileVC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateInitialViewController() as! UserProfileViewController
//                                
//                                userProfileVC.userDetail = userInfo
//                                userProfileVC.userId = userID
//                                
//                                if (showTestimonial == true) {
//                                    topController.present(userProfileVC, animated: true, completion: {
//                                        userProfileVC.showPostTestimonialViewController()
//                                    })
//                                } else {
//                                    topController.present(userProfileVC, animated: true, completion: nil)
//                                }
//                            }
                            }.fetchdata()
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                    }.fetchdata()
            }
        }
    }
    
    class func actionWithDelaytime(delayTime: Double, delayAction: @escaping (Void) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            delayAction()
        }
    }
    
}
