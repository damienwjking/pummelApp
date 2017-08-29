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

    @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.cornerRadius = 25
        
        self.descriptionLabel.font = UIFont.pmmMonLight11()
        
        self.userNameLabel.font = UIFont.pmmMonReg11()
        
        self.titleLabel.font = UIFont.pmmMonLight11()
    }

    func setupData(testimonial: TestimonialModel) {
        self.titleLabel.text = "" // no tilte 
        
        self.userNameLabel.text = testimonial.userCommentName
        self.descriptionLabel.text = testimonial.descript
        
        if (testimonial.rating >= 0 && testimonial.rating <= 5) {
            // Width of rating star is 32
            self.ratingViewWidthConstraint.constant = 32 * CGFloat(testimonial.rating)
            
            self.ratingImageView.layoutIfNeeded()
        }
        
        ImageRouter.getImage(imageURLString: testimonial.userCommentUrl, sizeString: widthHeight120) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.avatarImageView.image = imageRes
            } else {
                self.avatarImageView.image = UIImage(named: "display-empty.jpg")
                
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
        
    }
    
}
