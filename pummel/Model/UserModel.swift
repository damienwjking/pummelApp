//
//  UserModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 7/5/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class UserModel: NSObject {
    var id: Int = 0
    var businessId: Int = 0
    var mixpanel_id: String = ""
    
    var dob: String = ""
    var bio: String = ""
    var email: String = ""
    var gender: String = ""
    var emergencyName: String = ""
    var emergencyMobile: String = ""
    
    var firstname: String = ""
    var lastname: String = ""
    
    var height: Int = 0
    var weight: Int = 0
    
    var updatedAt: String = ""
    var createdAt: String = ""
    var mobile: String = ""
    
    var status: Int = 0
    
    var rating: Int = 0
    var postCount: Int = 0
    var connectionCount: Int = 0
    var nNotification: Int = 0
    var messageNotification: Int = 0
    var newleadNotification: Int = 0
    var sessionNotification: Int = 0
    var units: String = "Metric"
    
    var imageUrl: NSURL? = nil
    var videoUrl: NSURL? = nil
    var twitterUrl: String = ""
    var facebookUrl: String = ""
    var instagramUrl: String = ""
}
