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
    
    @IBOutlet weak var tvLinkHeightConstraint: NSLayoutConstraint!
    
    var discountDetail:NSDictionary!
    
    // MARK: - Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbTitle.font = UIFont.pmmMonReg20()
        self.lbTitle.textColor = UIColor.white
        
        self.lbSubTitle.font = UIFont.pmmMonReg16()
        self.lbSubTitle.textColor = UIColor.white
        
        self.lbText.textColor = UIColor.white
        self.lbText.font = UIFont.pmmMonLight16()
        
        self.lbDescription.font = UIFont.pmmMonLight16()
        self.lbFullText.font = UIFont.pmmMonLight16()
        self.tvLink.font = .pmmMonLight16()
        
        self.btnDiscount.layer.borderColor = UIColor.white.cgColor
        self.btnDiscount.layer.cornerRadius = 15
        self.btnDiscount.layer.borderWidth = 1
        self.btnDiscount.setTitleColor(UIColor.white, for: .normal)
        
        self.lbTitle.text = ""
        self.lbSubTitle.text = ""
        self.lbText.text = ""
        self.tvLink.delegate = self
        self.tvLink.text = ""
        self.lbDescription.text = ""
        self.lbFullText.text = ""
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.updateData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func updateData() {
        self.imgLogo.layer.cornerRadius = 75
        self.imgLogo.clipsToBounds = true
        
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
            self.btnDiscount.setTitle(val, for: .normal)
            self.btnDiscount.isHidden = false
        }
        
        if let val = discountDetail[kSubText] as? String {
            self.lbDescription.text = val
        }
        
        if let val = discountDetail[kWebsite] as? String {
            self.tvLink.text = val
            
            // Set color for link
            self.tvLink.linkTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg16(),
                                              NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor(),
                                              NSUnderlineStyleAttributeName: NSNumber(value: 1)]
            
            // Set height for link
            let textMarginVertical = self.tvLink.layoutMargins.left + self.tvLink.layoutMargins.right
            let textMarginHorizontal = self.tvLink.layoutMargins.top + self.tvLink.layoutMargins.bottom
            
            let textWidth = self.tvLink.frame.size.width - textMarginVertical
            let heightLinkText = val.heightWithConstrainedWidth(width: textWidth, font: self.tvLink.font!)
            
            self.tvLinkHeightConstraint.constant = heightLinkText + textMarginHorizontal
        }
        
        if let val = discountDetail[kFullText] as? String {
            self.lbFullText.text = val
        }
        
        // Get bussiness
        let businessId = String(format:"%0.f", (discountDetail[kBusinessId]! as AnyObject).doubleValue)
        ImageVideoRouter.getBusinessLogo(businessID: businessId, sizeString: widthHeight200) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                
                self.imgLogo.image = imageRes
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.openWebview()
        return false
    }
    
    func openWebview() {
        if let val = discountDetail[kWebsite] as? String {
            let urlWeb = NSURL(string: val)
            if urlWeb != nil {
                self.performSegue(withIdentifier: kClickURLLink, sender: urlWeb)
            }
        }
    }
    
    @IBAction func logoClicked() {
        self.openWebview()
    }
    
    @IBAction func buttonDiscountClicked() {
        self.openWebview()
    }

    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == kClickURLLink) {
            let destination = segue.destination as! FeedWebViewController
            destination.URL = sender as? NSURL
        }
    }
    
    @IBAction func backButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
