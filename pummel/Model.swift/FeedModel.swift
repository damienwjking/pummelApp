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
    var uploadId = 0
    
    var imageUrl: String?
    var text: String?
    var updatedAt: String?
    var createdAt: String?
    
    var userId = 0
    var userName = ""
    var userImageURL: String?
    
    var isLiked = false
    var likeTotal = ""
    
    var userDetail: NSDictionary? // Temp for reformat
    
    func parseData(data: NSDictionary) {
        self.id = data.object(forKey: "id") as! Int
        self.status = data.object(forKey: "status") as! Int
        self.userId = data.object(forKey: "userId") as! Int
        self.uploadId = data.object(forKey: "uploadId") as! Int
        
        self.text = data.object(forKey: "text") as? String
        self.imageUrl = data.object(forKey: "imageUrl") as? String
        self.createdAt = data.object(forKey: "createdAt") as? String
        self.updatedAt = data.object(forKey: "updatedAt") as? String
        
        let user = data.object(forKey: "user") as! NSDictionary
        self.userDetail = user
        
        let firstName = user[kFirstname] as! String
//        let lastName = user[kLastName] as? String
//        if (lastName == nil || lastName?.isEmpty == true) {
//            self.userName = firstName
//        } else {
//            self.userName = firstName + lastName!
//        }
        self.userName = firstName // now not append last name
        
        let userImage = user[kImageUrl] as? String
        if (userImage != nil && userImage?.isEmpty == false) {
            self.userImageURL = userImage
        }
    }
    
    func synsNumberLike() {
        let feedID = String(format:"%ld", self.id)
        
        FeedRouter.getAndCheckFeedLike(feedID: feedID) { (result, error) in
            if (error == nil) {
                let likeJson = result as! NSDictionary
                
                self.likeTotal = likeJson["likeNumber"] as! String
                self.isLiked = likeJson["currentUserLiked"] as! Bool
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func same(feed: FeedModel) -> Bool {
        if (self.id == feed.id) {
            return true
        }
        
        return false
    }
    
    func existInList(feedList: [FeedModel]) -> Bool {
        for feed in feedList {
            if (self.same(feed: feed)) {
                return true
            }
        }
        
        return false
    }
}
