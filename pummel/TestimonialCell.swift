//
//  TestimonialCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 8/28/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class TestimonialCell: UICollectionViewCell {
    var userID = ""
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!

    @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.cornerRadius = 25
        self.avatarImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.avatarImageView.layer.borderWidth = 0.5
        
        self.avatarImageView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer { (_) in
            self.avatarImageViewClicked()
        }
        self.avatarImageView.addGestureRecognizer(tapGesture)
        
        self.descriptionLabel.font = UIFont.pmmMonLight11()
        
        self.userNameLabel.font = UIFont.pmmMonReg11()
        
        self.locationLabel.font = UIFont.pmmMonLight11()
    }

    func setupData(testimonial: TestimonialModel) {
        self.userID = String(format: "%ld", testimonial.userCommentId)
        
        self.locationLabel.text = testimonial.userCommentLocation
        
        // 167: width of description text
        // 160: height of description text
        self.descriptionLabel.text = testimonial.descript
        var descriptionHeightText = testimonial.descript.heightWithConstrainedWidth(167, font: self.descriptionLabel.font) + 10
        if (descriptionHeightText > 160) {
            descriptionHeightText = 160
        }
        self.descriptionLabelHeightConstraint.constant = descriptionHeightText
        
        if (testimonial.rating >= 0 && testimonial.rating <= 5) {
            // Width of rating star is 20
            self.ratingViewWidthConstraint.constant = 20 * CGFloat(testimonial.rating)
            
            self.ratingImageView.layoutIfNeeded()
        }
        
        // cache
        self.userNameLabel.text = testimonial.nameCache
        if (testimonial.imageCache != nil) {
            self.avatarImageView.image = testimonial.imageCache
        }
        
        let userID = String(format: "%ld", testimonial.userCommentId)
        UserRouter.getUserInfo(userID: userID) { (result, error) in
            if (error == nil) {
                let userInfo = result as! NSDictionary
                
                let firstName = userInfo[kFirstname] as! String
                let lastName = userInfo[kLastName] as? String
                
                self.userNameLabel.text = firstName
                if (lastName != nil && lastName?.isEmpty == false) {
                    self.userNameLabel.text = firstName + " " + lastName!
                }
                
                testimonial.nameCache = self.userNameLabel.text!
                
                let imageURL = userInfo[kImageUrl] as? String
                if (imageURL != nil && imageURL?.isEmpty == false) {
                    ImageRouter.getImage(imageURLString: imageURL!, sizeString: widthHeight120) { (result, error) in
                        if (error == nil) {
                            let imageRes = result as! UIImage
                            self.avatarImageView.image = imageRes
                            
                            testimonial.imageCache = imageRes
                        } else {
                            let imageRes = UIImage(named: "display-empty.jpg")
                            self.avatarImageView.image = imageRes
                            
                            testimonial.imageCache = imageRes
                            
                            print("Request failed with error: \(error)")
                        }
                        }.fetchdata()
                }
                
                
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
    }
    
    func avatarImageViewClicked() {
        PMHeler.showCoachOrUserView(self.userID)
    }
}
