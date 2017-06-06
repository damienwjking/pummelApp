//
//  ImageRouter.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 6/6/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import Alamofire

typealias CompletionBlock = (result: NSData?, error: NSError?) -> Void

let defaults = NSUserDefaults.standardUserDefaults()

enum ImageRouter: URLRequestConvertible {
    case getCurrentUserAvatar(completed: CompletionBlock)
    case getUserAvatar(userID : String, completed: CompletionBlock)
    case getImage(pathString: String, size: CGFloat, completed: CompletionBlock)
    
    var comletedBlock: CompletionBlock {
        switch self {
        case .getCurrentUserAvatar(let completed):
            return completed
        case .getUserAvatar(_, let completed):
            return completed
        case .getImage(_, _, let completed):
            return completed
        }
    }
    
    var method: Alamofire.Method {
        switch self {
        case .getCurrentUserAvatar:
            return .GET
        case .getUserAvatar:
            return .GET
        case .getImage:
            return .GET
        }
    }
    
    var path: String {
        var prefix = kPMAPIUSER
        
        switch self {
        case .getCurrentUserAvatar:
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)

        case .getUserAvatar:
            prefix = ""
            
        case .getImage:
            prefix = ""
        }
        
        return prefix
    }
    
    // MARK: URLRequestConvertible
    var URLRequest: NSMutableURLRequest {
        //        let mutableURLRequest = NSMutableURLRequest.create(path, method: method.rawValue)!
        let url = NSURL(string: self.path)
        
        let mutableURLRequest = NSMutableURLRequest(URL: url!)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        default:
            return mutableURLRequest
        }
    }
    
    func fetchdata() {
        Alamofire.request(self.method, self.path).response { (request, respone, result, error) in
//            if (respone?.statusCode == 200) {
//                
//            } else {
//                
//            }
            self.comletedBlock(result:  result, error: error)
        }
    }
}
