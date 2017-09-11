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
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!

    @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.cornerRadius = 25
        
        self.descriptionLabel.font = UIFont.pmmMonLight11()
        
        self.userNameLabel.font = UIFont.pmmMonReg11()
        
        self.locationLabel.font = UIFont.pmmMonLight11()
    }

    func setupData(testimonial: TestimonialModel) {
        self.locationLabel.text = testimonial.userCommentLocation // change title to location
        
        self.userNameLabel.text = testimonial.userCommentName
        
        // 167: width of description text
        // 150: height of description text
        self.descriptionLabel.text = testimonial.descript
        var descriptionHeightText = testimonial.descript.heightWithConstrainedWidth(167, font: self.descriptionLabel.font)
        if (descriptionHeightText > 160) {
            descriptionHeightText = 160
        }
        self.descriptionLabelHeightConstraint.constant = descriptionHeightText
        
        if (testimonial.rating >= 0 && testimonial.rating <= 5) {
            // Width of rating star is 20
            self.ratingViewWidthConstraint.constant = 20 * CGFloat(testimonial.rating)
            
            self.ratingImageView.layoutIfNeeded()
        }
        
        if (testimonial.imageCache == nil) {
            ImageRouter.getImage(imageURLString: testimonial.userCommentUrl, sizeString: widthHeight120) { (result, error) in
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

        } else {
            self.avatarImageView.image = testimonial.imageCache
        }
    }
    
}
