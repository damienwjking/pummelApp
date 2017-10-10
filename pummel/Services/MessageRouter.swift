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
    case sendMessage(conversationID: String, text: String, completed: CompletionBlock)
    
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
            
        case .sendMessage(_, _, let completed):
            return completed
            
        }
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
            
        case .sendMessage(let messageID, _, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_CONVERSATION + "/" + messageID + kPM_PARTH_MESSAGE_V2
            
        }
        
        return prefix
    }
    
    var param: [String : Any]? {
        let currentUserID = PMHelper.getCurrentID()
        
        var param: [String : Any]? = [:]
        
        switch self {
//        case .getConversationList(let offset):
            
        case .setOpenMessage(let messageID):
            param?[kUserId] =  currentUserID
            param?[kConversationId] =  messageID
            
        case .createConversationWithUser(let userID, _):
            param?[kUserId] = currentUserID
            param?[kUserIds] = [userID]
            
        case .sendMessage(let messageID, let text, _):
            param?[kConversationId] = messageID
            param?[kText] = text
            param?["file"] = "nodata".data(usingEncoding: String.Encoding.utf8)! as Any
            
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
            Alamofire.request(self.URLRequest as! URLRequestConvertible).responseJSON(completionHandler: { (response) in
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
            Alamofire.request(self.URLRequest as! URLRequestConvertible).responseJSON(completionHandler: { (response) in
                print("PM: MessageRouter get_detail_conversation")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let result = JSON as! NSArray
                        
                        self.comletedBlock(result, nil)
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
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: MessageRouter add_message")
                
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
