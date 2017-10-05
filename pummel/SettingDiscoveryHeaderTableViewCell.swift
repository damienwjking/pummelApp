//
//  SettingDiscoveryHeaderTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 8/25/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class SettingDiscoveryHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var discoveryLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.discoveryLB.font = .pmmMonReg11()
    }
}
