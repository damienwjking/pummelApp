//
//  PhotoModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 11/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Foundation

protocol PhotoDelegate {
    func photoSynsDataCompleted(photo: PhotoModel)
}

class PhotoModel: NSObject {
    var delegate: PhotoDelegate? = nil
    
    var id = ""
    var userID = ""
    var uploadId = ""
    
    var profilePic = 0 // Don't know user for
    var priv = 0 // Don't know user for
    
    var createdAt = ""
    var updatedAt = ""
    
    var imageUrl = ""
    
    var imageCache: UIImage? = nil
    
    func parseData(data: NSDictionary) {
        let id = data[kId] as? Int
        if (id != nil) {
            self.id = "\(id!)"
        }
        
        let userID = data[kUserId] as? Int
        if (userID != nil) {
            self.userID = "\(userID!)"
        }
        
        let uploadId = data["uploadId"] as? Int
        if (uploadId != nil) {
            self.uploadId = "\(uploadId!)"
        }
        
        let profilePic = data["profilePic"] as? Int
        if (profilePic != nil) {
            self.profilePic = profilePic!
        }
        
        let priv = data["priv"] as? Int
        if (priv != nil) {
            self.priv = priv!
        }
        
        let createdAt = data[kCreateAt] as? String
        if (createdAt != nil) {
            self.createdAt = createdAt!
        }
        
        let updatedAt = data[kUpdateAt] as? String
        if (updatedAt != nil) {
            self.updatedAt = updatedAt!
        }
        
        let imageUrl = data[kImageUrl] as? String
        if (imageUrl != nil) {
            self.imageUrl = imageUrl!
        }
    }
    
    func synsImage() {
        // Discount image
        if (self.imageUrl.isEmpty == false) {
            ImageVideoRouter.getImage(imageURLString: self.imageUrl, sizeString: widthHeightScreen, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.imageCache = imageRes
                    
                    self.callDelegate()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
    
    func callDelegate() {
        if (self.delegate != nil) {
            self.delegate?.photoSynsDataCompleted(photo: self)
        }
    }
    
    func same(photo: PhotoModel) -> Bool {
        if (self.id == photo.id) {
            return true
        }
        
        return false
    }
    
    func existInList(photoList: [PhotoModel]) -> Bool {
        for photo in photoList {
            if (self.same(photo: photo)) {
                return true
            }
        }
        
        return false
    }
}
