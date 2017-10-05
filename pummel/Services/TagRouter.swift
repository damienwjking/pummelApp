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
    static var specialColor = self.getRandomColorString()
    
    case getTagList(offset: Int, completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getTagList(_, let completed):
            return completed
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getTagList:
            return .get
            
            
        }
    }
    
    var path: String {
        var prefix = ""
        switch self {
        case .getTagList(let offset, _):
            prefix = kPMAPI_TAG_OFFSET + String(offset)
            
            
        }
        
        return prefix
    }
    
    var param: [String : Any]? {
        let param: [String : Any]? = [:]
        
        switch self {
//        case .reportFeed(let postID, _):
//            param?[kPostId] = postID
//            
            
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
            Alamofire.request(self.URLRequest as! URLRequestConvertible).responseJSON(completionHandler: { (response) in
                print("PM: TagRouter 1")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        var tagList: [TagModel] = []
                        
                        let tagDetails = JSON as! [NSDictionary]
                        
                        for tagDetail in tagDetails {
                            let tag = TagModel()
                            
                            tag.name = tagDetail[kTitle] as? String
                            tag.tagId = String(format:"%0.f", (tagDetail[kId]! as AnyObject).doubleValue)
                            tag.tagType = (tagDetail[kType] as? NSNumber)?.intValue
                            
                            // Special tag: "body building", "Cycling"
                            if (tag.name?.uppercased() == kBodyBuilding ||
                                tag.name?.uppercased() == kCycling) {
                                tag.tagColor = TagRouter.specialColor
                            } else {
                                tag.tagColor = self.getRandomColorString()
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
            
        }
    }
    
    func getRandomColorString() -> String {
        
        let randomRed: CGFloat = CGFloat(drand48())
        let randomGreen: CGFloat = CGFloat(drand48())
        let randomBlue: CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed * 255), Int(randomGreen * 255),Int(randomBlue * 255), 255)
    }
}
