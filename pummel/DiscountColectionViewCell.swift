//
//  DiscountColectionViewCell.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 6/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class DiscountColectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgCover:UIImageView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var lbSubTitle:UILabel!
    @IBOutlet weak var lbText:UILabel!
    @IBOutlet weak var bntDiscount:UIButton!
    @IBOutlet weak var viewGradient:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgCover.layer.cornerRadius = 5
        self.imgCover.clipsToBounds = true
        self.viewGradient.layer.cornerRadius = 5
        
        self.lbTitle.textColor = UIColor.white
        self.lbTitle.font = UIFont.pmmMonReg18()
        
        self.lbSubTitle.textColor = UIColor.white
        self.lbSubTitle.font = UIFont.pmmMonReg13()
        
        self.lbText.textColor = UIColor.white
        self.lbText.font = UIFont.pmmMonLight13()
        
        self.bntDiscount.layer.borderColor = UIColor.white.cgColor
        self.bntDiscount.layer.cornerRadius = 15
        self.bntDiscount.layer.borderWidth = 1
        self.bntDiscount.setTitleColor(UIColor.white, for: .normal)
    }

    func setData(discount: DiscountModel) {
        self.lbTitle.text = discount.title
        self.lbSubTitle.text = discount.subTitle
        self.lbText.text = discount.text
        
        self.bntDiscount.isHidden = true
        if (discount.discount.count > 0) {
            self.bntDiscount.setTitle(discount.discount, for: .normal)
            self.bntDiscount.isHidden = false
        }
        
        if (discount.imageUrl.isEmpty == false) {
            self.imgCover.image = discount.imageCache
        }
    }
}
