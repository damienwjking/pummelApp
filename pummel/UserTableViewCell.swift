//
//  UserTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 5/11/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.nameLB.font = UIFont(name: "Montserrat-Regular", size: 16)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
