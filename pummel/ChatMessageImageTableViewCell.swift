//
//  ChatMessageImageTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 5/23/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class ChatMessageImageTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var messageLB: UILabel!
    @IBOutlet weak var photoIMW: UIImageView!
    @IBOutlet weak var photoIMWHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func setupData(message: MessageModel) {
        self.photoIMW.image = message.imageContentCache
        
        self.avatarIMV.image = message.imageCache
        self.nameLB.text = message.nameCache
        
        if (message.text == nil) {
            self.messageLB.text = ""
        } else {
            self.messageLB.text = message.text
        }
    }
}

