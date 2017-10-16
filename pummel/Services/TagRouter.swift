//
//  TagRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/4/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

enum TagRouter: URLRequestConvertible {
    static var specialColor = TagRouter.getRandomColorString()
    
    case getTagList(offset: Int, completed: CompletionBlock)
    case selectTag(tagID: String, completed: CompletionBlock)
    case deleteTag(tagID: String, completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getTagList(_, let completed):
            return completed
            
        case .selectTag(_, let completed):
            return completed
            
        case .deleteTag(_, let completed):
            return completed
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getTagList:
            return .get
            
        case .selectTag:
            return .post
            
        case .deleteTag:
            return .delete
            
            
        }
    }
    
    var path: String {
        let currentUserID = PMHelper.getCurrentID()
        
        var prefix = ""
        switch self {
        case .getTagList(let offset, _):
            prefix = kPMAPI_TAG_OFFSET + String(offset)
            
        case .selectTag:
            prefix = kPMAPIUSER + currentUserID + "/tags"
            
        case .deleteTag(let tagID, _):
            prefix = kPMAPIUSER + currentUserID + "/tags/" + tagID
            
        }
        
        return prefix
    }
    
    var param: [String : Any]? {
        let currentUserID = PMHelper.getCurrentID()
        
        var param: [String : Any]? = [:]
        switch self {
        case .selectTag(let tagID, _):
            param?[kUserId] = currentUserID
            param?["tagId"] = tagID
            
        case .deleteTag(let tagID, _):
            param?[kUserId] = currentUserID
            param?["tagId"] = tagID
            
            
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
        case .getTagList:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: TagRouter get_all_tag")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        var tagList: [TagModel] = []
                        
                        let tagDetails = JSON as! [NSDictionary]
                        
                        for tagDetail in tagDetails {
                            let tag = TagModel()
                            tag.parseData(data: tagDetail)
                            
                            // Special tag: "body building", "Cycling"
                            if (tag.tagTitle?.uppercased() == kBodyBuilding ||
                                tag.tagTitle?.uppercased() == kCycling) {
                                tag.tagColor = TagRouter.specialColor
                            } else {
                                tag.tagColor = TagRouter.getRandomColorString()
                            }
                            
                            tagList.append(tag)
                        }
                        
                        self.comletedBlock(tagList as AnyObject, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .selectTag, .deleteTag:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: TagRouter select_tag / delete_tag")
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 200 {
                        self.comletedBlock(true, nil)
                    } else {
                        self.comletedBlock(false, nil)
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
    
    static func getRandomColorString() -> String {
        
        let randomRed: CGFloat = CGFloat(drand48())
        let randomGreen: CGFloat = CGFloat(drand48())
        let randomBlue: CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed * 255), Int(randomGreen * 255),Int(randomBlue * 255), 255)
    }
}
