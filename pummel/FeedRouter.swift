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
    case getAndCheckFeedLike(feedID : String, completed: CompletionBlock)
    case reportFeed(param: [String : AnyObject]?, completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getListFeed(_, let completed):
            return completed
        case .getAndCheckFeedLike(_, let completed):
            return completed
        case .reportFeed(_, let completed):
            return completed
        }
    }
    
    var method: Alamofire.Method {
        switch self {
        case .getListFeed:
            return .GET
        case .getAndCheckFeedLike:
            return .GET
        case .reportFeed:
            return .PUT
        }
    }
    
    var path: String {
        var prefix = ""
        switch self {
        case .getListFeed(let offset, _):
            prefix = kPMAPI_POST_OFFSET + String(offset)
            
        case .getAndCheckFeedLike(let feedID, _):
            prefix = kPMAPI_LIKE + feedID + kPM_PATH_LIKE
            
        case .reportFeed(_, _):
            prefix = kPMAPI_REPORT
        }
        
        return prefix
    }
    
    var param: [String : AnyObject]? {
        switch self {
        case .reportFeed(let param, _):
            return param
        default:
            return nil
        }
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
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentUserID = defaults.objectForKey(k_PM_CURRENT_ID) as! String
        
        switch self {
        case .getListFeed:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success(let JSON):
                    if response.response?.statusCode == 200 {
                        let userDetail = JSON as! [NSDictionary]
                        
                        self.comletedBlock(result: userDetail, error: nil)
                    }
                case .Failure(let error):
                    self.comletedBlock(result: nil, error: error)
                }
            })
            
        case .getAndCheckFeedLike:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success(let JSON):
                    if response.response?.statusCode == 200 {
                        let resultDictionary = NSMutableDictionary()
                        
                        let likeJson = JSON as! NSDictionary
                        let likeNumber = String(format:"%0.f", likeJson[kCount]!.doubleValue)
                        let rows = likeJson[kRows] as! [NSDictionary]
                        
                        var currentUserLiked = false
                        for row in rows {
                            let likeUserID = String(format:"%0.f", row[kUserId]!.doubleValue)
                            if (likeUserID == currentUserID){
                                currentUserLiked = true
                                break
                            }
                        }
                        
                        resultDictionary["likeNumber"] = likeNumber
                        resultDictionary["currentUserLiked"] = currentUserLiked
                        
                        self.comletedBlock(result: resultDictionary, error: nil)
                    }
                case .Failure(let error):
                    self.comletedBlock(result: nil, error: error)
                }
            })
            
        case .reportFeed:
            Alamofire.request(self.method, self.path, parameters: self.param).responseJSON(completionHandler: { (response) in
                if response.response?.statusCode == 200 {
                    self.comletedBlock(result: true, error: nil)
                } else {
                    // Not expect case
                    self.comletedBlock(result: false, error: nil)
                }
            })
        }
    }
}
