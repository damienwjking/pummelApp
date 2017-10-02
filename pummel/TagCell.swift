//
//  TagCell.swift
//  TagFlowLayout
//
//  Created by Bear Daddy on 6/27/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var tagBackgroundV: UIView!
    @IBOutlet weak var tagNameMaxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagNameLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagImage: UIImageView!
    var isSearch: Bool = false
    override func awakeFromNib() {
        self.layer.borderColor = UIColor(white: 151.0/255.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.clear
        self.tagBackgroundV.backgroundColor = UIColor.clear
        self.tagBackgroundV.layer.cornerRadius = 2
        self.tagName.textColor = UIColor.white
        self.tagName.font = .pmmMonLight14()
        self.layer.cornerRadius = 2
        
        self.tagNameMaxWidthConstraint.constant = UIScreen.mainScreen().bounds.width - 9
        self.tagImageConstraint.constant = self.frame.height/2 - 18
        self.tagImage.layer.cornerRadius = 5
        if (isSearch ==  false) {self.tagImage.backgroundColor = self.getRandomColor()}
        self.tagImage.clipsToBounds = true
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func setupData(tag: Tag) {
        self.tagName.text = tag.name
        self.tagName.textColor = UIColor.black
        self.layer.borderColor = UIColor.clear.cgColor
    }
}
