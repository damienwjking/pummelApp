//
//  LeadCollectionViewCell.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class LeadCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2.0
        self.avatarImageView.clipsToBounds = true
        
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2.0
    }

    func setupData(userInfo: UserModel) {
        self.nameUser.text = userInfo.firstname?.uppercased()
        
        self.avatarImageView.image = userInfo.userImageCache
        
        // Check coach
        let userID = String(format: "%ld", userInfo.id)
        UserRouter.checkCoachOfUser(userID: userID) { (result, error) in
            let isCoach = result as! Bool
            
            if (isCoach == true) {
                self.avatarImageView.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
                self.avatarImageView.layer.borderWidth = 2
            }
        }.fetchdata()
    }
    
    func setupLayout(isShowAddButton: Bool) {
        self.addButton.isHidden = !isShowAddButton
    }
}
