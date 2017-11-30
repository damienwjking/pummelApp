//
//  ProductUserCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/27/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class ProductUserCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameAndTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
    }

    func setupData(userID: String) {
        UserRouter.getUserInfo(userID: userID) { (result, error) in
            if (error == nil) {
                let userInfo = result as! NSDictionary
                
                let userFirstName = userInfo[kFirstname] as! String
                self.nameAndTitleLabel.text = userFirstName + " can offer the following:"
                
                let avatarImageURL = userInfo[kImageUrl] as? String
                if (avatarImageURL != nil && avatarImageURL?.isEmpty == false) {
                    ImageVideoRouter.getImage(imageURLString: avatarImageURL!, sizeString: widthHeight100, completed: { (result, error) in
                        if (error == nil) {
                            let imageRes = result as! UIImage
                            
                            self.avatarImageView.image = imageRes
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }).fetchdata()
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
        
        UserRouter.checkCoachOfUser(userID: userID) { (result, error) in
            let isCoach = result as! Bool
            
            if (isCoach == true) {
                self.avatarImageView.layer.borderWidth = 2
            }
            
        }.fetchdata()
    }
}
