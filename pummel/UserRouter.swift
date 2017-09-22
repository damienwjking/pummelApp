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
    case getUpcomingSession(offset: Int, completed: CompletionBlock)
    case getCompletedSession(offset: Int, completed: CompletionBlock)
    case getTestimonial(userID: String, offset: Int, completed: CompletionBlock)
    case postTestimonial(userID: String, description: String, location: String, rating: CGFloat, completed: CompletionBlock)
    case getFollowCoach(offset: Int, completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock? {
        switch self {
        case .getCurrentUserInfo(let completed):
            return completed
        case .getUserInfo(_, let completed):
            return completed
        case .checkCoachOfUser(_, let completed):
            return completed
        case .authenticateFacebook(_, _, _, _, _, _, let completed):
            return completed
        case .getUpcomingSession(_, let completed):
            return completed
        case .getCompletedSession(_, let completed):
            return completed
        case .getTestimonial(_, _, let completed):
            return completed
        case .postTestimonial(_, _, _, _, let completed):
            return completed
        case .getFollowCoach(_, let completed):
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
        case .getUpcomingSession:
            return .GET
        case .getCompletedSession:
            return .GET
        case .getTestimonial:
            return .GET
        case .postTestimonial:
            return .POST
        case .getFollowCoach:
            return .GET
            
        }
    }
    
    var path: String {
        let currentUserID = PMHelper.getCurrentID()
        
        var prefix = ""
        switch self {
        case .getCurrentUserInfo:
            prefix = kPMAPIUSER + currentUserID
            
        case .getUserInfo(let userID, _):
            prefix = kPMAPIUSER + userID
            
        case .checkCoachOfUser(let userID, _):
            prefix = kPMAPICOACH + userID
            
        case .authenticateFacebook:
            prefix = kPMAPIAUTHENTICATEFACEBOOK
            
        case .getUpcomingSession(let offset, _):
            let offsetString = String(format: "%ld", offset)
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_UPCOMING_SESSION + offsetString
            
        case .getCompletedSession(let offset, _):
            let offsetString = String(format: "%ld", offset)
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_COMPLETED_SESSION + offsetString
            
        case .getTestimonial(let userID, let offset, _):
            let offsetString = String(format: "%ld", offset)
            prefix = kPMAPIUSER + userID + kPM_PATH_TESTIMONIAL_OFFSET + offsetString
        
        case .postTestimonial(let userID, _, _, _, _):
            prefix = kPMAPIUSER + userID + kPM_PATH_TESTIMONIAL
            
        case .getFollowCoach (let offset, _):
            let offsetString = String(format: "%ld", offset)
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_USERCOACH_OFFSET + offsetString
            
        }
        
        return prefix
    }
    
    var param : [String: AnyObject]? {
        var param : [String : AnyObject] = [:]
        let currentUserID = PMHelper.getCurrentID()
        
        switch self {
        case .authenticateFacebook(let fbID, let email, let firstName, let lastName, let avatarURL, let gender, _):
            if (fbID != nil) {
                param["fbId"] = fbID!
            }
            
            if (email != nil) {
                param["email"] = email!
            }
            
            if (firstName != nil) {
                param["firstname"] = firstName!
            }
            
            if (lastName != nil) {
                param["lastname"] = lastName!
            }
            
            if (avatarURL != nil) {
                param["imageUrl"] = avatarURL!
            }
            
            if (gender != nil) {
                param["gender"] = gender!
            }
            
        case .postTestimonial(let userID, let description, let location, let rating, _):
            param["userId"] = userID
            param["userCommentId"] = currentUserID
            param["description"] = description
            param["userCommentLocation"] = location
            param["rating"] = String(format: "%0.1f", rating)

        case .getUpcomingSession, .getCompletedSession:
            let dateFormater = NSDateFormatter()
            dateFormater.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dateString = dateFormater.stringFromDate(NSDate())
            
            param["currentDate"] = dateString
            
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
                print("PM: UserRouter 1")
                
                switch response.result {
                case .Success(let JSON):
                    if (JSON is NSNull == false) {
                        let userDetail = JSON as! NSDictionary
                        
                        self.comletedBlock!(result: userDetail, error: nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(result: nil, error: error)
                    }
                case .Failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(result: nil, error: error)
                    }
                }
            })
            
        case checkCoachOfUser:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 2")
                
                if response.response?.statusCode == 200 {
                    self.comletedBlock!(result: true, error: nil)
                } else {
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(result: false, error: error)
                    }
                }
            })
            
        case .authenticateFacebook:
            Alamofire.request(self.method, self.path, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 3")
                
                switch response.result {
                case .Success(let JSON):
                    if (JSON is NSNull == false) {
                        UserRouter.saveCurrentUserInfo(response)
                        
                        self.comletedBlock!(result: true, error: nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(result: false, error: error)
                    }
                case .Failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(result: false, error: error)
                    }
                }
            })
            
        case .getUpcomingSession, .getCompletedSession:
            Alamofire.request(self.method, self.path, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 4")
                
                switch response.result {
                case .Success(let JSON):
                    if (JSON is NSNull == false) {
                        let sessionArray = JSON as! NSArray
                        
                        self.comletedBlock!(result: sessionArray, error: nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(result: nil, error: error)
                    }
                case .Failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(result: nil, error: error)
                    }
                }
            })
        case getTestimonial:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 5")
                
                switch response.result {
                case .Success(let JSON):
                    if (JSON is NSNull == false) {
                        let userDetail = JSON as! NSArray
                        
                        self.comletedBlock!(result: userDetail, error: nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(result: nil, error: error)
                    }
                case .Failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(result: nil, error: error)
                    }
                }
            })
            
        case .postTestimonial:
            Alamofire.request(self.method, self.path, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 6")
                
                switch response.result {
                case .Success(let JSON):
                    if (JSON is NSNull == false) {
                        let userDetails = JSON as! NSDictionary
                        
                        self.comletedBlock!(result: userDetails, error: nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(result: false, error: error)
                    }
                case .Failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(result: false, error: error)
                    }
                }
            })
            
        case getFollowCoach:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 7")
                
                switch response.result {
                case .Success(let JSON):
                    if (JSON is NSNull == false) {
                        let userDetails = JSON as! NSArray
                        
                        var coachArray: [UserModel] = []
                        for userDetail in userDetails {
                            let user = UserModel()
                            
                            user.id = userDetail[kCoachId] as! Int
                            coachArray.append(user)
                        }
                        
                        self.comletedBlock!(result: coachArray, error: nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(result: nil, error: error)
                    }
                case .Failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(result: nil, error: error)
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
            let currentId = PMHelper.getCurrentID()
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
