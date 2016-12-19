//
//  LogTableViewCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 12/19/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation


class LogCompletedTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var messageLB: UILabel!
    @IBOutlet weak var tagActionLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.messageLB.numberOfLines = 2
        
        self.nameLB.font = .pmmMonLight13()
        self.messageLB.font = .pmmMonLight16()
        self.timeLB.font = .pmmMonLight13()
        self.timeLB.textColor = UIColor.blackColor()
        self.tagActionLB.font = .pmmMonLight13()
        
    }
}
