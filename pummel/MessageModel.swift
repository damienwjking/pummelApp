//
//  MessageModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/23/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation

import UIKit


protocol MessageDelegate {
    func MessageSynsDataCompleted(message: MessageModel)
}

class MessageModel: NSObject {
    var delegate: MessageDelegate? = nil
    
    var id: String?  = ""
    var text: String? = " "
    var userId: String? = ""
    var uploadId: String? = ""
    var imageUrl: String? = ""
    var updatedAt: String? = ""
    var createdAt: String? = ""
    var videoUrl: String? = ""
    var conversationId: String? = ""
    
    var nameCache = ""
    var imageCache: UIImage? = nil
    var imageContentCache: UIImage? = nil
    
    func parseData(data: NSDictionary) {
        let id = data[kId] as? Int
        let userId = data[kUserId] as? Int
        let uploadId = data["uploadId"] as? Int
        let conversationId = data["conversationId"] as? Int
        
        if (id != nil) {
            self.id = String(id!)
        }
        
        if (userId != nil) {
            self.userId = String(userId!)
        }
        
        if (uploadId != nil) {
            self.uploadId = String(uploadId!)
        }
        
        if (conversationId != nil) {
            self.conversationId = String(conversationId!)
        }
        
        self.imageUrl = data["imageUrl"] as? String
        self.videoUrl = data["videoUrl"] as? String
        self.createdAt = data["createdAt"] as? String
        self.updatedAt = data["updatedAt"] as? String
        
        self.text = data["text"] as? String
        if (self.text != nil) {
            if (self.text == "") {
                self.text = "Media message"
            }
        } else {
            if (self.imageUrl != nil) {
                self.text = sendYouAImage
            } else if (self.videoUrl != nil) {
                self.text = sendYouAVideo
            } else {
                self.text = ""
            }
        }
    }
    
    func synsOtherData() {
        UserRouter.getUserInfo(userID: self.userId!, completed: { (result, error) in
            if (error == nil) {
                    let userInfo = result as! NSDictionary
                    
                    let firstName = userInfo.object(forKey: kFirstname) as! String
                    self.nameCache = firstName.uppercased()
                    
                    if (userInfo[kImageUrl] is NSNull == false) {
                        let userImageURL = userInfo[kImageUrl] as! String
                        
                        ImageVideoRouter.getImage(imageURLString: userImageURL, sizeString: widthHeight160, completed: { (result, error) in
                            if (error == nil) {
                                let imageRes = result as! UIImage
                                self.imageCache = imageRes
                            } else {
                                print("Request failed with error: \(String(describing: error))")
                                
                                self.imageCache = UIImage(named: "display-empty.jpg")
                            }
                            
                            self.callDelegate()
                        }).fetchdata()
                    } else {
                        self.imageCache = UIImage(named: "display-empty.jpg")
                        
                        self.callDelegate()
                    }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }).fetchdata()
        
        // Get image content
        if (self.imageUrl != nil && self.imageUrl?.isEmpty == false) {
            ImageVideoRouter.getImage(imageURLString: self.imageUrl!, sizeString: widthHeight640, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.imageContentCache = imageRes
                } else {
                    self.imageUrl = nil
                }
                
                self.callDelegate()
            }).fetchdata()
        }
    }
    
    func callDelegate() {
        if (self.delegate != nil) {
            self.delegate?.MessageSynsDataCompleted(message: self)
        }
    }
    
    
    func same(message: MessageModel) -> Bool {
        if (self.id == message.id) {
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
