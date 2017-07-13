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
    case getMBadgeSBadge(completed: CompletionBlock)
    case resetSBadge(completed: CompletionBlock)
    case decreaseMBadge(completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getMBadgeSBadge(let completed):
            return completed
        case .resetSBadge(let completed):
            return completed
        case .decreaseMBadge(let completed):
            return completed
        }
    }
    
    var method: Alamofire.Method {
        switch self {
        case .getMBadgeSBadge:
            return .GET
        case .resetSBadge:
            return .PUT
        case .decreaseMBadge:
            return .PUT
        }
    }
    
    var path: String {
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentUserID = defaults.objectForKey(k_PM_CURRENT_ID) as! String
        
        var prefix = ""
        switch self {
        case .getMBadgeSBadge(_):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_M_BADGE_S_BADGE
            
        case .resetSBadge(_):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_RESET_S_BADGE
            
        case .decreaseMBadge(_):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_DECREASE_M_BADGE
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
        case .getMBadgeSBadge:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success(let JSON):
                    let result = JSON as! NSArray
                    
                    self.comletedBlock(result: result, error: nil)
                case .Failure(let error):
                    self.comletedBlock(result: nil, error: error)
                }
            })
            
        case .resetSBadge, .decreaseMBadge:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                if response.response?.statusCode == 200 {
                    self.comletedBlock(result: true, error: nil)
                } else {
                    self.comletedBlock(result: false, error: nil)
                }
            })
        }
    }
}
