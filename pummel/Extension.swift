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
        
        UIGraphicsBeginImageContextWithOptions(viewSize, self.isOpaque, 0.0)
        
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIImageView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addBlurEffect(alpha: CGFloat = 0.5) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = alpha
        
        self.addSubview(blurEffectView)
    }
    
    func addVibrancyEffect(alpha: CGFloat = 0.5) {
        let blurEffect = UIBlurEffect(style: .dark)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let effectView = UIVisualEffectView(effect: vibrancyEffect)
        
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = alpha
        
        self.addSubview(effectView)
    }
}

extension NSData {
    var dataType: String? {
        
        // Ensure data length is at least 1 byte
        guard self.length > 0 else { return nil }
        
        // Get first byte
        var c = [UInt8](repeating: 0, count: 1)
        c.withUnsafeMutableBufferPointer { buffer in
            getBytes(buffer.baseAddress!, length: 1)
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
    
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters as CharacterSet)
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func isValidEmail() -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", kEmailRegEx)
        return emailTest.evaluate(with: self)
    }
}

extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    func randomAString()-> String {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed*255), Int(randomGreen*255),Int(randomBlue*255),255)
    }
}

extension UIApplication {
    class func appVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        let appversion = "Pummel " + version
        
        return appversion
    }
    
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion()
        let build = appBuild()
        
        return version == build ? "\(version)" : "\(version)(\(build))"
    }
}

extension UICollectionView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

extension UITableView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

extension Array {
    func randomElement() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}
