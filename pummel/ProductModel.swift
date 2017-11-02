//
//  ProductModel.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/27/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation

import UIKit

class ProductModel: NSObject {
    var id = ""
    
    func parseData(data: NSDictionary) {
        
        
        print(data)
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
}
