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
    
    var method: Alamofire.Method {
        switch self {
        case .getNotificationBadge:
            return .GET
        case .resetSBadge:
            return .PUT
        case .resetLBadge:
            return .PUT
        case .resetCBadge:
            return .PUT
        }
    }
    
    var path: String {
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentUserID = defaults.objectForKey(k_PM_CURRENT_ID) as! String
        
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
        case .getNotificationBadge:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success(let JSON):
                    // [Message] [Session] [Lead] [Comment]
                    
                    let result = JSON as! NSArray
                    
                    self.comletedBlock(result: result, error: nil)
                case .Failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHeler.showLogoutAlert()
                    } else {
                        self.comletedBlock(result: nil, error: error)
                    }
                }
            })
            
        case .resetSBadge, .resetLBadge, .resetCBadge:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                if (response.response?.statusCode == 401) {
                    PMHeler.showLogoutAlert()
                } else {
                    self.comletedBlock(result: nil, error: nil)
                }
            })
        }
    }
}
