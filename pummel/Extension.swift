//
//  Extension.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 7/10/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    func renderImage() -> UIImage? {
        var viewSize = self.frame.size
        if (viewSize.width > SCREEN_WIDTH) {
            viewSize.width = SCREEN_WIDTH
        }
        if (viewSize.height > SCREEN_HEIGHT) {
            viewSize.height = SCREEN_HEIGHT
        }
        
        UIGraphicsBeginImageContextWithOptions(viewSize, self.opaque, 0.0)
        
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIImageView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
    
    func addBlurEffect(alpha: CGFloat = 0.5) {
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        blurEffectView.alpha = alpha
        
        self.addSubview(blurEffectView)
    }
    
    func addVibrancyEffect(alpha: CGFloat = 0.5) {
        let blurEffect = UIBlurEffect(style: .Dark)
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let effectView = UIVisualEffectView(effect: vibrancyEffect)
        
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        effectView.alpha = alpha
        
        self.addSubview(effectView)
    }
}

extension NSData {
    var dataType: String? {
        
        // Ensure data length is at least 1 byte
        guard self.length > 0 else { return nil }
        
        // Get first byte
        var c = [UInt8](count: 1, repeatedValue: 0)
        c.withUnsafeMutableBufferPointer { buffer in
            getBytes(buffer.baseAddress, length: 1)
        }
        // Identify data type
        switch (c[0]) {
        case 0xFF:
            return "jpg"
        case 0x89:
            return "png"
        case 0x47:
            return "gif"
        case 0x49, 0x4D:
            return "tiff"
        default:
            return nil //unknown
        }
    }
    
}

extension String {
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func sliceFrom(start: String, to: String) -> String? {
        return (rangeOfString(start)?.endIndex).flatMap { sInd in
            (rangeOfString(to, range: sInd..<endIndex)?.startIndex).map { eInd in
                substringWithRange(sInd..<eInd)
            }
        }
    }
    
    func isValidEmail() -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", kEmailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}

extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joinWithSeparator("&")
    }
    
}
