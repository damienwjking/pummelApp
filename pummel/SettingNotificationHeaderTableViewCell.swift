//
//  SettingNotificationHeaderTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 8/25/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class SettingNotificationHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var notificationLB: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.notificationLB.font = .pmmMonReg11()
    }
}
