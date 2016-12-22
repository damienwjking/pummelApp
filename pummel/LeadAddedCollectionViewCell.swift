//
//  LeadAddedCollectionViewCell.swift
//  pummel
//
//  Created by Hao Nguyen Vu on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class LeadAddedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.width/2.0
        self.imgAvatar.clipsToBounds = true
        self.btnRemove.layer.cornerRadius = self.btnRemove.frame.size.width/2.0
    }

}
