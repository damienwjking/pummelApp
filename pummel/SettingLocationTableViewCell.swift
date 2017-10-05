//
//  SettingLocationTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 8/25/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class SettingLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var locationLB: UILabel!
    @IBOutlet weak var myCurrentLocationLB: UILabel!
    @IBOutlet weak var locationContentLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.locationLB.font = .pmmMonReg11()
        self.myCurrentLocationLB.font = .pmmMonReg11()
        self.locationContentLB.font = .pmmMonReg11()
    }
    
}
