//
//  BookSessionTableViewCell.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/21/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class BookSessionTableViewCell: UITableViewCell {

    @IBOutlet weak var statusIMV: UIImageView!
    @IBOutlet weak var bookTitleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.statusIMV.layer.masksToBounds = true
        self.statusIMV.layer.cornerRadius = 15
        self.bookTitleLB.font = .pmmMonReg16()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
