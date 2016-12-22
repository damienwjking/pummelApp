//
//  LogSessionTableViewCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 12/21/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation

class LogSessionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusIMV: UIImageView!
    @IBOutlet weak var LogTitleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusIMV.layer.masksToBounds = true
        self.statusIMV.layer.cornerRadius = 20
        
        
        self.LogTitleLB.font = .pmmMonLight16()
    }
}
