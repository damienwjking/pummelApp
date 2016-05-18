//
//  User.swift
//  pummel
//
//  Created by Bear Daddy on 5/17/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation

class User : NSObject {
    var name : NSString!
    var avatar : NSData!
    
    init(name: NSString, avatar: NSData) {
        self.name = name
        self.avatar = avatar
    }
}