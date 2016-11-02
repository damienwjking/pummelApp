//
//  HorizontalCell.swift
//  Swift_TableView_ Horizontal
//
//  Created by（ 捉个妹子来玩玩 ---- 陶亚利 ）
//  on 16/5/20.
//  taoyali_1234@163.com
//
//  Copyright © 2016年 陶亚利. All rights reserved.
//

import UIKit

class HorizontalCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var imageV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageV.layer.cornerRadius = 35
        imageV.clipsToBounds = true
        name.font = .pmmMonReg13()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
