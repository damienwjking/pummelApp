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
    var tagId: Int?
    var tagColor: String?
    var updateAt: String?
    var tagType: Int?
    var tagTitle: String?
    var selected = false
    
    func parseData(data: NSDictionary) {
        self.tagId = data.object(forKey: "id") as? Int
        self.tagTitle = data.object(forKey: "title") as? String
        self.updateAt = data.object(forKey: "updatedAt") as? String
        self.tagType = data.object(forKey: "type") as? Int
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
