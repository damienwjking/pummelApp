//
//  SettingMaxDistanceTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 8/25/16.
//  Copyright © 2016 pummel. All rights reserved.
//


import UIKit

class SettingMaxDistanceTableViewCell: UITableViewCell {
    @IBOutlet weak var maxDistanceLB: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var maxDistanceContentLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.maxDistanceLB.font = .pmmMonReg11()
        self.maxDistanceContentLB.font = .pmmMonReg11()
        self.slider.maximumValue = 50
        self.slider.minimumValue = 0
    }
}
