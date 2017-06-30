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
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getCurrentUserInfo(let completed):
            return completed
        case .getUserInfo(_, let completed):
            return completed
        case .checkCoachOfUser(_, let completed):
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
        }
    }
    
    var path: String {
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentUserID = defaults.objectForKey(k_PM_CURRENT_ID) as! String
        
        var prefix = ""
        switch self {
        case .getCurrentUserInfo:
            prefix = kPMAPIUSER + currentUserID
            
        case .getUserInfo(let userID, _):
            prefix = kPMAPIUSER + userID
            
        case .checkCoachOfUser(let userID, _):
            prefix = kPMAPICOACH + userID
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
        case .getCurrentUserInfo, .getUserInfo:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success(let JSON):
                    let userDetail = JSON as! NSDictionary
                    
                    self.comletedBlock(result: userDetail, error: nil)
                case .Failure(let error):
                    self.comletedBlock(result: nil, error: error)
                }
            })
            
        case checkCoachOfUser:
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
