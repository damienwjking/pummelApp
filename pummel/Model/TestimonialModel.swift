//
//  TestimonialModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 8/29/17.
//  Copyright © 2017 pummel. All rights reserved.
//

class TestimonialModel: NSObject {
    
    
    var id = 0
    var rating = 0.0
    var userId = 0
    var userCommentId = 0
    
    var descript = ""
    var updatedAt = ""
    var createdAt = ""
    var userCommentUrl = ""
    var userCommentName = ""
    
    var imageCache: UIImage? = nil // For scroll animation
    
    func parseData(data: NSDictionary) {
        self.id = data["id"] as! Int
        self.rating = data["rating"] as! Double
        self.userId = data["userId"] as! Int
        self.userCommentId = data["userCommentId"] as! Int
        
        let descript = data["description"] as? String
        if (descript != nil && descript?.isEmpty == false) {
            self.descript = descript!
        }
        
        let updatedAt = data["updatedAt"] as? String
        if (updatedAt != nil && updatedAt?.isEmpty == false) {
            self.updatedAt = updatedAt!
        }
        
        let createdAt = data["createdAt"] as? String
        if (createdAt != nil && createdAt?.isEmpty == false) {
            self.createdAt = createdAt!
        }
        
        let userCommentUrl = data["userCommentUrl"] as? String
        if (userCommentUrl != nil && userCommentUrl?.isEmpty == false) {
            self.userCommentUrl = userCommentUrl!
        }
        
        let userCommentName = data["userCommentName"] as? String
        if (userCommentName != nil && userCommentName?.isEmpty == false) {
            self.userCommentName = userCommentName!
        }
    }
}
