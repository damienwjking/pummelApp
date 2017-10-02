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
    case signup(firstName: String, email: String, password: String, gender: String, completed: CompletionBlock)
    
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
        case .signup(_ , _, _, _, let completed):
            return completed
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getCurrentUserInfo:
            return .get
        case .getUserInfo:
            return .get
        case .checkCoachOfUser:
            return .get
        case .authenticateFacebook:
            return .post
        case .getUpcomingSession:
            return .get
        case .getCompletedSession:
            return .get
        case .getTestimonial:
            return .get
        case .postTestimonial:
            return .post
        case .getFollowCoach:
            return .get
        case .signup:
            return .post
            
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
            
        case .signup:
            prefix = kPMAPI_REGISTER
            
        }
        
        return prefix
    }
    
    var param : [String: AnyObject]? {
        var param : [String : AnyObject] = [:]
        let currentUserID = PMHelper.getCurrentID()
        
        switch self {
        case .authenticateFacebook(let fbID, let email, let firstName, let lastName, let avatarURL, let gender, _):
            if (fbID != nil) {
                param["fbId"] = fbID! as AnyObject
            }
            
            if (email != nil) {
                param["email"] = email! as AnyObject
            }
            
            if (firstName != nil) {
                param["firstname"] = firstName! as AnyObject
            }
            
            if (lastName != nil) {
                param["lastname"] = lastName! as AnyObject
            }
            
            if (avatarURL != nil) {
                param["imageUrl"] = avatarURL! as AnyObject
            }
            
            if (gender != nil) {
                param["gender"] = gender! as AnyObject
            }
            
        case .postTestimonial(let userID, let description, let location, let rating, _):
            param["userId"] = userID as AnyObject
            param["userCommentId"] = currentUserID as AnyObject
            param["description"] = description as AnyObject
            param["userCommentLocation"] = location as AnyObject
            param["rating"] = String(format: "%0.1f", rating) as AnyObject

        case .getUpcomingSession, .getCompletedSession:
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dateString = dateFormater.string(from: NSDate() as Date)
            
            param["currentDate"] = dateString as AnyObject
            
        case .signup(let firstName, let email, let password, let gender, _):
            param[kEmail] = email as AnyObject
            param[kPassword] = password as AnyObject
            param[kFirstname] = firstName as AnyObject
            param[kGender] = gender as AnyObject
            
            
        default:
            break
        }
        
        return param
    }
    
    var URLRequest: NSMutableURLRequest {
        let url = NSURL(string: self.path)
        
        let mutableURLRequest = NSMutableURLRequest(url: url! as URL)
        mutableURLRequest.httpMethod = method.rawValue
        
        return mutableURLRequest
    }
    
    // For combine
    func asURLRequest() throws -> URLRequest {
        let url = NSURL(string: self.path)
        
        let mutableURLRequest = NSMutableURLRequest(url: url! as URL)
        mutableURLRequest.httpMethod = self.method.rawValue
        
        return mutableURLRequest as URLRequest
    }
    
    func fetchdata() {
        switch self {
        case .getCurrentUserInfo, .getUserInfo:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 1")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let userDetail = JSON as! NSDictionary
                        
                        self.comletedBlock!(userDetail, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(nil, error as NSError
                        
                        )
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(nil, error as NSError)
                    }
                }
            })
            
        case .checkCoachOfUser:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 2")
                
                if response.response?.statusCode == 200 {
                    self.comletedBlock!(true as AnyObject, nil)
                } else {
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(false as AnyObject, error as NSError)
                    }
                }
            })
            
        case .authenticateFacebook:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 3")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        UserRouter.saveCurrentUserInfo(response: response)
                        
                        // Can't return respone object
                        self.comletedBlock!(true as AnyObject, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(false as AnyObject, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(false as AnyObject, error as NSError)
                    }
                }
            })
            
        case .getUpcomingSession, .getCompletedSession:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 4")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let sessionArray = JSON as! NSArray
                        
                        self.comletedBlock!(sessionArray, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(nil, error as NSError)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(nil, error as NSError)
                    }
                }
            })
            
        case .getTestimonial:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 5")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let userDetail = JSON as! NSArray
                        
                        self.comletedBlock!(userDetail, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(nil, error as NSError)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(nil, error as NSError
                        )
                    }
                }
            })
            
        case .postTestimonial:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 6")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let userDetails = JSON as! NSDictionary
                        
                        self.comletedBlock!(userDetails, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(false as AnyObject, error as NSError)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(false as AnyObject, error as NSError)
                    }
                }
            })
            
        case .getFollowCoach:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 7")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let userDetails = JSON as! NSArray
                        
                        var coachArray: [UserModel] = []
                        for userDetail in userDetails {
                            let user = UserModel()
                            
                            user.id = (userDetail as! NSDictionary)[kCoachId] as! Int
                            coachArray.append(user)
                        }
                        
                        self.comletedBlock!(coachArray as AnyObject, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(nil, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(nil, error as NSError)
                    }
                }
            })
        case .signup:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 8")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        UserRouter.saveCurrentUserInfo(response: response)
                        
                        // Can't return respone object
                        self.comletedBlock!(true as AnyObject, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(false as AnyObject, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 400) {
                        let error = NSError(domain: "Error", code: 400, userInfo: nil) // Create duplicate emial error
                        self.comletedBlock!(false as AnyObject, error as NSError)
                    } else if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(false as AnyObject, error as NSError)
                    }
                }
            })
            
        }
    }
    
    static func saveCurrentUserInfo(response: DefaultDataResponse) {
        let defaults = UserDefaults.standard
        
        // Save access token here
        let JSON = NSKeyedUnarchiver.unarchiveObject(with: response.data!) as! NSDictionary
        self.updateCookies(response: response)
        let currentId = String(format:"%0.f", (JSON.object(forKey: kUserId)! as AnyObject).doubleValue)
        defaults.set(true, forKey: k_PM_IS_LOGINED)
        defaults.set(currentId, forKey: k_PM_CURRENT_ID)
        
        // Check Coach
        UserRouter.checkCoachOfUser(userID: currentId) { (result, error) in
            let isCoach = result as! Bool
            
            defaults.set(isCoach, forKey: k_PM_IS_COACH)
            }.fetchdata()
        
        
        // Send token
        if ((defaults.object(forKey: k_PM_PUSH_TOKEN)) != nil) {
            let currentId = PMHelper.getCurrentID()
            let deviceTokenString = defaults.object(forKey: k_PM_PUSH_TOKEN) as! String
            
            let param = [kUserId:currentId,
                         kProtocol:"APNS",
                         kToken: deviceTokenString]
            
            var linkPostNotif = kPMAPIUSER
            linkPostNotif.append(currentId)
            linkPostNotif.append(kPM_PATH_DEVICES)
            Alamofire.request(.POST, linkPostNotif, parameters: param)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        print("Already push tokenString")
                    } else {
                        print("Can't push tokenString")
                    }
            }
        } else {
            let application = UIApplication.shared
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    static func updateCookies(response: DefaultDataResponse) {
        let defaults = UserDefaults.standard
        
        if let
            headerFields = response.response?.allHeaderFields as? [String: String],
            let URL = response.request?.url {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
            // Set the cookies back in our shared instance. They'll be sent back with each subsequent request.
            
            Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: URL, mainDocumentURL: nil)
            defaults.set(headerFields, forKey: k_PM_HEADER_FILEDS)
            defaults.set(URL.absoluteString, forKey: k_PM_URL_LAST_COOKIE)
        }
    }
    
}
