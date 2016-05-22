//
//  ChatMessageHeaderTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 5/20/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class ChatMessageHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var connectToLB: UILabel!
    @IBOutlet weak var nameChatUserLB: UILabel!
    @IBOutlet weak var startConversationLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIMV.layer.cornerRadius = 40
        self.avatarIMV.clipsToBounds = true
        self.connectToLB.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.nameChatUserLB.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.startConversationLB.font = UIFont(name: "Montserrat-Light", size: 11)
        self.timeLB.font = UIFont(name: "Montserrat-Light", size: 11)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
