//
//  SettingLogoutTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 8/25/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class SettingLogoutTableViewCell: UITableViewCell {
    @IBOutlet weak var logoutLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.logoutLB.font = .pmmMonReg11()
        self.logoutLB.textColor = UIColor.pmmBrightOrangeColor()
    }
}
