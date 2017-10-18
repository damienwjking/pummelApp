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
    @IBOutlet weak var tagTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusIMV.layer.masksToBounds = true
        self.statusIMV.layer.cornerRadius = 20
    }
    
    func setupData(tag: TagModel) {
        self.LogTitleLB.text = tag.tagTitle?.uppercased()
        self.tagTypeLabel.text = ""
        self.statusIMV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
    }
}
