//
//  FeedRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/12/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import Alamofire

enum FeedRouter: URLRequestConvertible {
    case getListFeed(offset: Int, completed: CompletionBlock)
    case getUserInfo(userID : String, completed: CompletionBlock) // delete
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getListFeed(_, let completed):
            return completed
        case .getUserInfo(_, let completed):
            return completed
        }
    }
    
    var method: Alamofire.Method {
        switch self {
        case .getListFeed:
            return .GET
        case .getUserInfo:
            return .GET
        }
    }
    
    var path: String {
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentUserID = defaults.objectForKey(k_PM_CURRENT_ID) as! String
        
        var prefix = ""
        switch self {
        case .getListFeed(let offset, _):
            prefix = kPMAPI_POST_OFFSET + String(offset)
            
        case .getUserInfo(let userID, _):
            prefix = kPMAPIUSER + userID
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
        case .getListFeed, .getUserInfo:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success(let JSON):
                    let userDetail = JSON as! [NSDictionary]
                    
                    self.comletedBlock(result: userDetail, error: nil)
                case .Failure(let error):
                    self.comletedBlock(result: nil, error: error)
                }
            })
        }
    }
}
