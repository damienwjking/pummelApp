//
//  DiscountDetailVC.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 6/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Alamofire

class DiscountDetailVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var imgCover:UIImageView!
    @IBOutlet weak var imgLogo:UIImageView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var lbSubTitle:UILabel!
    @IBOutlet weak var lbText:UILabel!
    
    @IBOutlet weak var btnDiscount:UIButton!
    @IBOutlet weak var lbDescription:UILabel!
    @IBOutlet weak var tvLink:UITextView!
    @IBOutlet weak var lbFullText:UILabel!
    
    var businessDetail:NSDictionary!
    var discountDetail:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbTitle.font = UIFont.pmmMonReg20()
        self.lbTitle.textColor = UIColor.whiteColor()
        
        self.lbSubTitle.font = UIFont.pmmMonReg16()
        self.lbSubTitle.textColor = UIColor.whiteColor()
        
        self.lbText.textColor = UIColor.whiteColor()
        self.lbText.font = UIFont.pmmMonLight16()
        
        self.btnDiscount.layer.borderColor = UIColor.whiteColor().CGColor
        self.btnDiscount.layer.cornerRadius = 15
        self.btnDiscount.layer.borderWidth = 1
        self.btnDiscount.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        self.lbTitle.text = ""
        self.lbSubTitle.text = ""
        self.lbText.text = ""
        self.tvLink.delegate = self
        self.tvLink.text = ""
        self.lbDescription.text = ""
        self.lbFullText.text = ""
        
        self.updateData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
            self.btnDiscount.setTitle(val, forState: .Normal)
            self.btnDiscount.hidden = false
        }
        
        if let val = discountDetail[kSubText] as? String {
            self.lbDescription.text = val
        }
        
        if let val = discountDetail[kWebsite] as? String {
            self.tvLink.text = val
        }
        
        if let val = discountDetail[kFullText] as? String {
            self.lbFullText.text = val
        }
        
        // Get bussiness
        let businessId = String(format:"%0.f", discountDetail[kBusinessId]!.doubleValue)
        var linkBusinessId = kPMAPI_BUSINESS
        linkBusinessId.appendContentsOf(businessId)
        Alamofire.request(.GET, linkBusinessId)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    if let jsonBusiness = response.result.value as? NSDictionary {
                        self.businessDetail = jsonBusiness
                        self.fillData()
                    }
                }
        }
    }
    
    func fillData() {
        self.lbDescription.font = UIFont.pmmMonReg16()
        self.imgLogo.layer.cornerRadius = 75
        self.imgLogo.clipsToBounds = true
        
        self.tvLink.font = .pmmMonReg16()
        self.tvLink.linkTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg16(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor(), NSUnderlineStyleAttributeName: NSNumber(int: 1)]
        
        let postfix = widthEqual.stringByAppendingString(String(self.imgLogo.bounds.width)).stringByAppendingString(heighEqual).stringByAppendingString(String(self.imgLogo.bounds.height))
        if !(businessDetail[kImageUrl] is NSNull) {
            let imageLink = businessDetail[kImageUrl] as! String
            var prefix = kPMAPI
            prefix.appendContentsOf(imageLink)
            prefix.appendContentsOf(postfix)
            if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                self.imgLogo.image = imageRes
            } else {
                Alamofire.request(.GET, prefix)
                    .responseImage { response in
                        if (response.response?.statusCode == 200) {
                            let imageRes = response.result.value! as UIImage
                            self.imgLogo.image = imageRes
                            NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                        }
                }
            }
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        self.openWebview()
        return false
    }
    
    func openWebview() {
        if let val = discountDetail[kWebsite] as? String {
            let urlWeb = NSURL(string: val)
            if urlWeb != nil {
                self.performSegueWithIdentifier(kClickURLLink, sender: urlWeb)
            }
        }
    }
    
    @IBAction func logoClicked() {
        self.openWebview()
    }
    
    @IBAction func buttonDiscountClicked() {
        self.openWebview()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == kClickURLLink) {
            let destination = segue.destinationViewController as! FeedWebViewController
            destination.URL = sender as? NSURL
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked() {
        _ = self.navigationController?.popViewControllerAnimated(true)
    }
}
