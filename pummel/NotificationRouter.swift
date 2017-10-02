//
//  NotificationRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 7/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import Alamofire

enum NotificationRouter: URLRequestConvertible {
    case getNotificationBadge(completed: CompletionBlock)
    case resetSBadge(completed: CompletionBlock)
    case resetLBadge(completed: CompletionBlock)
    case resetCBadge(completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getNotificationBadge(let completed):
            return completed
        case .resetSBadge(let completed):
            return completed
        case .resetLBadge(let completed):
            return completed
        case .resetCBadge(let completed):
            return completed
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getNotificationBadge:
            return .get
        case .resetSBadge:
            return .put
        case .resetLBadge:
            return .put
        case .resetCBadge:
            return .put
        }
    }
    
    var path: String {
        let currentUserID = PMHelper.getCurrentID()
        
        var prefix = ""
        switch self {
        case .getNotificationBadge(_):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_M_BADGE_S_BADGE
            
        case .resetSBadge(_):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_RESET_S_BADGE
            
        case .resetLBadge(_):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_RESET_L_BADGE
            
        case .resetCBadge(_):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_RESET_C_BADGE
        }
    
        return prefix
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
        case .getNotificationBadge:
            Alamofire.request(self.URLRequest as! URLRequestConvertible).responseJSON(completionHandler: { (response) in
                print("PM: NotificationRouter 1")
                
                switch response.result {
                case .success(let JSON):
                    // [Message] [Session] [Lead] [Comment]
                    
                    let result = JSON as! NSArray
                    
                    self.comletedBlock(result, nil)
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .resetSBadge, .resetLBadge, .resetCBadge:
            Alamofire.request(self.URLRequest as! URLRequestConvertible).responseJSON(completionHandler: { (response) in
                print("PM: NotificationRouter 2")
                
                if (response.response?.statusCode == 401) {
                    PMHelper.showLogoutAlert()
                } else {
                    self.comletedBlock(nil, nil)
                }
            })
        }
    }
}
