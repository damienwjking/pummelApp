//
//  BookUserTableViewCell.swift
//  pummel
//
//  Created by Hao Nguyen Vu on 1/4/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class BookUserTableViewCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.width/2.0
        self.imgAvatar.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
