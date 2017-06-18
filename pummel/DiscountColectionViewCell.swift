//
//  DiscountColectionViewCell.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 6/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Alamofire

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
        
        self.lbTitle.textColor = UIColor.whiteColor()
        self.lbTitle.font = UIFont.pmmMonReg18()
        
        self.lbSubTitle.textColor = UIColor.whiteColor()
        self.lbSubTitle.font = UIFont.pmmMonReg13()
        
        self.lbText.textColor = UIColor.whiteColor()
        self.lbText.font = UIFont.pmmMonLight13()
        
        self.bntDiscount.layer.borderColor = UIColor.whiteColor().CGColor
        self.bntDiscount.layer.cornerRadius = 15
        self.bntDiscount.layer.borderWidth = 1
        self.bntDiscount.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }

    func setData(discountDetail:NSDictionary) {
        self.lbTitle.text = ""
        self.lbSubTitle.text = ""
        self.lbText.text = ""
        self.bntDiscount.hidden = true
        
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
            self.bntDiscount.setTitle(val, forState: .Normal)
            self.bntDiscount.hidden = false
        }
        
        let postfix = widthEqual.stringByAppendingString(String(self.bounds.width)).stringByAppendingString(heighEqual).stringByAppendingString(String(self.bounds.height))
        if !(discountDetail[kImageUrl] is NSNull) {
            let imageLink = discountDetail[kImageUrl] as! String
            var prefix = kPMAPI
            prefix.appendContentsOf(imageLink)
            prefix.appendContentsOf(postfix)
            if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                self.imgCover.image = imageRes
            } else {
                Alamofire.request(.GET, prefix)
                    .responseImage { response in
                        if (response.response?.statusCode == 200) {
                            let imageRes = response.result.value! as UIImage
                            self.imgCover.image = imageRes
                            NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                        }
                }
            }
        }
    }
}
