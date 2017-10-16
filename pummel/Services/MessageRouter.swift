//
//  MessageRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/6/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

enum MessageRouter: URLRequestConvertible {
    case getConversationList(offset: Int, completed: CompletionBlock)
    case getDetailConversation(messageID: String, completed: CompletionBlock)
    case setOpenMessage(messageID: String, completed: CompletionBlock)
    case createConversationWithUser(userID: String, completed: CompletionBlock)
    case sendMessage(conversationID: String, text: String, imageData: Data, completed: CompletionBlock)
    case updateMessageDetail(messageID: String, param: [String : Any], completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getConversationList(_, let completed):
            return completed
            
        case .getDetailConversation(_, let completed):
            return completed
            
        case .setOpenMessage(_, let completed):
            return completed
            
        case .createConversationWithUser(_, let completed):
            return completed
            
        case .sendMessage(_, _, _, let completed):
            return completed
            
        case .updateMessageDetail(_, _, let completed):
            return completed
            
        }
    }
    
    var imageData: Data {
        switch self {
        case .sendMessage(_, _, let imageData, _):
            return imageData
            
        default:
            break
        }
        
        return Data()
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getConversationList:
            return .get
            
        case .getDetailConversation:
            return .get
            
        case .setOpenMessage:
            return .put
            
        case .createConversationWithUser:
            return .post
            
        case .sendMessage:
            return .post
            
        case .updateMessageDetail:
            return .put
            
            
        }
    }
    
    var path: String {
        let currentUserID = PMHelper.getCurrentID()
        
        var prefix = ""
        switch self {
        case .getConversationList(let offset, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_CONVERSATION_OFFSET_V2 + "\(offset)"
            
        case .getDetailConversation(let messageID, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_CONVERSATION + "/" + messageID + kPM_PARTH_MESSAGE
            
        case .setOpenMessage(let messageID, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_CONVERSATION_V2 + "/" + messageID
            
        case .createConversationWithUser:
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_CONVERSATION + "/"
            
        case .sendMessage(let messageID, _, _, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_CONVERSATION + "/" + messageID + kPM_PARTH_MESSAGE_V2
            
        case .updateMessageDetail(let messageID, _, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_CONVERSATION + "/" + messageID
            
            
        }
        
        return prefix
    }
    
    var param: [String : AnyObject]? {
        let currentUserID = PMHelper.getCurrentID()
        
        var param: [String : AnyObject]? = [:]
        
        switch self {
//        case .getConversationList(let offset):
            
        case .setOpenMessage(let messageID):
            param?[kUserId] =  currentUserID as AnyObject
            param?[kConversationId] =  messageID as AnyObject
            
        case .createConversationWithUser(let userID, _):
            param?[kUserId] = currentUserID as AnyObject
            param?[kUserIds] = [userID]  as AnyObject
            
        case .sendMessage(let messageID, let text, _, _):
            param?[kConversationId] = messageID as AnyObject
            param?[kText] = text as AnyObject
            param?["file"] = "nodata" as AnyObject
            
        case .updateMessageDetail(_, let parameter, _):
            for (key, value) in parameter {
                param?[key] = value as AnyObject
            }
            
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
        case .getConversationList:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: MessageRouter get_conversation")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        var messageList: [MessageModel] = []
                        
                        let messageDetails = JSON as! [NSDictionary]
                        
                        for messageDetail in messageDetails {
                            let message = MessageModel()
                            
                            message.parseData(data: messageDetail)
                            
                            messageList.append(message)
                        }
                        
                        self.comletedBlock(messageList as AnyObject, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock(nil, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .getDetailConversation:
            Alamofire.request(self).responseJSON(completionHandler: { (response) in
                print("PM: MessageRouter get_detail_conversation")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let messageDetail = JSON as! NSArray
                        
                        if (messageDetail.count >= 2) {
                            self.comletedBlock(messageDetail, nil)
                        } else {
                            let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                            self.comletedBlock(nil, error)
                        }
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock(nil, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .setOpenMessage:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseString(completionHandler: { (response) in
                print("PM: MessageRouter set_open_message")
                
                switch response.result {
                case .success( _):
                    if response.response?.statusCode == 200 {
                        self.comletedBlock(true, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock(false, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(false, error as NSError)
                    }
                }
            })
            
        case .createConversationWithUser:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: MessageRouter create_conversation")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let messageInfo = JSON as! NSDictionary
                        
                        self.comletedBlock(messageInfo, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock(nil, error)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .sendMessage:
            let type = imageJpeg
            let filename = jpgeFile
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(self.imageData,
                                         withName: "file",
                                         fileName: filename,
                                         mimeType: type)
                
                for (key, value) in self.param! {
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to: self.path, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print("PM: MessageRouter send_message")
                        
                        if response.response?.statusCode == 200 {
                            self.comletedBlock(true, nil)
                        } else if (response.response?.statusCode == 401) {
                            PMHelper.showLogoutAlert()
                        } else {
                            let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                            self.comletedBlock(false, error)
                        }
                    }
                case .failure(let error):
                    self.comletedBlock(false, error as NSError)
                }
            })
            
        case .updateMessageDetail:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: MessageRouter update_message")
                
                switch response.result {
                case .success(_):
                    if response.response?.statusCode == 200 {
                        self.comletedBlock(true, nil)
                    } else {
                        let error = NSError(domain: "Error", code: 500, userInfo: nil) // Create simple error
                        self.comletedBlock(false, error)
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
