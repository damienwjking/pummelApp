//
//  Session.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 12/30/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class Session: NSObject {
    var id: Int?
    var text: String?
    var imageUrl: String?
    var type: String?
    var status: Int?
    var userId: Int?
    var coachId: Int?
    var uploadId: String?
    var datetime: String?
    var createdAt: String?
    var updatedAt: String?
    var distance: Int?
    var longtime: Int?
    var intensity: Int?
    var calorie: Int?
    
    func parseDataWithDictionary(sessionContent: NSDictionary) {
        self.id = sessionContent.objectForKey("id") as? Int
        self.text = sessionContent.objectForKey("text") as? String
        self.imageUrl = sessionContent.objectForKey("imageUrl") as? String
        self.type = sessionContent.objectForKey("type") as? String
        self.status = sessionContent.objectForKey("status") as? Int
        self.userId = sessionContent.objectForKey("userId") as? Int
        self.coachId = sessionContent.objectForKey("coachId") as? Int
        self.uploadId = sessionContent.objectForKey("uploadId") as? String
        self.datetime = sessionContent.objectForKey("datetime") as? String
        self.createdAt = sessionContent.objectForKey("createdAt") as? String
        self.updatedAt = sessionContent.objectForKey("updatedAt") as? String
        self.distance = sessionContent.objectForKey("distance") as? Int
        self.longtime = sessionContent.objectForKey("longtime") as? Int
        self.intensity = sessionContent.objectForKey("intensity") as? Int
        self.calorie = sessionContent.objectForKey("calorie") as? Int
    }
}
