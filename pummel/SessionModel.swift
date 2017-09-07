//
//  Session.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 12/30/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class SessionModel: NSObject {
    var id = 0
    var status = 0
    var userId = 0
    var coachId = 0
    
    var longtime = 0
    var calorie = 0
    
    var text: String?
    var type: String?
    var uploadId: String?
    var datetime: String?
    var createdAt: String?
    var updatedAt: String?
    var distance: Double?
    var intensity: String?
    
    var imageUrl: String?
    
    func parseData(data: NSDictionary) {
        self.id = data.objectForKey("id") as! Int
        self.status = data.objectForKey("status") as! Int
        self.userId = data.objectForKey("userId") as! Int
        
        let coachId = data.objectForKey("coachId") as? Int
        if (coachId != nil) {
            self.coachId = coachId!
        }
        
        self.text = data.objectForKey("text") as? String
        self.imageUrl = data.objectForKey("imageUrl") as? String
        self.type = data.objectForKey("type") as? String
        self.uploadId = data.objectForKey("uploadId") as? String
        self.createdAt = data.objectForKey("createdAt") as? String
        self.updatedAt = data.objectForKey("updatedAt") as? String
        self.datetime = data.objectForKey("datetime") as? String
        
        if self.datetime == nil {
            self.datetime = self.createdAt
        }
        
        let intensity = data.objectForKey("intensity") as? String
        if (intensity != nil) {
            self.intensity = intensity!
        }
        
        
        let distance = data.objectForKey("distance") as? Double
        if distance != nil {
            self.distance = distance!
        }
        
        let longtime = data.objectForKey("longtime") as? Int
        if longtime != nil {
            self.longtime = longtime!
        }
        
        let calorie = data.objectForKey("calorie") as? Int
        if calorie != nil {
            self.calorie = calorie!
        }
    }
    
    func same(session: SessionModel) -> Bool {
        if (self.id == session.id) {
            return true
        }
        
        return false
    }
    
    func existInList(sessionList: [SessionModel]) -> Bool {
        for session in sessionList {
            if (self.same(session)) {
                return true
            }
        }
        
        return false
    }
}
