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

    @IBOutlet weak var firstLab: UILabel!
    
    @IBOutlet weak var secondLab: UILabel!
    
    @IBOutlet weak var threeLab: UILabel!
    
    @IBOutlet weak var firthLab: UILabel!
    
    @IBOutlet weak var fifveLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
