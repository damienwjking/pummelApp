//
//  FeedModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/3/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation

import UIKit

class FeedModel: NSObject {
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
        self.id = data.object(forKey: "id") as! Int
        self.status = data.object(forKey: "status") as! Int
        self.userId = data.object(forKey: "userId") as! Int
        
        let coachId = data.object(forKey: "coachId") as? Int
        if (coachId != nil) {
            self.coachId = coachId!
        }
        
        self.text = data.object(forKey: "text") as? String
        self.imageUrl = data.object(forKey: "imageUrl") as? String
        self.type = data.object(forKey: "type") as? String
        self.uploadId = data.object(forKey: "uploadId") as? String
        self.createdAt = data.object(forKey: "createdAt") as? String
        self.updatedAt = data.object(forKey: "updatedAt") as? String
        self.datetime = data.object(forKey: "datetime") as? String
        
        if self.datetime == nil {
            self.datetime = self.createdAt
        }
        
        let intensity = data.object(forKey: "intensity") as? String
        if (intensity != nil) {
            self.intensity = intensity!
        }
        
        
        let distance = data.object(forKey: "distance") as? Double
        if distance != nil {
            self.distance = distance!
        }
        
        let longtime = data.object(forKey: "longtime") as? Int
        if longtime != nil {
            self.longtime = longtime!
        }
        
        let calorie = data.object(forKey: "calorie") as? Int
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
