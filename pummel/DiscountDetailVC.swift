//
//  DiscountDetailVC.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 6/13/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

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
    
    var discount : DiscountModel!
    
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
        
        self.imgLogo.layer.cornerRadius = 75
        self.imgLogo.clipsToBounds = true
        
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
        self.discount.delegate = self
        
        self.lbTitle.text = self.discount.title
        self.lbSubTitle.text = self.discount.subTitle
        self.lbText.text = self.discount.text
        self.lbDescription.text = self.discount.subtext
        self.lbFullText.text = self.discount.fullText
        
        self.imgCover.image = self.discount.imageCache
        
        self.imgLogo.image = self.discount.businessImageCache
        
        self.btnDiscount.isHidden = true
        if (self.discount.discount.count > 0) {
            self.btnDiscount.setTitle(self.discount.discount, for: .normal)
            self.btnDiscount.isHidden = false
        }
        
        if (self.discount.website.isEmpty == false) {
            self.tvLink.text = self.discount.website
            
            // Set color for link
            self.tvLink.linkTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg16(),
                                              NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor(),
                                              NSUnderlineStyleAttributeName: NSNumber(value: 1)]
            
            // Set height for link
            let textMarginVertical = self.tvLink.layoutMargins.left + self.tvLink.layoutMargins.right
            let textMarginHorizontal = self.tvLink.layoutMargins.top + self.tvLink.layoutMargins.bottom
            
            let textWidth = self.tvLink.frame.size.width - textMarginVertical
            let heightLinkText = self.tvLink.text.heightWithConstrainedWidth(width: textWidth, font: self.tvLink.font!)
            
            self.tvLinkHeightConstraint.constant = heightLinkText + textMarginHorizontal
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.openWebview()
        return false
    }
    
    func openWebview() {
        if (self.discount.website.isEmpty == false) {
            let urlWeb = NSURL(string: self.discount.website)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == kClickURLLink) {
            let destination = segue.destination as! FeedWebViewController
            destination.URL = sender as? NSURL
        }
    }
    
    @IBAction func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DiscountDetailVC: DiscountDelegate {
    func discountSynsDataCompleted(discount: DiscountModel) {
        self.updateData()
    }
}
