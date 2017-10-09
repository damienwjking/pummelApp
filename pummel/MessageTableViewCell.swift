//
//  MessageTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 5/17/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var messageLB: UILabel!
    var targetId: String!
    var isNewMessage: Bool!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.messageLB.numberOfLines = 2
        self.timeLB.font = .pmmMonLight13()
        isNewMessage = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupData(message: MessageModel) {
        // TargetID
        let targerID = message.targetUserID
        if (targerID?.isEmpty == false) {
            self.targetId = targerID
            self.isUserInteractionEnabled = true
        } else {
            self.isUserInteractionEnabled = false
        }
        
        // Chat time
        let timeAgo = message.updateAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let date : NSDate = dateFormatter.date(from: timeAgo!)! as NSDate
        self.timeLB.text = date.timeAgoSinceDate()
        
        // User name
        let nameString: String? = message.targetUserName
        if nameString?.isEmpty == false {
            self.nameLB.text = nameString
        } else {
            self.nameLB.text = ""
        }
        
        // User image
        let userImage = message.messageImage
        if userImage != nil {
            self.avatarIMV.image = userImage
        } else {
            self.avatarIMV.image = UIImage(named:"display-empty.jpg")
        }
        
        // Check New or old
        let lastOpen = message.isOpen
        let userMessage = message.text
        if lastOpen == false {
            self.isNewMessage = true
            self.nameLB.font = .pmmMonReg13()
            self.messageLB.font = .pmmMonReg16()
            self.timeLB.textColor = UIColor.pmmBrightOrangeColor()
            
            self.messageLB.text = userMessage
        } else {
            self.nameLB.font = .pmmMonLight13()
            self.messageLB.font = .pmmMonLight16()
            self.timeLB.textColor = UIColor.black
            
            self.messageLB.text = " "
        }
    }
}
