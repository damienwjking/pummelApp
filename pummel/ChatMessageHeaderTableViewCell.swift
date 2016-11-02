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
        self.connectToLB.font = .pmmMonReg11()
        self.nameChatUserLB.font = .pmmMonReg11()
        self.startConversationLB.font = .pmmMonLight11()
        self.timeLB.font = .pmmMonLight11()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
