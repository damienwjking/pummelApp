//
//  SettingHelpSupportTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 8/25/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class SettingHelpSupportTableViewCell: UITableViewCell {
    @IBOutlet weak var helpAndSupportLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.helpAndSupportLB.font = .pmmMonReg11()
//        self.helpAndSupportLB.textColor = UIColor.black // error
    }
    
    func setData(text: String, canSelect: Bool = true) {
        self.helpAndSupportLB.text = text
        self.helpAndSupportLB.textColor = UIColor.black // error fixed
        
        if (canSelect == false) {
            self.selectionStyle = .none
        }
    }
}
