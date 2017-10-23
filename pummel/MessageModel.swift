//
//  MessageModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/6/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation

import UIKit

protocol MessageModelDelegate {
    func messageModelSynsDataSuccess()
}

class MessageModel: NSObject {
    var delegate : MessageModelDelegate? 
    
    
    var targetUserID: String?
    var targetUserName: String?
    var targetUserImage: UIImage?
    
    var messageID: String?
    var text: String?
    var isOpen = false
    var createdAt: String?
    var updateAt: String?
    
    var tagType: Int?
    
    var selected = false
    
    func parseData(data: NSDictionary) {
        let messageID = data[kId] as! Int
        self.messageID = String(format:"%ld", messageID)
        self.createdAt = data[kCreateAt] as? String
        self.updateAt = data[kUpdateAt] as? String
        
        // Other param will fill later
    }
    
    func synsOtherData() {
        MessageRouter.getDetailConversation(messageID: self.messageID!, completed: { (result, error) in
            if (error == nil) {
                // Get lastest message
                let arrayMessageThisConverId = result as! NSArray
                if (arrayMessageThisConverId.count != 0) {
                    let messageDetail = arrayMessageThisConverId[0] as! NSDictionary
                    
                    if ((messageDetail[kText] is NSNull) == false) {
                        if (messageDetail[kText] as! String == "") {
                            self.text = "Media message"
                        } else {
                            self.text = messageDetail[kText]  as? String
                        }
                    } else {
                        if (!(messageDetail[kImageUrl] is NSNull)) {
                            self.text = sendYouAImage
                        } else if (!(messageDetail[KVideoUrl] is NSNull)) {
                            self.text = sendYouAVideo
                        } else {
                            self.text = "Media messge"
                        }
                    }
                } else {
                    self.text = " "
                }
            
                // Check which on is sender
                let conversationsUserArray = result as! NSArray
                let conversationMe : NSDictionary!
                let conversationTarget: NSDictionary!
                
                if (conversationsUserArray.count <= 1) {
                    conversationMe = conversationsUserArray[0] as! NSDictionary
                    conversationTarget = conversationsUserArray[0]  as! NSDictionary
                } else {
                    let converstationTemp = conversationsUserArray[0] as! NSDictionary
                    let tempUserID = String(format:"%0.f", (converstationTemp[kUserId]! as AnyObject).doubleValue)
                    
                    if (tempUserID == PMHelper.getCurrentID()) {
                        conversationMe = conversationsUserArray[0] as! NSDictionary
                        conversationTarget = conversationsUserArray[1]  as! NSDictionary
                    } else {
                        conversationMe = conversationsUserArray[1] as! NSDictionary
                        conversationTarget = conversationsUserArray[0]  as! NSDictionary
                    }
                }
                
                self.targetUserID = String(format:"%0.f", (conversationTarget[kUserId]! as AnyObject).doubleValue)
                
                // Check New or old
                if (conversationMe[kLastOpenAt] == nil) {
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
                                            self.delegate?.messageModelSynsDataSuccess()
                                        }
                                    })
                                } else {
                                    print("Request failed with error: \(String(describing: error))")
                                }
                            }).fetchdata()
                        } else {
                            self.targetUserImage = UIImage(named:"display-empty.jpg")
                            
                            if (self.delegate != nil) {
                                self.delegate?.messageModelSynsDataSuccess()
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
    
    func same(message: MessageModel) -> Bool {
        if (self.messageID == message.messageID) {
            return true
        }
        
        return false
    }
    
    func existInList(messageList: [MessageModel]) -> Bool {
        for message in messageList {
            if (self.same(message: message)) {
                return true
            }
        }
        
        return false
    }
}
