//
//  ConversationModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/6/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation

import UIKit

protocol ConversationDelegate {
    func ConversationSynsDataSuccess()
}

class ConversationModel: NSObject {
    var delegate : ConversationDelegate?
    
    var targetUserID: String?
    var targetUserName: String?
    var targetUserImage: UIImage?
    
    var conversationID: String?
    var text: String?
    var isOpen = false
    var createdAt: String?
    var updateAt: String?
    
    var tagType: Int?
    
    var selected = false
    
    func parseData(data: NSDictionary) {
        let conversationID = data[kId] as! Int
        self.conversationID = String(format:"%ld", conversationID)
        self.createdAt = data[kCreateAt] as? String
        self.updateAt = data[kUpdateAt] as? String
        
        // Get target user id
        let conversations = data["conversationUsers"] as! NSArray
        var conversationMe = conversations[0] as! NSDictionary
        var conversationTarget = conversations[1] as! NSDictionary
        
        let tempUserID = conversationMe[kUserId] as! Int
        let tempUserIDString = String(format:"%ld", tempUserID)
        
        if (tempUserIDString != PMHelper.getCurrentID()) {
            conversationMe = conversations[1] as! NSDictionary
            conversationTarget = conversations[0] as! NSDictionary
        }
        
        let targetUserID = conversationTarget[kUserId] as! Int
        self.targetUserID = String(format:"%ld", targetUserID)
        
        // Check is open message
        if (conversationMe[kLastOpenAt] is NSNull == true) {
            self.isOpen = false
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = kFullDateFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            
            let lastOpenAtM = dateFormatter.date(from: conversationMe[kLastOpenAt] as! String)
            let updateAtM =  dateFormatter.date(from: self.updateAt!)
            
            if (lastOpenAtM!.compare(updateAtM!) == .orderedAscending) {
                self.isOpen = false
            } else {
                self.isOpen = true
            }
        }
    }
    
    func synsOtherData() {
        MessageRouter.getDetailConversation(conversationID: self.conversationID!, completed: { (result, error) in
            if (error == nil) {
                // Get lastest message
                let arrayMessageThisConverId = result as! [MessageModel]
                self.text = arrayMessageThisConverId[0].text
                
                // Get name
                UserRouter.getUserInfo(userID: self.targetUserID!, completed: { (result, error) in
                    if (error == nil) {
                        let userInfo = result as! NSDictionary
                        
                        let name = userInfo.object(forKey: kFirstname) as! String
                        self.targetUserName = name.uppercased()
                        
                        var imageURL = userInfo.object(forKey: kImageUrl) as? String
                        if (imageURL?.isEmpty == true) {
                            imageURL = " "
                        }
                        
                        if (userInfo[kImageUrl] is NSNull == false) {
                            let imageURLString = userInfo[kImageUrl] as! String
                            
                            ImageVideoRouter.getImage(imageURLString: imageURLString, sizeString: widthHeight160, completed: { (result, error) in
                                if (error == nil) {
                                    DispatchQueue.main.async(execute: {
                                        let imageRes = result as! UIImage
                                        self.targetUserImage = imageRes
                                        
                                        if (self.delegate != nil) {
                                            self.delegate?.ConversationSynsDataSuccess()
                                        }
                                    })
                                } else {
                                    print("Request failed with error: \(String(describing: error))")
                                }
                            }).fetchdata()
                        } else {
                            self.targetUserImage = UIImage(named:"display-empty.jpg")
                            
                            if (self.delegate != nil) {
                                self.delegate?.ConversationSynsDataSuccess()
                            }
                        }
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }).fetchdata()
    }
    
    func same(conversation: ConversationModel) -> Bool {
        if (self.conversationID == conversation.conversationID) {
            return true
        }
        
        return false
    }
    
    func existInList(conversationList: [ConversationModel]) -> Bool {
        for conversation in conversationList {
            if (self.same(conversation: conversation)) {
                return true
            }
        }
        
        return false
    }
}
