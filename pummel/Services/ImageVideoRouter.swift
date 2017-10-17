//
//  ImageVideoRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/6/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Mixpanel
import Alamofire
import Foundation
import AlamofireImage

typealias CompletionBlock = (_ result: Any?, _ error: NSError?) -> Void
//typealias ResponseCompletionBlock = (response:  Response<AnyObject, NSError>, error: NSError?) -> Void

enum ImageVideoRouter: URLRequestConvertible {
    static let imageCache = NSCache<NSString, UIImage>()
    
    case getCurrentUserAvatar(sizeString: String, completed: CompletionBlock)
    case getUserAvatar(userID : String, sizeString: String, completed: CompletionBlock)
    case getCoachAvatar(coachID : String, sizeString: String, completed: CompletionBlock)
    case getBusinessLogo(businessID : String, sizeString: String, completed: CompletionBlock)
    case getImage(imageURLString: String, sizeString: String, completed: CompletionBlock)
    case uploadPhoto(posfix: String, imageData: Data, textPost: String, completed: CompletionBlock)
    case uploadVideo(videoData: Data, completed: CompletionBlock)
    case uploadPostImage(postID: String, imageData: Data, text: String, completed: CompletionBlock)
    
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
        case .uploadPhoto:
            return ""
        case .uploadVideo:
            return ""
        case .uploadPostImage:
            return ""
            
            
        }
    }
    
    var fileData: Data? {
        var data: Data? = nil
        switch self {
        case .uploadPhoto(_, let imageData, _, _):
            data = imageData
            
        case .uploadVideo(let videoData, _):
            data = videoData
            
        case .uploadPostImage(_, let imageData, _, _):
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
        case .uploadPhoto(_, _, _, let completed):
            return completed
        case .uploadVideo(_, let completed):
            return completed
        case .uploadPostImage(_, _, _, let completed):
            return completed
            
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getCurrentUserAvatar:
            return .get
        case .getUserAvatar:
            return .get
        case .getCoachAvatar:
            return .get
        case .getBusinessLogo:
            return .get
        case .getImage:
            return .get
        case .uploadPhoto:
            return .post
        case .uploadVideo:
            return .post
        case .uploadPostImage:
            return .post
            
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
            
        case .uploadPhoto(let posfix, _, _, _):
            prefix = kPMAPIUSER + currentUserID + posfix
            
        case .uploadVideo:
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_VIDEO
         
        case .uploadPostImage(let postID, _, _, _):
            prefix = kPMAPI_POST + postID + kPM_PATH_COMMENT
            
        }
        
        return prefix
    }
    
    var param : [String: AnyObject]? {
        var param : [String : AnyObject] = [:]
        let currentUserID = PMHelper.getCurrentID()
        
        switch self {
        case .uploadPhoto(let posfix, _, let textPost, _):
            param[kUserId] = currentUserID as AnyObject
            if (posfix == kPM_PATH_PHOTO_PROFILE) {
                param[kProfilePic] = "1" as AnyObject
            } else if (posfix == "/posts/") {
                param[kText] = textPost as AnyObject
            }
            
        case .uploadVideo:
            param[kUserId] = currentUserID as AnyObject
            param[kProfileVideo] = "1" as AnyObject
            
        case .uploadPostImage(let postID, _, let text, _):
            param[kPostId] = postID as AnyObject
            param[kText] = text as AnyObject
            
        default:
            break
            
        }
        
        return param
    }
    
    var URLRequest: NSMutableURLRequest {
        let url = NSURL(string: self.path)
        
        let mutableURLRequest = NSMutableURLRequest(url: url! as URL)
        mutableURLRequest.httpMethod = self.method.rawValue
        
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
        case .getCurrentUserAvatar, .getUserAvatar, .getCoachAvatar, .getBusinessLogo:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: ImageRouter 1")
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let userDetail = JSON as! NSDictionary
                        
                        if (userDetail[kImageUrl] is NSNull == false) {
                            let imageURLString = userDetail[kImageUrl] as! String
                            
                            ImageVideoRouter.getImage(imageURLString: imageURLString, sizeString: self.imageSize, completed: { (result, error) in
                                self.comletedBlock(result, error)
                            }).fetchdata()
                        } else {
                            let defaultImage = UIImage(named: "display-empty.jpg")
                            self.comletedBlock(defaultImage, nil)
                        }
                    } else {
                        let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                        self.comletedBlock(nil, error)
                    }
                case .failure(let error):
                    // check status code 401 : cookie expire
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
        case .getImage:
            if (self.path.isEmpty == false) {
                let image = self.getCacheImageWithLink(link: self.path as NSString)
                if (image != nil) {
                    self.comletedBlock(image, nil)
                } else {
                    Alamofire.request(self.path, method: self.method).responseImage(completionHandler: { (response) in
                        print("PM: ImageRouter 2")
                        
                        if (response.result.isSuccess) {
                            let imageRes = response.result.value! as UIImage
                            
                            ImageVideoRouter.imageCache.setObject(imageRes, forKey: self.path as NSString)
                            
                            self.comletedBlock(imageRes, nil)
                        } else {
                            let error = NSError(domain: "Pummel", code: 1000, userInfo: nil) // simple error
                            self.comletedBlock(nil, error)
                        }
                    })
                }
            } else {
                let error = NSError(domain: "Pummel", code: 500, userInfo: nil) // Simple error
                self.comletedBlock(nil, error)
            }
            
        case .uploadPhoto:
            let filename = jpgeFile
            let type = imageJpeg
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(self.fileData!, withName: "file", fileName: filename, mimeType: type)
                
                for (key, value) in self.param! {
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to: self.path, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if (response.result.isSuccess) {
                            self.comletedBlock(true as AnyObject, nil)
                        } else {
                            let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                            self.comletedBlock(false as AnyObject, error)
                        }
                    }
                    
                case .failure(_):
                    let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                    self.comletedBlock(false as AnyObject, error)
                }
            })
            
        case .uploadVideo:
            let videoType = "video/mp4"
            let videoName = "video.mp4"
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(self.fileData!, withName: "file", fileName: videoName, mimeType: videoType)
                
                for (key, value) in self.param! {
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to: self.path, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (Progress) in
                        print("Upload Progress: \(Progress.fractionCompleted)")
                        
                        self.comletedBlock(Progress.fractionCompleted, nil)
                    })
                    
                    // 0 : upload faile
                    // 0 < x < 100: in progress
                    // 101 : done
                    upload.responseJSON { response in
                        if (response.result.isSuccess) {
                            self.comletedBlock(Double(101), nil)
                        } else {
                            let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                            self.comletedBlock(0, error)
                        }
                    }
                    
                case .failure(_):
                    let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                    self.comletedBlock(false as AnyObject, error)
                }
            })
            
        case .uploadPostImage:
            let filename = jpgeFile
            let type = imageJpeg
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(self.fileData!, withName: "file", fileName: filename, mimeType: type)
                
                for (key, value) in self.param! {
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to: self.path, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if (response.result.isSuccess) {
                            self.comletedBlock(true as AnyObject, nil)
                        } else {
                            let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                            self.comletedBlock(false as AnyObject, error)
                        }
                    }
                    
                case .failure(_):
                    let error = NSError(domain: "Pummel", code: 500, userInfo: nil)
                    self.comletedBlock(false as AnyObject, error)
                }
            })
            
            
        }
    }
    
    func getCacheImageWithLink(link: NSString) -> UIImage?  {
        let cache = ImageVideoRouter.imageCache
        if (cache.object(forKey: link) != nil) {
            let imageRes = cache.object(forKey: link)!
            return imageRes
        }
        
        return nil
    }
}
