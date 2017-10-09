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
    case postLogSession(userID: String, targetUserID: String?, message: String, type: String, intensity: String, distance: String, longtime: String, calorie: String, dateTime: String, imageData: Data, completed: CompletionBlock)
    
    case editLogSession(sessionID: String, message: String, intensity: String, distance: String, longtime: String, calorie: String, dateTime: String, completed: CompletionBlock)
    
    case postBookSession(userID: String, targetUserID: String?, message: String, type: String, dateTime: String, imageData: Data, completed: CompletionBlock)
    
    case deleteSession(sessionID: String, completed: CompletionBlock)
    
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .postLogSession(_, _, _, _, _, _, _, _, _, _, let completed):
            return completed
            
        case .editLogSession(_, _, _, _, _, _, _, let completed):
            return completed
            
        case .postBookSession(_, _, _, _, _, _, let completed):
            return completed
            
        case .deleteSession(_, let completed):
            return completed
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .postLogSession:
            return .post
            
        case .editLogSession:
            return .put
            
        case .postBookSession:
            return .post
            
        case .deleteSession:
            return .post
            
            
            
        }
    }
    
    var path: String {
        let currentUserID = PMHelper.getCurrentID()
        
        var prefix = ""
        switch self {
        case .postLogSession(let userID, let targetUserID, _, _, _, _, _, _, _, _, _):
            if (targetUserID != nil && targetUserID?.isEmpty == false) {
                prefix = kPMAPICOACH + userID + kPM_PATH_LOG_ACTIVITIES_COACH
            } else {
                prefix = kPMAPIUSER + userID + kPM_PATH_LOG_ACTIVITIES_USER
            }
            
        case .editLogSession(let sessionID, _, _, _, _, _, _, _):
            prefix = kPMAPIACTIVITY + sessionID
            
        case .postBookSession(let userID, _, _, _, _, _, _):
            prefix = kPMAPICOACHES + userID + kPMAPICOACH_BOOK
            
        case .deleteSession:
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_DELETEACTIVITY
            
        }
        
        return prefix
    }
    
    var param: [String : Any]? {
        var param: [String : Any]? = [:]
        
        switch self {
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
            param?[kActivityId] = sessionID
            
            
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
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 200 {
                        self.comletedBlock(true, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(false, error as NSError)
                    }
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
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 200 {
                        self.comletedBlock(true, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(false, error as NSError)
                    }
                }
            })

            
        }
    }
}
