//
//  Message.swift
//  pummel
//
//  Created by Bear Daddy on 5/17/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation

class Message : NSObject {
    var timeLeft : NSString!
    var message: NSString!
    var read : Bool!
    var user : User!
    
    init(timeLeft: NSString, message: NSString, read: Bool, user: User) {
        self.timeLeft = timeLeft
        self.message = message
        self.read = read
        self.user = user
    }
}