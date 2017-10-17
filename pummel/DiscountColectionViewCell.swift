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

    func setData(discountDetail:NSDictionary) {
        self.lbTitle.text = ""
        self.lbSubTitle.text = ""
        self.lbText.text = ""
        self.bntDiscount.isHidden = true
        
        if let val = discountDetail[kTitle] as? String {
            self.lbTitle.text = val
        }
        
        if let val = discountDetail[kSubTitle] as? String {
            self.lbSubTitle.text = val
        }
        
        if let val = discountDetail[kText] as? String {
            self.lbText.text = val
        }
        
        if let val = discountDetail[kDiscount] as? String {
            self.bntDiscount.setTitle(val, for: .normal)
            self.bntDiscount.isHidden = false
        }
        
        
        if (discountDetail[kImageUrl] is NSNull == false) {
            let imageLink = discountDetail[kImageUrl] as! String
            
            ImageVideoRouter.getImage(imageURLString: imageLink, sizeString: widthHeightScreen, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.imgCover.image = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
}
