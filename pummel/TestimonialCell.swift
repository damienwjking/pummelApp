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
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!

    @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.init(white: 0.8, alpha: 0.25).CGColor
        
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.cornerRadius = 25
        self.avatarImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.avatarImageView.layer.borderWidth = 0 // No border
        
        self.avatarImageView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer { (_) in
            self.avatarImageViewClicked()
        }
        self.avatarImageView.addGestureRecognizer(tapGesture)
    }

    func setupData(testimonial: TestimonialModel) {
        self.userID = String(format: "%ld", testimonial.userCommentId)
        
        self.locationLabel.text = testimonial.userCommentLocation
        
        self.descriptionTextView.text = testimonial.descript
        
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
        
        if (testimonial.needUpdate == true) {
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
                            testimonial.needUpdate = false
                            
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
    }
    
    func avatarImageViewClicked() {
        PMHeler.showCoachOrUserView(self.userID)
    }
}
