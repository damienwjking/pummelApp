//
//  UserModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 7/5/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

protocol UserModelDelegate {
    func userModelSynsCompleted(user: UserModel)
}

class UserModel: NSObject {
    var delegate: UserModelDelegate?
    
    var id: Int = 0
    var businessId: Int = 0
    var mixpanel_id: String? = ""
    var fbId: String? = ""
    
    var dob: String? = ""
    var bio: String? = ""
    var email: String? = ""
    var gender: String? = ""
    var emergencyName: String? = ""
    var emergencyMobile: String? = ""
    
    var firstname: String? = ""
    var lastname: String? = ""
    
    var height: Int? = 0
    var weight: Int? = 0
    
    var updatedAt: String? = ""
    var createdAt: String? = ""
    var mobile: String? = ""
    
    var status: Int = 0
    
    var rating: Int = 0
    var postCount: Int = 0
    var connectionCount: Int = 0
    var nNotification: Int = 0
    var mNotification: Int = 0
    var lNotification: Int = 0
    var cNotification: Int = 0
    var sNotification: Int = 0
    var messageNotification: Int = 0
    var newleadNotification: Int = 0
    var sessionNotification: Int = 0
    var units: String = "Metric"
    
    var imageUrl: String? = nil
    var videoUrl: NSURL? = nil
    var twitterUrl: String? = ""
    var facebookUrl: String? = ""
    var instagramUrl: String? = ""
    
    var isSynsCompleted = true // Flag for syns case
    var userImageCache: UIImage? = nil
    var userDictionary: NSDictionary? // Template
    
    func parseData(data: NSDictionary) {
        self.userDictionary = data // Template
        
        self.id = data["id"] as! Int
        self.businessId = data["id"] as! Int
        self.mixpanel_id = data["mixpanel_id"] as? String
        self.fbId = data["fbId"] as? String
        
        self.dob = data["dob"] as? String
        self.bio = data["bio"] as? String
        self.email = data["email"] as? String
        self.gender = data["gender"] as? String
        self.emergencyName = data["emergencyName"] as? String
        self.emergencyMobile = data["emergencyMobile"] as? String
        
        self.firstname = data["firstname"] as? String
        self.lastname = data["lastname"] as? String
        
        self.height = data["height"] as? Int
        self.weight = data["weight"] as? Int
        
        self.updatedAt = data["updatedAt"] as? String
        self.createdAt = data["createdAt"] as? String
        self.mobile = data["mobile"] as? String
        
        self.status = data["status"] as! Int
        
        self.rating = data["rating"] as! Int
        self.postCount = data["postCount"] as! Int
        self.connectionCount = data["connectionCount"] as! Int
        self.nNotification = data["nNotification"] as! Int
        self.mNotification = data["mNotification"] as! Int
        self.lNotification = data["lNotification"] as! Int
        self.cNotification = data["cNotification"] as! Int
        self.sNotification = data["sNotification"] as! Int
        self.messageNotification = data["messageNotification"] as! Int
        self.newleadNotification = data["newleadNotification"] as! Int
        self.sessionNotification = data["sessionNotification"] as! Int
        self.units = data["units"] as! String
        
        self.imageUrl = data["imageUrl"] as? String
        self.videoUrl = data["videoUrl"] as? NSURL
        self.twitterUrl = data["twitterUrl"] as? String
        self.facebookUrl = data["facebookUrl"] as? String
        self.instagramUrl = data["instagramUrl"] as? String
    }
    
    func synsData() {
        self.isSynsCompleted = false
        
        let userID = String(format: "%ld", self.id)
        UserRouter.getUserInfo(userID: userID) { (result, error) in
            self.isSynsCompleted = true
            if (error == nil) {
                let userInfo = result as! NSDictionary
                
                self.parseData(data: userInfo)
                
                self.synsImage()
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            
            self.callDelegate()
        }.fetchdata()
    }
    
    func synsImage() {
        self.userImageCache = UIImage(named: "display-empty.jpg")
        
        if (self.imageUrl != nil && self.imageUrl?.isEmpty == false) {
            ImageVideoRouter.getImage(imageURLString: self.imageUrl!, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.userImageCache = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
                
                self.callDelegate()
            }).fetchdata()
        }
    }
    
    func callDelegate() {
        if (self.delegate != nil) {
            self.delegate?.userModelSynsCompleted(user: self)
        }
    }
    
    func convertToDictionary() -> NSDictionary {
        return self.userDictionary!
    }
    
    func same(userCheck: UserModel) -> Bool {
        if (self.id == userCheck.id) {
            return true
        }
        
        return false
    }
    
    func existInList(userList: [UserModel]) -> Bool {
        for user in userList {
            if (self.same(userCheck: user)) {
                return true
            }
        }
        
        return false
    }
}
