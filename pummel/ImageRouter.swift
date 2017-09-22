//
//  ImageRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/6/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Mixpanel
import Alamofire
import Foundation

typealias CompletionBlock = (result: AnyObject?, error: NSError?) -> Void
//typealias ResponseCompletionBlock = (response:  Response<AnyObject, NSError>, error: NSError?) -> Void

enum ImageRouter: URLRequestConvertible {
    case getCurrentUserAvatar(sizeString: String, completed: CompletionBlock)
    case getUserAvatar(userID : String, sizeString: String, completed: CompletionBlock)
    case getCoachAvatar(coachID : String, sizeString: String, completed: CompletionBlock)
    case getBusinessLogo(businessID : String, sizeString: String, completed: CompletionBlock)
    case getImage(imageURLString: String, sizeString: String, completed: CompletionBlock)
    
    var imageSize: String {
        switch self {
        case .getCurrentUserAvatar(let sizeString, _):
            return sizeString
        case .getUserAvatar(_, let sizeString, _):
            return sizeString
        case .getCoachAvatar(_, let sizeString, _):
            return sizeString
        case .getBusinessLogo(_, let sizeString, _):
            return sizeString
        case .getImage(_, let sizeString, _):
            return sizeString
        }
    }
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getCurrentUserAvatar(_, let completed):
            return completed
        case .getUserAvatar(_, _, let completed):
            return completed
        case .getCoachAvatar(_, _, let completed):
            return completed
        case .getBusinessLogo(_, _, let completed):
            return completed
        case .getImage(_, _, let completed):
            return completed
        }
    }
    
    var method: Alamofire.Method {
        switch self {
        case .getCurrentUserAvatar:
            return .GET
        case .getUserAvatar:
            return .GET
        case .getCoachAvatar:
            return .GET
        case .getBusinessLogo:
            return .GET
        case .getImage:
            return .GET
        }
    }
    
    var path: String {
        let currentUserID = PMHelper.getCurrentID()
        
        var prefix = ""
        switch self {
        case .getCurrentUserAvatar:
            prefix = kPMAPIUSER + currentUserID
            
        case .getUserAvatar(let userID, _, _):
            prefix = kPMAPIUSER + userID
            
        case .getCoachAvatar(let coachID, _, _):
            prefix = kPMAPICOACH + coachID
            
        case .getBusinessLogo(let businessID, _, _):
            prefix = kPMAPI_BUSINESS + businessID
            
        case .getImage(let imageURLString, let sizeString, _):
            if (imageURLString.isEmpty == false) {
                if (imageURLString.contains("scontent.xx.fbcdn.net")) {
                    prefix = imageURLString
                } else {
                    prefix = kPMAPI + imageURLString + sizeString
                }
            } else {
                prefix = ""
            }
        }
        
        return prefix
    }
    
    // MARK: URLRequestConvertible
    var URLRequest: NSMutableURLRequest {
        //        let mutableURLRequest = NSMutableURLRequest.create(path, method: method.rawValue)!
        let url = NSURL(string: self.path)
        
        let mutableURLRequest = NSMutableURLRequest(URL: url!)
        mutableURLRequest.HTTPMethod = self.method.rawValue
        
        return mutableURLRequest
    }
    
    func fetchdata() {
        switch self {
        case .getCurrentUserAvatar, .getUserAvatar, .getCoachAvatar, .getBusinessLogo:
            Alamofire.request(self.URLRequest).responseJSON(completionHandler: { (response) in
                print("PM: ImageRouter 1")
                switch response.result {
                case .Success(let JSON):
                    if response.response?.statusCode == 200 {
                        let userDetail = JSON as! NSDictionary
                        
                        if (userDetail[kImageUrl] is NSNull == false) {
                            let imageURLString = userDetail[kImageUrl] as! String
                            
                            ImageRouter.getImage(imageURLString: imageURLString, sizeString: self.imageSize, completed: { (result, error) in
                                self.comletedBlock(result: result, error: error)
                            }).fetchdata()
                        } else {
                            let defaultImage = UIImage(named: "display-empty.jpg")
                            self.comletedBlock(result:  defaultImage, error: nil)
                        }
                    }
                case .Failure(let error):
                    // check status code 401 : cookie expire
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(result:  nil, error: error)
                    }
                }
            })
        case .getImage:
            if (self.path.isEmpty == false) {
                let image = self.getCacheImageWithLink(self.path)
                if (image != nil) {
                    self.comletedBlock(result: image, error: nil)
                } else {
                    Alamofire.request(.GET, self.path).responseImage { response in
                        print("PM: ImageRouter 2")
                        
                        if (response.result.isSuccess) {
                            let imageRes = response.result.value! as UIImage
                            NSCache.sharedInstance.setObject(imageRes, forKey: self.path)
                            
                            self.comletedBlock(result: imageRes, error: nil)
                        } else {
                            let error = NSError(domain: "Pummel", code: 1000, userInfo: nil) // simple error
                            self.comletedBlock(result: nil, error: error)
                        }
                    }
                }
            } else {
                let error = NSError(domain: "Pummel", code: 500, userInfo: nil) // Simple error
                self.comletedBlock(result: nil, error: error)
            }
        }
    }
    
    func getCacheImageWithLink(link: String) -> UIImage?  {
        if (NSCache.sharedInstance.objectForKey(link) != nil) {
            let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
            return imageRes
        }
        
        return nil
    }
}
