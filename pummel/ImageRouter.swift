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
    case currentUserUploadAvatar(imageData: NSData, completed: CompletionBlock)
    
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
        case .currentUserUploadAvatar:
            return ""
            
        }
    }
    
    var imageData: NSData? {
        var data: NSData? = nil
        switch self {
        case .currentUserUploadAvatar(let imageData, _):
            data = imageData
            
        default:
            break
        }
        
        return data
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
        case .currentUserUploadAvatar(_, let completed):
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
        case .currentUserUploadAvatar:
            return .POST
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
            
        case .currentUserUploadAvatar:
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_PHOTO_PROFILE
            
        }
        
        return prefix
    }
    
    var param : [String: AnyObject]? {
        var param : [String : AnyObject] = [:]
        let currentUserID = PMHelper.getCurrentID()
        
        switch self {
        case .currentUserUploadAvatar:
            param[kUserId] = currentUserID
            param[kProfilePic] = "1"
            
        default:
            break
            
        }
        
        return param
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
                    } else {
                        let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                        self.comletedBlock(result:  nil, error: error)
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
            
        case .currentUserUploadAvatar:
            let filename = jpgeFile
            let type = imageJpeg
            
            Alamofire.upload(self.method, self.path,
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: self.imageData!, name: "file", fileName:filename, mimeType:type)
                    
                    for (key, value) in self.param! {
                        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                    }
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            if (response.result.isSuccess) {
                                self.comletedBlock(result: true, error: nil)
                            } else {
                                let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                                self.comletedBlock(result: false, error: error)
                            }
                        }
                        
                    case .Failure(_):
                        let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                        self.comletedBlock(result: false, error: error)
                    }
                }
            )
            
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
