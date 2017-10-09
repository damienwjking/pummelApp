//
//  TagModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/3/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation

import UIKit

class TagModel: NSObject {
    var name: String?
    var tagId: String?
    var tagColor: String?
    var tagType: Int?
    
    var selected = false
    
    func parseData(data: NSDictionary) {
        self.name = data.object(forKey: "id") as? String
        self.tagId = data.object(forKey: "status") as? String
        self.tagColor = data.object(forKey: "userId") as? String
        self.tagType = data.object(forKey: "text") as? Int
    }
    
    func same(tag: TagModel) -> Bool {
        if (self.tagId == tag.tagId) {
            return true
        }
        
        return false
    }
    
    func existInList(tagList: [TagModel]) -> Bool {
        for tag in tagList {
            if (self.same(tag: tag)) {
                return true
            }
        }
        
        return false
    }
}
