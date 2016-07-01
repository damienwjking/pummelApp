//
//  TagCell.swift
//  TagFlowLayout
//
//  Created by Diep Nguyen Hoang on 7/30/15.
//  Copyright (c) 2015 CodenTrick. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var tagNameMaxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagImage: UIImageView!
    override func awakeFromNib() {
        self.layer.borderColor = UIColor(white: 151.0/255.0, alpha: 1.0).CGColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.clearColor()
        self.tagName.textColor = UIColor.whiteColor()
        self.tagName.font = UIFont(name: "PlayfairDisplay-Light", size: 14)
        self.layer.cornerRadius = 2
        
        self.tagNameMaxWidthConstraint.constant = UIScreen.mainScreen().bounds.width - 8 * 2 - 8 * 2
        self.tagImageConstraint.constant = self.frame.height/2 - 16
        self.tagImage.layer.cornerRadius = 5
        self.tagImage.backgroundColor = self.getRandomColor()
        self.tagImage.clipsToBounds = true
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
