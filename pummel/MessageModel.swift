//
//  MessageModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/6/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation

import UIKit

class MessageModel: NSObject {
    var targetUserID: String?
    var targetUserName: String?
    var targetUserImage: UIImage?
    
    var messageID: String?
    var text: String?
    var isOpen = false
    var updateAt: String?
    
    
    
    var tagType: Int?
    
    var selected = false
    
    func parseData(data: NSDictionary) {
        self.username = data.object(forKey: "id") as? String
        self.messageID = data.object(forKey: "status") as? String
        self.text = data.object(forKey: "userId") as? String
        self.tagType = data.object(forKey: "text") as? Int
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
