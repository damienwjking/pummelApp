//
//  DicountModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 11/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Foundation

protocol DiscountDelegate {
    func discountSynsDataCompleted(discount: DiscountModel)
}

class DiscountModel: NSObject {
    var delegate: DiscountDelegate? = nil
    
    var id = ""
    var uploadId = ""
    var businessId = ""

    var title = ""
    var subTitle = ""
    var fullText = ""
    var text = ""
    var subtext = ""
    var discount = ""
    
    var state = ""
    var country = ""
    var long = 0.0
    var lat = 0.0
    
    var website = ""
    
    var createdAt = ""
    var updatedAt = ""
    
    var imageUrl = ""
    
    var imageCache: UIImage? = nil
    var businessImageCache: UIImage? = nil
    
    func parseData(data: NSDictionary) {
        let id = data[kId] as? Int
        if (id != nil) {
            self.id = "\(id!)"
        }
        
        let uploadId = data["uploadId"] as? Int
        if (uploadId != nil) {
            self.uploadId = "\(uploadId!)"
        }
        
        let businessId = data[kBusinessId] as? Int
        if (businessId != nil) {
            self.businessId = "\(businessId!)"
        }
        
        let title = data[kTitle] as? String
        if (title != nil) {
            self.title = title!
        }
        
        let subTitle = data[kSubTitle] as? String
        if (subTitle != nil) {
            self.subTitle = subTitle!
        }
        
        let fullText = data[kFullText] as? String
        if (fullText != nil) {
            self.fullText = fullText!
        }
        
        let text = data[kText] as? String
        if (text != nil) {
            self.text = text!
        }
        
        let subtext = data[kSubText] as? String
        if (subtext != nil) {
            self.subtext = subtext!
        }
        
        let discount = data[kDiscount] as? String
        if (discount != nil) {
            self.discount = discount!
        }
        
        let state = data[kState] as? String
        if (state != nil) {
            self.state = state!
        }
        
        let country = data[kCountry] as? String
        if (country != nil) {
            self.country = country!
        }
        
        let long = data[kLong] as? String
        if (long != nil) {
//            self.long = Double(long)!
        }
        
        let lat = data[kLat] as? String
        if (lat != nil) {
//            self.lat = Double(lat)!
        }
        
        let website = data[kWebsite] as? String
        if (website != nil) {
            self.website = website!
        }
        
        let createdAt = data[kCreateAt] as? String
        if (createdAt != nil) {
            self.createdAt = createdAt!
        }
        
        let updatedAt = data[kUpdateAt] as? String
        if (updatedAt != nil) {
            self.updatedAt = updatedAt!
        }
        
        let imageUrl = data[kImageUrl] as? String
        if (imageUrl != nil) {
            self.imageUrl = imageUrl!
        }
        
    }
    
    func synsImage() {
        // Discount image
        if (self.imageUrl.isEmpty == false) {
            ImageVideoRouter.getImage(imageURLString: self.imageUrl, sizeString: widthHeightScreen, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.imageCache = imageRes
                    
                    self.callDelegate()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
        // Business logo
        if (self.businessId.isEmpty == false) {
            ImageVideoRouter.getBusinessLogo(businessID: self.businessId, sizeString: widthHeight200) { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    
                    self.businessImageCache = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
                }.fetchdata()
        }
    }
    
    func callDelegate() {
        if (self.delegate != nil) {
            self.delegate?.discountSynsDataCompleted(discount: self)
        }
    }
    
    func same(discount: DiscountModel) -> Bool {
        if (self.id == discount.id) {
            return true
        }
        
        return false
    }
    
    func existInList(discountList: [DiscountModel]) -> Bool {
        for discount in discountList {
            if (self.same(discount: discount)) {
                return true
            }
        }
        
        return false
    }
}
