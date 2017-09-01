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
        self.descript = data["description"] as! String
        self.updatedAt = data["updatedAt"] as! String
        self.createdAt = data["createdAt"] as! String
        self.userCommentUrl = data["userCommentUrl"] as! String
        self.userCommentName = data["userCommentName"] as! String
    }
}
