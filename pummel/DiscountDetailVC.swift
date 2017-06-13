//
//  DiscountDetailVC.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 6/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Alamofire

class DiscountDetailVC: UIViewController {

    @IBOutlet weak var imgCover:UIImageView!
    
    var discountDetail:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateData()
    }
    
    func updateData() {
        let postfix = widthEqual.stringByAppendingString(String(self.imgCover.bounds.width)).stringByAppendingString(heighEqual).stringByAppendingString(String(self.imgCover.bounds.height))
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
        
        // Get bussiness
        let businessId = String(format:"%0.f", discountDetail[kBusinessId]!.doubleValue)
        var linkBusinessId = kPMAPI_BUSINESS
        linkBusinessId.appendContentsOf(businessId)
        Alamofire.request(.GET, linkBusinessId)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    let jsonBusiness = response.result.value as! NSDictionary
                    print(jsonBusiness)
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
