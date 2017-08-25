//
//  UserRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/7/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import Alamofire

enum UserRouter: URLRequestConvertible {
    case getCurrentUserInfo(completed: CompletionBlock)
    case getUserInfo(userID : String, completed: CompletionBlock)
    case checkCoachOfUser(userID : String, completed: CompletionBlock)
    case authenticateFacebook(fbID : String?, email : String?, firstName : String?, lastName : String?, avatarURL : String?, gender : String?, completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getCurrentUserInfo(let completed):
            return completed
        case .getUserInfo(_, let completed):
            return completed
        case .checkCoachOfUser(_, let completed):
            return completed
        case .authenticateFacebook(_, _, _, _, _, _, let completed):
            return completed
        }
    }
    
    var method: Alamofire.Method {
        switch self {
        case .getCurrentUserInfo:
            return .GET
        case .getUserInfo:
            return .GET
        case .checkCoachOfUser:
            return .GET
        case .authenticateFacebook:
            return .POST
        }
    }
    
    var path: String {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var prefix = ""
        switch self {
        case .getCurrentUserInfo:
            let currentUserID = defaults.objectForKey(k_PM_CURRENT_ID) as! String
            prefix = kPMAPIUSER + currentUserID
            
        case .getUserInfo(let userID, _):
            prefix = kPMAPIUSER + userID
            
        case .checkCoachOfUser(let userID, _):
            prefix = kPMAPICOACH + userID
            prefix = kPMAPIUSER + userID
            
        case .authenticateFacebook:
            prefix = kPMAPIAUTHENTICATEFACEBOOK
        }
        
        return prefix
    }
    
    var param : [String: AnyObject]? {
        var param : [String : AnyObject
            ]? = [:]
        
        switch self {
        case .authenticateFacebook(let fbID, let email, let firstName, let lastName, let avatarURL, let gender, _):
            if (fbID != nil) {
                param!["fbId"] = fbID!
            }
            
            if (email != nil) {
                param!["email"] = email!
            }
            
            if (firstName != nil) {
                param!["firstname"] = firstName!
            }
            
            if (lastName != nil) {
                param!["lastname"] = lastName!
            }
            
            if (avatarURL != nil) {
                param!["imageUrl"] = avatarURL!
            }
            
            if (gender != nil) {
                param!["gender"] = gender!
            }
            
        default:
            break
        }
        
        return param
    }
    
    // MARK: URLRequestConvertible
    var URLRequest: NSMutableURLRequest {
        //        let mutableURLRequest = NSMutableURLRequest.create(path, method: method.rawValue)!
        
        let url = NSURL(string: self.path)
        
        let mutableURLRequest = NSMutableURLRequest(URL: url!)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        return mutableURLRequest
    }
    
    func fetchdata() {
        switch self {
        case .getCurrentUserInfo, .getUserInfo:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success(let JSON):
                    if (JSON is NSNull == false) {
                        let userDetail = JSON as! NSDictionary
                        
                        self.comletedBlock(result: userDetail, error: nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock(result: nil, error: error)
                    }
                case .Failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHeler.showLogoutAlert()
                    } else {
                        self.comletedBlock(result: nil, error: error)
                    }
                }
            })
            
        case checkCoachOfUser:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                if response.response?.statusCode == 200 {
                    self.comletedBlock(result: true, error: nil)
                } else {
                    if (response.response?.statusCode == 401) {
                        PMHeler.showLogoutAlert()
                    } else {
                        self.comletedBlock(result: false, error: nil)
                    }
                }
            })
            
        case .authenticateFacebook:
            Alamofire.request(self.method, self.path, parameters: self.param).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success(let JSON):
                    if (JSON is NSNull == false) {
                        UserRouter.saveCurrentUserInfo(response)
                        
                        self.comletedBlock(result: true, error: nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock(result: false, error: error)
                    }
                case .Failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHeler.showLogoutAlert()
                    } else {
                        self.comletedBlock(result: false, error: error)
                    }
                }
            })
        }
    }
    
    static func saveCurrentUserInfo(response: Response<AnyObject, NSError>) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Save access token here
        let JSON = response.result.value
        self.updateCookies(response)
        let currentId = String(format:"%0.f",JSON!.objectForKey(kUserId)!.doubleValue)
        defaults.setObject(true, forKey: k_PM_IS_LOGINED)
        defaults.setObject(currentId, forKey: k_PM_CURRENT_ID)
        
        // Check Coach
        var coachLink  = kPMAPICOACH
        let coachId = currentId
        coachLink.appendContentsOf(coachId)
        Alamofire.request(.GET, coachLink)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    defaults.setObject(true, forKey: k_PM_IS_COACH)
                } else {
                    defaults.setObject(false, forKey: k_PM_IS_COACH)
                }
        }
        
        // Send token
        if ((defaults.objectForKey(k_PM_PUSH_TOKEN)) != nil) {
            let currentId = NSUserDefaults.standardUserDefaults().objectForKey(k_PM_CURRENT_ID) as! String
            let deviceTokenString = defaults.objectForKey(k_PM_PUSH_TOKEN) as! String
            
            let param = [kUserId:currentId,
                         kProtocol:"APNS",
                         kToken: deviceTokenString]
            
            var linkPostNotif = kPMAPIUSER
            linkPostNotif.appendContentsOf(currentId)
            linkPostNotif.appendContentsOf(kPM_PATH_DEVICES)
            Alamofire.request(.POST, linkPostNotif, parameters: param)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        print("Already push tokenString")
                    } else {
                        print("Can't push tokenString")
                    }
            }
        } else {
            let application = UIApplication.sharedApplication()
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    static func updateCookies(response: Response<AnyObject, NSError>) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let
            headerFields = response.response?.allHeaderFields as? [String: String],
            let URL = response.request?.URL {
            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: URL)
            // Set the cookies back in our shared instance. They'll be sent back with each subsequent request.
            Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: URL, mainDocumentURL: nil)
            defaults.setObject(headerFields, forKey: k_PM_HEADER_FILEDS)
            defaults.setObject(URL.absoluteString, forKey: k_PM_URL_LAST_COOKIE)
        }
    }
    
}
