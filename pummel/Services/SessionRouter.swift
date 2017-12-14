//
//  SessionRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/5/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

enum SessionRouter: URLRequestConvertible {
    case getSessionList(offset: Int, completed: CompletionBlock)
    
    case getUpcommingSession(offset: Int, completed: CompletionBlock)
    
    case postLogSession(userID: String, targetUserID: String?, message: String, type: String, intensity: String, distance: String, longtime: String, calorie: String, dateTime: String, imageData: Data, completed: CompletionBlock)
    
    case editLogSession(sessionID: String, message: String, intensity: String, distance: String, longtime: String, calorie: String, dateTime: String, completed: CompletionBlock)
    
    case postBookSession(userID: String, targetUserID: String?, message: String, type: String, dateTime: String, imageData: Data, completed: CompletionBlock)
    
    case deleteSession(sessionID: String, completed: CompletionBlock)
    
    case getGroupInfo(groupType: TypeGroup, offset: Int, completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getSessionList(_, let completed):
            return completed
            
        case .getUpcommingSession(_, let completed):
            return completed
            
        case .postLogSession(_, _, _, _, _, _, _, _, _, _, let completed):
            return completed
            
        case .editLogSession(_, _, _, _, _, _, _, let completed):
            return completed
            
        case .postBookSession(_, _, _, _, _, _, let completed):
            return completed
            
        case .deleteSession(_, let completed):
            return completed
            
        case .getGroupInfo(_, _, let completed):
            return completed
            
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getSessionList:
            return .get
            
        case .getUpcommingSession:
            return .get
            
        case .postLogSession:
            return .post
            
        case .editLogSession:
            return .put
            
        case .postBookSession:
            return .post
            
        case .deleteSession:
            return .post
            
        case .getGroupInfo:
            return .get
            
        }
    }
    
    var path: String {
        let currentUserID = PMHelper.getCurrentID()
        
        var prefix = ""
        switch self {
        case .getSessionList(let offset, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_ACTIVITIES_USER + "\(offset)"
            
        case .getUpcommingSession:
            prefix = kPMAPIUSER + currentUserID + "/upcommingActivities"
            
        case .postLogSession(let userID, let targetUserID, _, _, _, _, _, _, _, _, _):
            if (targetUserID != nil && targetUserID?.isEmpty == false) {
                prefix = kPMAPICOACH + userID + kPM_PATH_LOG_ACTIVITIES_COACH
            } else {
                prefix = kPMAPIUSER + userID + kPM_PATH_LOG_ACTIVITIES_USER
            }
            
        case .editLogSession(let sessionID, _, _, _, _, _, _, _):
            prefix = kPMAPIACTIVITY + sessionID + kPM_PATH_UPDATE
            
        case .postBookSession(let userID, _, _, _, _, _, _):
            prefix = kPMAPICOACHES + userID + kPMAPICOACH_BOOK
            
        case .deleteSession(let sessionID, _):
            prefix = kPMAPIUSER + currentUserID + "/activities/" + sessionID + "/delete"
            
        case .getGroupInfo(let groupType, _, _):
            prefix = kPMAPICOACHES
            if groupType == .CoachJustConnected ||
                groupType == .CoachCurrent ||
                groupType == .CoachOld {
                prefix = kPMAPIUSER
            }
            
            prefix = prefix + currentUserID
            
            if groupType == .NewLead {
                prefix = prefix + kPM_PATH_LEADS
            } else if groupType == .Current {
                prefix = prefix + kPM_PATH_CURRENT
            } else if groupType == .Old {
                prefix = prefix + kPM_PATH_OLD
            } else if groupType == .CoachJustConnected {
                prefix = prefix + kPM_PATH_JUSTCONNECTED
            } else if groupType == .CoachCurrent {
                prefix = prefix + kPM_PATH_COACHCURRENT
            } else if groupType == .CoachOld {
                prefix = prefix + kPM_PATH_COACHOLD
            }
        }
        
        return prefix
    }
    
    var param: [String : Any]? {
        let currentUserID = PMHelper.getCurrentID()
        
        var param: [String : Any]? = [:]
        
        switch self {
        case .getUpcommingSession(let offset, _):
            param?[kUserId] = currentUserID
            param?[kOffset] = offset
            param?[kLimit] = 20
            param?["currentDate"] = Date()
            
        case .postLogSession(let userID, let targetUserID, let message, let type, let intensity, let distance, let longtime, let calorie, let dateTime, _, _):
            param?[kUserId] = userID
            param?[kUserIdTarget] = targetUserID
            param?[kText] = message
            param?[kType] = type
            param?[kIntensity] = intensity
            param?[kDistance] = distance
            param?[kLongtime] = longtime
            param?[kCalorie] = calorie
            param?[kDatetime] = dateTime
            
        case .editLogSession(let sessionID, let message, let intensity, let distance, let longtime, let calorie, let dateTime, _):
            param?[kActivityId] = sessionID
            param?[kText] = message
            param?[kIntensity] = intensity
            param?[kDistance] = distance
            param?[kLongtime] = longtime
            param?[kCalorie] = calorie
            param?[kDatetime] = dateTime
            
        case .postBookSession(let userID, let targetUserID, let message, let type, let dateTime, _, _):
            param?[kUserId] = userID
            param?[kUserIdTarget] = targetUserID
            param?[kText] = message
            param?[kType] = type
            param?[kDatetime] = dateTime

        case .deleteSession(let sessionID):
            param?[kUserId] = currentUserID
            param?[kActivityId] = sessionID
            
        case .getGroupInfo(_, let offset, _):
            param?[kUserId] = currentUserID
            param?[kOffset] = offset
            param?[kLimit] = 20
            
            
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
    
    var imageData: Data? {
        var data: Data?
        
        switch self {
        case .postLogSession(_, _, _, _, _, _, _, _, _, let imageData, _):
            data = imageData
        
        case .postBookSession(_, _, _, _, _, let imageData, _):
            data = imageData
            
            
        default:
            break
            
        }
        
        return data
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
        case .getSessionList:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: SessionRouter get_session_list")
                
                switch response.result {
                case .success(let JSON):
                    let sessionInfos = JSON as! [NSDictionary]
                    
                    self.comletedBlock(sessionInfos, nil)
                case .failure(let error):
                    self.comletedBlock(nil, error as NSError)
                }
            })
            
        case .getUpcommingSession:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: SessionRouter get_upcomming_session")
                
                switch response.result {
                case .success(let JSON):
                    let sessionInfos = JSON as! [NSDictionary]
                    
                    self.comletedBlock(sessionInfos, nil)
                case .failure(let error):
                    self.comletedBlock(nil, error as NSError)
                }
            })
            
        case .postLogSession:
            let filename = jpgeFile
            let type = imageJpeg
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(self.imageData!, withName: "file", fileName: filename, mimeType: type)
                
                for (key, value) in self.param! {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to: self.path, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print("PM: SessionRouter post_log")
                        
                        switch response.result {
                        case .success( _):
                            self.comletedBlock(true, nil)
                        case .failure(let error):
                            if (response.response?.statusCode == 401) {
                                PMHelper.showLogoutAlert()
                            } else {
                                self.comletedBlock(false, error as NSError)
                            }
                        }
                    }
                case .failure(_):
                    let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                    self.comletedBlock(false, error)
                }
            })
            
        case .editLogSession:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: SessionRouter edit_log")
                
                if response.response?.statusCode == 200 {
                    self.comletedBlock(true, nil)
                } else if (response.response?.statusCode == 401) {
                    PMHelper.showLogoutAlert()
                } else {
                    self.comletedBlock(false, nil)
                }
            })
            
        case .postBookSession:
            let filename = jpgeFile
            let type = imageJpeg
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(self.imageData!, withName: "file", fileName: filename, mimeType: type)
                
                for (key, value) in self.param! {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to: self.path, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print("PM: SessionRouter post_book")
                        
                        switch response.result {
                        case .success( _):
                            self.comletedBlock(true, nil)
                        case .failure(let error):
                            if (response.response?.statusCode == 401) {
                                PMHelper.showLogoutAlert()
                            } else {
                                self.comletedBlock(false, error as NSError)
                            }
                        }
                    }
                case .failure(_):
                    let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                    self.comletedBlock(false, error)
                }
            })
            
        case .deleteSession:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: SessionRouter delete_session")
                
                if response.response?.statusCode == 200 {
                    self.comletedBlock(true, nil)
                } else if (response.response?.statusCode == 401) {
                    PMHelper.showLogoutAlert()
                } else {
                    let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                    self.comletedBlock(false, error)
                }
            })

        case .getGroupInfo:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: SessionRouter get_group_info")
                
                switch response.result {
                case .success(let JSON):
                    let groupInfo = JSON as! [NSDictionary]
                    self.comletedBlock(groupInfo, nil)
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        }
    }
}
