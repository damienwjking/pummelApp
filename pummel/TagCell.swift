//
//  TagCell.swift
//  TagFlowLayout


import UIKit

class TagCell: UICollectionViewCell {
    
    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var tagBackgroundV: UIView!
    @IBOutlet weak var tagNameMaxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagNameLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagImage: UIImageView!
    override func awakeFromNib() {
        self.layer.borderColor = UIColor(white: 151.0/255.0, alpha: 1.0).CGColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.clearColor()
        self.tagBackgroundV.backgroundColor = UIColor.clearColor()
        self.tagBackgroundV.layer.cornerRadius = 2
        self.tagName.textColor = UIColor.whiteColor()
        self.tagName.font = UIFont(name: "Montserrat-Light", size: 14)
        self.layer.cornerRadius = 2
        
        self.tagNameMaxWidthConstraint.constant = UIScreen.mainScreen().bounds.width - 8 * 2 
        self.tagImageConstraint.constant = self.frame.height/2 - 18
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
