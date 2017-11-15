//
//  ProductModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/27/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Foundation

class ProductModel: NSObject {
    var id = ""
    var userId = ""
    
    var title = ""
    var subTitle = ""
    var productDescription = ""
    
    var imageUrl = ""
    var productUrl = ""
    
    var updatedAt = ""
    var createdAt = ""
    
    var amount: CGFloat = 0.0
    var status = 0
    
    var isBought = false // 
    
    func parseData(data: NSDictionary) {
        let id = data[kId] as? Int
        if (id != nil) {
            self.id = "\(id!)"
        }
        
        let userID = data[kUserId] as? Int
        if (userID != nil) {
            self.userId = "\(userID!)"
        }
        
        let title = data[kTitle] as? String
        if (title != nil) {
            self.title = title!
        }
        
        let subTitle = data[kSubTitle] as? String
        if (subTitle != nil) {
            self.subTitle = subTitle!
        }
        
        let productDescription = data[kDescription] as? String
        if (productDescription != nil) {
            self.productDescription = productDescription!
        }
        
        let imageUrl = data[kImageUrl] as? String
        if (imageUrl != nil) {
            self.imageUrl = imageUrl!
        }
        
        let productUrl = data["productUrl"] as? String
        if (productUrl != nil) {
            self.productUrl = productUrl!
        }
        
        let updatedAt = data["updatedAt"] as? String
        if (updatedAt != nil) {
            self.updatedAt = updatedAt!
        }
        
        let createdAt = data["createdAt"] as? String
        if (createdAt != nil) {
            self.createdAt = createdAt!
        }
        
        let amount = data["amount"] as? CGFloat
        if (amount != nil) {
            self.amount = amount!
        }
        
        let status = data["status"] as? Int
        if (status != nil) {
            self.status = status!
        }
        
    }
    
    func same(product: ProductModel) -> Bool {
        if (self.id == product.id) {
            return true
        }
        
        return false
    }
    
    func existInList(productList: [ProductModel]) -> Bool {
        for product in productList {
            if (self.same(product: product)) {
                return true
            }
        }
        
        return false
    }
    
    func checkIsPurchase() {
        ProductRouter.checkBought(productID: self.id) { (result, error) in
            print(result)
        }.fetchdata()
    }
}
