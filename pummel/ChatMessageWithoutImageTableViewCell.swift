//
//  ChatMessageWithoutImageTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 5/23/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class ChatMessageWithoutImageTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var messageLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.nameLB.font = UIFont(name: "Montserrat-Light", size: 13)
        self.messageLB.font = UIFont(name: "Montserrat-Light", size: 16)
        self.messageLB.numberOfLines = 10
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}