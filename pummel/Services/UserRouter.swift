//
//  UserRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/7/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import MapKit
import Mixpanel
import Alamofire
import Foundation

enum UserRouter: URLRequestConvertible {
    case getCurrentUserInfo(completed: CompletionBlock)
    case getUserInfo(userID : String, completed: CompletionBlock)
    case getCoachInfo(userID : String, completed: CompletionBlock)
    case changeCurrentUserInfo(posfix: String, param: [String : Any], completed: CompletionBlock)
    case changeCurrentCoachInfo(posfix: String, param: [String : Any], completed: CompletionBlock)
    case checkCoachOfUser(userID : String, completed: CompletionBlock)
    case authenticateFacebook(fbID : String?, email : String?, firstName : String?, lastName : String?, avatarURL : String?, gender : String?, completed: CompletionBlock)
    case getUpcomingSession(offset: Int, completed: CompletionBlock)
    case getCompletedSession(offset: Int, completed: CompletionBlock)
    case getTestimonial(userID: String, offset: Int, completed: CompletionBlock)
    case postTestimonial(userID: String, description: String, location: String, rating: CGFloat, completed: CompletionBlock)
    case getFollowCoach(offset: Int, completed: CompletionBlock)
    case getUserTagList(userID : String, completed: CompletionBlock)
    case getPhotoList(userID : String, offset: Int, completed: CompletionBlock)
    case signup(firstName: String, email: String, password: String, gender: String, completed: CompletionBlock)
    case login(email: String, password: String, completed: CompletionBlock)
    case changePassword(currentPassword: String, newPassword: String, completed: CompletionBlock)
    case forgotPassword(email: String, completed: CompletionBlock)
    case checkConnect(coachID: String, completed: CompletionBlock)
    case setLead(coachID: String, completed: CompletionBlock)
    case getLead(userID: String, type: String, offset: Int, completed: CompletionBlock)
    case setCurrentLead(requestID: String, completed: CompletionBlock)
    case setOldLead(requestID: String, completed: CompletionBlock)
    case searchCoachNearby(gender: String, tags: NSArray, longitude: CLLocationDegrees, latitute: CLLocationDegrees, stage: String, city: String, offset: Int, completed: CompletionBlock)
    case getUserList(offset: Int, completed: CompletionBlock)
    case getSearhUserList(offset: Int, character: String, completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock? {
        switch self {
        case .getCurrentUserInfo(let completed):
            return completed
        case .getUserInfo(_, let completed):
            return completed
        case .getCoachInfo(_, let completed):
            return completed
        case .changeCurrentUserInfo(_, _, let completed):
            return completed
        case .changeCurrentCoachInfo(_, _, let completed):
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
        case .getUserTagList(_, let completed):
            return completed
        case .getPhotoList(_, _, let completed):
            return completed
        case .signup(_ , _, _, _, let completed):
            return completed
        case .login(_ , _, let completed):
            return completed
        case .changePassword(_, _, let completed):
            return completed
        case .forgotPassword(_, let completed):
            return completed
        case .checkConnect(_, let completed):
            return completed
        case .setLead(_, let completed):
            return completed
        case .getLead(_, _, _, let completed):
            return completed
        case .setCurrentLead(_, let completed):
            return completed
        case .setOldLead(_, let completed):
            return completed
        case .searchCoachNearby(_, _, _, _, _, _, _, let completed):
            return completed
        case .getUserList(_, let completed):
            return completed
        case .getSearhUserList(_, _, let completed):
            return completed
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getCurrentUserInfo:
            return .get
        case .getUserInfo:
            return .get
        case .getCoachInfo:
            return .get
        case .changeCurrentUserInfo:
            return .put
        case .changeCurrentCoachInfo:
            return .put
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
        case .getUserTagList:
            return .get
        case .getPhotoList:
            return .get
        case .signup:
            return .post
        case .login:
            return .post
        case .changePassword:
            return .put
        case .forgotPassword:
            return .post
        case .checkConnect:
            return .post
        case .setLead:
            return .post
        case .getLead:
            return .get
        case .setCurrentLead:
            return .put
        case .setOldLead:
            return .put
        case .searchCoachNearby:
            return .get
        case .getUserList:
            return .get
        case .getSearhUserList:
            return .get
            
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
            
        case .getCoachInfo(let userID, _):
            prefix = kPMAPICOACH + userID
            
        case .changeCurrentUserInfo (let posfix, _, _):
            prefix = kPMAPIUSER + currentUserID + posfix
            
        case .changeCurrentCoachInfo (let posfix, _, _):
            prefix = kPMAPICOACH + currentUserID + posfix
            
        case .checkCoachOfUser(let userID, _):
            prefix = kPMAPICOACH + userID
            
        case .authenticateFacebook:
            prefix = kPMAPIAUTHENTICATEFACEBOOK
            
        case .getUpcomingSession(let offset, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_UPCOMING_SESSION + "\(offset)"
            
        case .getCompletedSession(let offset, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_COMPLETED_SESSION + "\(offset)"
            
        case .getTestimonial(let userID, let offset, _):
            prefix = kPMAPIUSER + userID + kPM_PATH_TESTIMONIAL_OFFSET + "\(offset)"
        
        case .postTestimonial(let userID, _, _, _, _):
            prefix = kPMAPIUSER + userID + kPM_PATH_TESTIMONIAL
            
        case .getFollowCoach(let offset, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_USERCOACH_OFFSET + "\(offset)"
            
        case .getUserTagList(let userID, _):
            prefix = kPMAPIUSER + userID + "/tags"
            
        case .getPhotoList(let userID, let offset, _):
            prefix = kPMAPIUSER + userID + kPM_PATH_PHOTOV2 + "\(offset)"
            
        case .signup:
            prefix = kPMAPI_REGISTER
            
        case .login:
            prefix = kPMAPI_LOGIN
            
        case .changePassword:
            prefix = kPMAPIUSER + currentUserID + kPMAPI_CHANGEPASS
            
        case .forgotPassword:
            prefix = kPMAPI_FORGOT
            
        case .checkConnect:
            prefix = kPMAPICHECKUSERCONNECT
            
        case .setLead:
            prefix = kPMAPIUSER + currentUserID + kPMAPI_LEAD + "/" // TODO check need / ???
            
        case .getLead(let userID, let type, let offset, _):
            prefix = kPMAPICOACHES + userID + type + "\(offset)"
            
        case .setCurrentLead:
            prefix = kPMAPICOACHES + currentUserID + kPMAPICOACH_CURRENT + "/"
            
        case .setOldLead:
            prefix = kPMAPICOACHES + currentUserID + kPMAPICOACH_OLD + "/"
            
        case .searchCoachNearby(_, let tags, _, _, _, _, _, _):
            prefix = kPMAPICOACH_SEARCHV3
            if (tags.count > 0) {
                var index = 0
                for id in tags {
                    if (index == 0) {
                        prefix = prefix + "?"
                    } else {
                        prefix = prefix + "&"
                    }
                    
                    index = index + 1
                    
                    prefix = prefix + "tagIds=\(id)"
                }
            }
            
        case .getUserList(let offset, _):
            prefix = kPMAPIUSER_OFFSET + "\(offset)"
            
        case .getSearhUserList:
            prefix = kPMAPISEARCHUSER
            
        }
        
        return prefix
    }
    
    var param : [String: AnyObject]? {
        var param : [String : AnyObject] = [:]
        let currentUserID = PMHelper.getCurrentID()
        
        switch self {
        case .changeCurrentUserInfo(_, let parameter, _):
            for (key, value) in parameter {
                param[key] = value as AnyObject
            }
            
        case .changeCurrentCoachInfo(_, let parameter, _):
            for (key, value) in parameter {
                param[key] = value as AnyObject
            }
            
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
            
        case .login(let email, let password, _):
            param[kEmail] = email as AnyObject
            param[kPassword] = password as AnyObject
            
        case .changePassword(let currentPassword, let newPassword, _):
            param[kPassword] = currentPassword as AnyObject
            param[kPasswordNew] = newPassword as AnyObject
            
        case .forgotPassword(let email, _):
            param[kEmail] = email as AnyObject
            
        case .checkConnect(let coachID, _):
            param[kUserId] = currentUserID as AnyObject
            param[kCoachId] = coachID as AnyObject
            
        case .setLead(let coachID, _):
            param[kUserId] = currentUserID as AnyObject
            param[kCoachId] = coachID as AnyObject
            
        case .setCurrentLead(let requestID, _):
            param[kUserId] = currentUserID as AnyObject
            param[kUserIdRequest] = requestID as AnyObject
            
        case .setOldLead(let requestID, _):
            param[kUserId] = currentUserID as AnyObject
            param[kUserIdRequest] = requestID as AnyObject
            
        case .searchCoachNearby(let gender, _, let longitude, let latitude, let stage, let city, let offset, _):
            param[kGender] = gender as AnyObject
            param[kLimit] = 30 as AnyObject
            param[kOffset] = offset as AnyObject
            param[kLong] = longitude as AnyObject
            param[kLat] = latitude as AnyObject
            param[kState] = stage as AnyObject
            param[kCity] = city as AnyObject
            
        case .getSearhUserList(let offet, let character, _):
            param[kOffset] = offet as AnyObject
            param["character"] = character as AnyObject
            
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
        case .getCurrentUserInfo, .getUserInfo, .getCoachInfo:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
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
            
        case .changeCurrentUserInfo:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 2")
                
                if (response.response?.statusCode == 200) {
                    self.comletedBlock!(true as AnyObject, nil)
                } else if (response.response?.statusCode == 401) {
                    PMHelper.showLogoutAlert()
                } else {
                    let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                    self.comletedBlock!(false as AnyObject, error as NSError)
                }
            })
            
        case .changeCurrentCoachInfo:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 3")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
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
            
        case .checkCoachOfUser:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 4")
                
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
                print("PM: UserRouter 5")
                
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
                print("PM: UserRouter 6")
                
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
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 7")
                
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
                print("PM: UserRouter 8")
                
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
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 9")
                
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
            
        case .getUserTagList:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter User_Tag_List")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let tagDetails = JSON as! [NSDictionary]
                        
                        var tagList: [TagModel] = []
                        for tagDetail in tagDetails {
                            let tag = TagModel()
                            tag.parseData(data: tagDetail)
                            
                            tagList.append(tag)
                        }
                        
                        self.comletedBlock!(tagList as AnyObject, nil)
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
            
        case .getPhotoList:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter 11")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let photoList = JSON as! NSArray
                        
                        self.comletedBlock!(photoList as AnyObject, nil)
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
                print("PM: UserRouter signup")
                
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
                    } else {
                        self.comletedBlock!(false as AnyObject, error as NSError)
                    }
                }
            })
            
        case .login:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter login")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        UserRouter.saveCurrentUserInfo(response: response)
                        
                        // TODO : need check
                        let userTotalInfo = JSON as! NSDictionary
                        if let userinfo = userTotalInfo.object(forKey: "user") as? NSDictionary {
                            let currentUserID = PMHelper.getCurrentID()
                            
                            let mixpanel = Mixpanel.sharedInstance()
                            if mixpanel?.distinctId != "" {
                                mixpanel?.identify(currentUserID)
                            } else {
                                mixpanel?.createAlias(currentUserID, forDistinctID: (mixpanel?.distinctId)!)
                                mixpanel?.identify((mixpanel?.distinctId)!)
                            }
                            
                            if let nameUser = userinfo.object(forKey: kFirstname) as? String {
                                mixpanel?.people.set("$name", to: nameUser)
                            }
                            
                            if let mailUser = userinfo[kEmail] as? String {
                                mixpanel?.people.set("$email", to: mailUser)
                            }
                        }
                        
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
                    } else {
                        self.comletedBlock!(false as AnyObject, error as NSError)
                    }
                }
            })
            
        case .changePassword:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter change_password")
                
                switch response.result {
                case .success(_):
                    self.comletedBlock!(true as AnyObject, nil)
                case .failure(let error):
                    self.comletedBlock!(false as AnyObject, error as NSError)
                }
            })
            
        case .forgotPassword:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter forgot_password")
                
                switch response.result {
                case .success(_):
                    self.comletedBlock!(true as AnyObject, nil)
                case .failure(let error):
                    self.comletedBlock!(false as AnyObject, error as NSError)
                }
            })
            
        case .checkConnect:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseString(completionHandler: { (response) in
                print("PM: UserRouter check_connect")
                
                self.comletedBlock!(response.result.value as AnyObject, nil)
            })
            
        case .setLead:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter set_lead")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
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
            
        case .getLead:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter get_lead")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let result = JSON as! [NSDictionary]
                        
                        self.comletedBlock!(result, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(nil, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 400) {
                        let error = NSError(domain: "Error", code: 400, userInfo: nil) // Create duplicate emial error
                        self.comletedBlock!(nil, error as NSError)
                    } else if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(nil, error as NSError)
                    }
                }
            })
            
        case .setCurrentLead:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter set_current_lead")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        self.comletedBlock!(true, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(false, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(false, error as NSError)
                    }
                }
            })
            
        case .setOldLead:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter set_old_lead")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        self.comletedBlock!(true, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock!(false, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock!(false, error as NSError)
                    }
                }
            })
            
        case .searchCoachNearby:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter search_coach_nearby")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let coachDetails = JSON as? [NSDictionary]
                        
                        self.comletedBlock!(coachDetails, nil)
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
            
        case .getUserList:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter get_user_list")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let coachDetails = JSON as? [NSDictionary]
                        
                        self.comletedBlock!(coachDetails, nil)
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
            
        case .getSearhUserList:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: UserRouter get_search_user_list")
                
                switch response.result {
                case .success(let JSON):
                    if (JSON is NSNull == false) {
                        let coachDetails = JSON as? [NSDictionary]
                        
                        self.comletedBlock!(coachDetails, nil)
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
            
        }
    }
    
    static func saveCurrentUserInfo(response: DataResponse<Any>) {
        let defaults = UserDefaults.standard
        
        // Save access token here
        let JSON = response.result.value as! NSDictionary
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
            Alamofire.request(linkPostNotif, method: .post, parameters: param)
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
    
    static func updateCookies(response: DataResponse<Any>) {
        let defaults = UserDefaults.standard
        
        if let
            headerFields = response.response?.allHeaderFields as? [String: String],
            let URL = response.request?.url {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
            // Set the cookies back in our shared instance. They'll be sent back with each subsequent request.
            
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL, mainDocumentURL: nil)
            defaults.set(headerFields, forKey: k_PM_HEADER_FILEDS)
            defaults.set(URL.absoluteString, forKey: k_PM_URL_LAST_COOKIE)
        }
    }
    
}
