//
//  TestimonialCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 8/28/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class TestimonialCell: UICollectionViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.cornerRadius = 25
        
        self.descriptionLabel.font = UIFont.pmmMonLight11()
        
        self.userNameLabel.font = UIFont.pmmMonReg11()
        
        self.titleLabel.font = UIFont.pmmMonLight11()
    }

}
