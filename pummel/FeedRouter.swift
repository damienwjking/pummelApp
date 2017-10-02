//
//  FeedRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/12/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

enum FeedRouter: URLRequestConvertible {
    case getListFeed(offset: Int, completed: CompletionBlock)
    case getAndCheckFeedLike(feedID : String, completed: CompletionBlock)
    case reportFeed(postID: String, completed: CompletionBlock)
    case getLikePost(postID: String, completed: CompletionBlock)
    case sendLikePost(postID: String, completed: CompletionBlock)
    case getDiscount(longitude: CLLocationDegrees?, latitude: CLLocationDegrees?, state: String?, country: String?, offset: Int, completed: CompletionBlock)
    case getComment(postID: String, offset: Int, limit: Int, completed: CompletionBlock)

    var comletedBlock: CompletionBlock {
        switch self {
        case .getListFeed(_, let completed):
            return completed
            
        case .getAndCheckFeedLike(_, let completed):
            return completed
            
        case .reportFeed(_, let completed):
            return completed
            
        case .getLikePost(_, let completed):
            return completed
            
        case .sendLikePost(_, let completed):
            return completed
            
        case .getDiscount(_, _, _, _, _, let completed):
            return completed
            
        case .getComment(_, _, _, let completed):
            return completed
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getListFeed:
            return .get
            
        case .getAndCheckFeedLike:
            return .get
            
        case .reportFeed:
            return .put
            
        case .getLikePost:
            return .get
            
        case .sendLikePost:
            return .post
            
        case .getDiscount:
            return .get
            
        case .getComment:
            return .get
            
        }
    }
    
    var path: String {
        var prefix = ""
        switch self {
        case .getListFeed(let offset, _):
            prefix = kPMAPI_POST_OFFSET + String(offset)
            
        case .getAndCheckFeedLike(let feedID, _):
            prefix = kPMAPI_LIKE + feedID + kPM_PATH_LIKE
            
        case .reportFeed:
            prefix = kPMAPI_REPORT
            
        case .getLikePost(let postID, _):
            prefix = kPMAPI_LIKE + postID + kPM_PATH_LIKE
            
        case .sendLikePost(let postID, _):
            prefix = kPMAPI_LIKE + postID + kPM_PATH_LIKE
            
        case .getDiscount:
            prefix = kPMAPI_DISCOUNTS
            
        case .getComment(let postID, _, _, _):
            prefix = kPMAPI_POST + postID + kPM_PATH_COMMENT
            
        }
        
        return prefix
    }
    
    var param: [String : Any]? {
        var param: [String : Any]? = [:]
        
        switch self {
        case .reportFeed(let postID, _):
            param?[kPostId] = postID
            
        case .getLikePost(let postID, _):
            param?[kPostId] = postID
            
        case .sendLikePost(let postID, _):
            param?[kPostId] = postID
            
        case .getDiscount(let longitude, let latitude, let state, let country, let offset, _):
            if (longitude != nil) {
                param?[kLong] = longitude
            }
            
            if (latitude != nil) {
                param?[kLat] = latitude
            }

            if (state != nil) {
                param?[kState] = state
            }
            
            if (country != nil) {
                param?[kCountry] = country
            }
            
            param?[kOffset] = offset
            
        case .getComment(_, let offset, let limit, _):
            param?[kOffset] = offset
            param?[kLimit] = limit
            
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
        let currentUserID = PMHelper.getCurrentID()
        
        switch self {
        case .getListFeed:
            Alamofire.request(self.URLRequest as! URLRequestConvertible).responseJSON(completionHandler: { (response) in
                print("PM: FeedRouter 1")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let userDetail = JSON as! [NSDictionary]
                        
                        self.comletedBlock(userDetail as AnyObject, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .getAndCheckFeedLike:
            Alamofire.request(self.URLRequest as! URLRequestConvertible).responseJSON(completionHandler: { (response) in
                print("PM: FeedRouter 2")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let resultDictionary = NSMutableDictionary()
                        
                        let likeJson = JSON as! NSDictionary
                        let likeNumber = String(format:"%0.f", (likeJson[kCount]! as AnyObject).doubleValue)
                        let rows = likeJson[kRows] as! [NSDictionary]
                        
                        var currentUserLiked = false
                        for row in rows {
                            let likeUserID = String(format:"%0.f", (row[kUserId]! as AnyObject).doubleValue)
                            if (likeUserID == currentUserID){
                                currentUserLiked = true
                                break
                            }
                        }
                        
                        resultDictionary["likeNumber"] = likeNumber
                        resultDictionary["currentUserLiked"] = currentUserLiked
                        
                        self.comletedBlock(resultDictionary, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .reportFeed:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: FeedRouter 3")
                
                switch response.result {
                case .success( _):
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
            
        case .getLikePost:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: FeedRouter 4")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let result = JSON as! NSDictionary
                        
                        self.comletedBlock(result, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .sendLikePost:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: FeedRouter 5")
                
                switch response.result {
                case .success( _):
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
            
        case .getDiscount:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: FeedRouter 6")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let result = JSON as! [NSDictionary]
                        
                        self.comletedBlock(result, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(false, error as NSError)
                    }
                }
            })
            
        case .getComment:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: FeedRouter 7")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let result = JSON as! [NSDictionary]
                        
                        self.comletedBlock(result, nil)
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
