//
//  LeadCollectionViewCell.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class LeadCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.width/2.0
        self.imgAvatar.clipsToBounds = true
        self.btnAdd.layer.cornerRadius = self.btnAdd.frame.size.width/2.0
    }

}
