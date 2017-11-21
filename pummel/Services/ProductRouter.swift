//
//  ProductRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 11/2/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

enum ProductRouter: URLRequestConvertible {
    case getProductList(userID: String, offset: Int, completed: CompletionBlock)
    case getPurchaseProduct(offset: Int, completed: CompletionBlock)
    case checkBought(productID: String, completed: CompletionBlock)
    case buyProduct(productID: String, amount: Int, token: String, completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getProductList(_, _, let completed):
            return completed
            
        case .getPurchaseProduct(_, let completed):
            return completed
            
        case .checkBought(_, let completed):
            return completed
            
        case .buyProduct(_, _, _, let completed):
            return completed
            
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getProductList:
            return .get
            
        case .getPurchaseProduct:
            return .get
            
        case .checkBought:
            return .post
            
        case .buyProduct:
            return .post
            
        }
    }
    
    var path: String {
        let currentUserID = PMHelper.getCurrentID()
        
        var prefix = ""
        switch self {
        case .getProductList(let userID, _, _):
            prefix = kPMAPIUSER + userID + kPM_PATH_PRODUCT
            
        case .getPurchaseProduct:
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_PURCHASE_PRODUCT
            
        case .checkBought(let productID, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_PRODUCT + "/" + productID + kPM_PATH_CHECK_BOUGHT
            
        case .buyProduct(let productID, _, _, _):
            prefix = kPMAPIUSER + currentUserID + kPM_PATH_PRODUCT + "/" + productID + kPM_PATH_BUY
            
        }
        
        return prefix
    }
    
    var param: [String : Any]? {
        let currentUserID = PMHelper.getCurrentID()
        
        var param: [String : Any]? = [:]
        switch self {
        case .getProductList(let userID, let offset, _):
            param?[kUserId] = userID
            param?[kOffset] = offset
            param?[kLimit] = 20
            
        case .getPurchaseProduct(let offset, _):
            param?[kUserId] = currentUserID
            param?[kOffset] = offset
            param?[kLimit] = 20
            
        case .checkBought(let productID, _):
            param?[kUserId] = currentUserID
            param?["productId"] = productID
            
        case .buyProduct(let productID, let amount, let token, _):
            param?[kUserId] = currentUserID
            param?["productId"] = productID
            param?["amount"] = amount
            param?["token"] = token
            
        }
        
        return param
    }
    
    var URLRequest: NSMutableURLRequest {
        let url = NSURL(string: self.path)
        
        let mutableURLRequest = NSMutableURLRequest(url: url! as URL)
        mutableURLRequest.httpMethod = method.rawValue
        
        return mutableURLRequest
    }
    
    // For combine
    func asURLRequest() throws -> URLRequest {
        let url = NSURL(string: self.path)
        
        let mutableURLRequest = NSMutableURLRequest(url: url! as URL)
        mutableURLRequest.httpMethod = self.method.rawValue
        
        return mutableURLRequest as URLRequest
    }
    
    func fetchdata() {
        switch self {
        case .getProductList:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: ProductRouter get_product_list")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        var productList: [ProductModel] = []
                        
                        let productDetails = JSON as! [NSDictionary]
                        for productDetail in productDetails {
                            let product = ProductModel()
                            product.parseData(data: productDetail)
                            
                            productList.append(product)
                        }
                        
                        self.comletedBlock(productList as AnyObject, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .getPurchaseProduct:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: ProductRouter get_purchase_product")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let resultDetail = JSON as! NSDictionary
                        
                        self.comletedBlock(resultDetail as AnyObject, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .checkBought:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: ProductRouter check_bought")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let resultDetail = JSON as! NSDictionary
                        
                        self.comletedBlock(resultDetail as AnyObject, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        case .buyProduct:
            Alamofire.request(self.path, method: self.method, parameters: self.param).responseJSON(completionHandler: { (response) in
                print("PM: ProductRouter buy_product")
                
                switch response.result {
                case .success(let JSON):
                    if response.response?.statusCode == 200 {
                        let resultDetail = JSON as! NSDictionary
                        
                        self.comletedBlock(resultDetail as AnyObject, nil)
                    }
                case .failure(let error):
                    if (response.response?.statusCode == 401) {
                        PMHelper.showLogoutAlert()
                    } else {
                        self.comletedBlock(nil, error as NSError)
                    }
                }
            })
            
        }
    }
    
}
