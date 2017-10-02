//
//  FSConstants.swift
//  Fusuma
//
//  Created by Thong Nguyen on 2015/08/31.
//  Copyright © 2015年 Thong Nguyen. All rights reserved.
//

import UIKit

// Extension
internal extension UIColor {
    
    class func hex (hexStr : NSString, alpha : CGFloat) -> UIColor {
        let hexS = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = NSScanner(string: hexS as String)
        var color: UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            return UIColor.white
        }
    }
}

extension UIView {
    
    func addBottomBorder(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: width)
        border.borderWidth = width
        self.layer.addSublayer(border)
    }

}
