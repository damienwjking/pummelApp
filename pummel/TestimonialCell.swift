//
//  TestimonialCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 8/28/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class TestimonialCell: UICollectionViewCell {
    var testimonial: TestimonialModel? = nil
    
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
        self.layer.borderColor = UIColor.init(white: 0.8, alpha: 0.25).cgColor
        
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.cornerRadius = 25
        self.avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
        self.avatarImageView.layer.borderWidth = 0 // No border
        
        self.avatarImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.avatarImageViewClicked))
        
        self.avatarImageView.addGestureRecognizer(tapGesture)
    }

    func setupData(testimonial: TestimonialModel) {
        self.testimonial = testimonial
        
        self.locationLabel.text = testimonial.userCommentLocation
        
        self.descriptionTextView.text = testimonial.descript
        
        if (testimonial.rating >= 0 && testimonial.rating <= 5) {
            // Width of rating star is 20
            self.ratingViewWidthConstraint.constant = 20 * CGFloat(testimonial.rating)
            
            self.ratingImageView.layoutIfNeeded()
        }
        
        // cache
        self.userNameLabel.text = testimonial.nameCache
        if (testimonial.userImageCache != nil) {
            self.avatarImageView.image = testimonial.userImageCache
        }
    }
    
    func avatarImageViewClicked() {
        if (self.testimonial != nil) {
            PMHelper.showCoachOrUserView(userID: (self.testimonial?.userCommentId)!)
        }
    }
}
