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
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
