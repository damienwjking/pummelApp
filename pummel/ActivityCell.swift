//
//  ActivityCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 12/21/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation

class ActivityCell: UICollectionViewCell {
    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var tagBackgroundV: UIView!
    @IBOutlet weak var tagNameMaxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagNameLeftMarginConstraint: NSLayoutConstraint!
    
    var isSearch: Bool = false
    override func awakeFromNib() {
        self.layer.borderColor = UIColor(white: 151.0/255.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 2
        self.backgroundColor = UIColor.clear
        self.tagBackgroundV.layer.cornerRadius = 2
        self.tagBackgroundV.backgroundColor = self.getRandomColor()
        self.tagName.textColor = UIColor.white
        self.tagName.font = .pmmMonLight14()
        
        self.tagNameMaxWidthConstraint.constant = SCREEN_WIDTH - 9
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
