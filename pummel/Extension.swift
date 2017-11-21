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

extension UIBarButtonItem {
    func setAttributeForAllStage(textFont: UIFont = UIFont.pmmMonReg13(), textColor: UIColor = UIColor.pmmBrightOrangeColor()) {
        self.setTitleTextAttributes([NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor], for: .normal)
        
        self.setTitleTextAttributes([NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor], for: .highlighted)
        
        self.setTitleTextAttributes([NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor], for: .disabled)
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
}

extension Data {
    var hexString: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

extension NSDate {
    func timeAgoSinceDate() -> String {
        let calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let now = NSDate()
        let earliest = now.earlierDate(self as Date)
        let latest = (earliest == now as Date) ? self : now
        let components = calendar.dateComponents(unitFlags, from: earliest, to: latest as Date)
        
        if (components.year! >= 1) {
            return "\(components.year!) y"
        } else if (components.month! >= 1) {
            return "\(components.month!) month"
        } else if (components.day! >= 1) {
            return "\(components.day!) d"
        } else if (components.hour! >= 1) {
            return "\(components.hour!) hr"
        } else if (components.minute! >= 1) {
            return "\(components.minute!) m"
        } else if (components.second! >= 4) {
            return "\(components.second!) s"
        } else {
            return "Just now"
        }
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
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isNumber() -> Bool {
        do {
            let numberRegex = try NSRegularExpression(pattern: "[0-9]", options:.caseInsensitive)
            let numberString = self as NSString
            let results = numberRegex.matches(in: self, options: [], range: NSMakeRange(0, numberString.length))
            
            if results.count == numberString.length {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func removeNonDigits() -> String{
        var i = 0
        var numberText = ""
        
        while (i < self.count) {
            let start = self.index(self.startIndex, offsetBy: i )
            var checkString = self.substring(from: start)
            
            let end = checkString.index(checkString.startIndex, offsetBy: 1)
            checkString = checkString.substring(to: end)
            if (checkString.isNumber() == true) {
                numberText = numberText + checkString
            }
            
            i = i + 1
        }
        
        return numberText
    }
    
    func insertSpacesEveryFourDigitsIntoString() -> String {
        var newString = ""
        
        var i = 0
        while (i <= (self.count / 4)) {
            let start = self.index(self.startIndex, offsetBy: i * 4)
            var s = self.substring(from: start)
            
            let endIndex = s.count > 4 ? 4 : s.count
            let end = s.index(s.startIndex, offsetBy: endIndex)
            s = s.substring(to: end)
            
            if (i == 0) {
                newString = s
            } else {
                newString = newString + " " + s
            }
            
            i = i + 1
        }
        
        return newString
    }
    
    func insertSlashEveryTwoDigitsIntoString() -> String {
        var newString = ""
        
        var i = 0
        while (i <= (self.count / 2)) {
            let start = self.index(self.startIndex, offsetBy: i * 2)
            var s = self.substring(from: start)
            
            let endIndex = s.count > 2 ? 2 : s.count
            let end = s.index(s.startIndex, offsetBy: endIndex)
            s = s.substring(to: end)
            
            if (i == 0) {
                newString = s
            } else {
                newString = newString + " " + s
            }
            
            i = i + 1
        }
        
        return newString
    }
    
    func insert(inserString: String, afterNumberChar numberChar: Int) -> String {
        var newString = ""
        
        var i = 0
        while (i <= (self.count / numberChar)) {
            let start = self.index(self.startIndex, offsetBy: i * numberChar)
            var s = self.substring(from: start)
            
            let endIndex = s.count > numberChar ? numberChar : s.count
            let end = s.index(s.startIndex, offsetBy: endIndex)
            s = s.substring(to: end)
            
            if (i == 0) {
                newString = s
            } else if (i * numberChar == self.count) {
                newString = newString + s
            } else {
                newString = newString + inserString + s
            }
            
            i = i + 1
        }
        
        return newString
    }
    
}

extension CGFloat {
    func toCurrency(withSymbol symbol: String) -> String? {
        let numberFormat = NumberFormatter()
        numberFormat.currencySymbol = symbol
        numberFormat.numberStyle = .currency
        numberFormat.formatWidth = 3
        numberFormat.generatesDecimalNumbers = true
        numberFormat.alwaysShowsDecimalSeparator = false
        
        let moneyString = numberFormat.string(from: NSNumber(value: Double(self)))
        
        return moneyString
    }
}

extension Int {
    func toCurrency(withSymbol symbol: String) -> String? {
        let numberFormat = NumberFormatter()
        numberFormat.currencySymbol = symbol
        numberFormat.numberStyle = .currency
        numberFormat.formatWidth = 3
        numberFormat.generatesDecimalNumbers = true
        numberFormat.alwaysShowsDecimalSeparator = false
        
        let moneyString = numberFormat.string(from: NSNumber(value: self))
        
        return moneyString
    }
}

extension Double {
    func toCurrency(withSymbol symbol: String) -> String? {
        let numberFormat = NumberFormatter()
        numberFormat.currencySymbol = symbol
        numberFormat.numberStyle = .currency
        numberFormat.formatWidth = 3
        numberFormat.generatesDecimalNumbers = true
        numberFormat.alwaysShowsDecimalSeparator = false
        
        let moneyString = numberFormat.string(from: NSNumber(value: self))
        
        return moneyString
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

extension UITextView {
    func getHeightWithWidthFixed() -> CGFloat {
        let constraintRect = CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.text.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: self.font ?? UIFont.systemFont(ofSize: 13)], context: nil)
        
        let height = boundingBox.height + self.layoutMargins.top + self.layoutMargins.bottom
        
        return height
    }
}

extension UITextField {
    func reformatAsCardNumber() {
        var textWithoutSpace = self.text?.removeNonDigits()
        
        // 19 is maximum visa number
        let maxChar = 19
        if (textWithoutSpace!.count > maxChar) {
            let end = textWithoutSpace?.index(textWithoutSpace!.startIndex, offsetBy: maxChar)
            textWithoutSpace = textWithoutSpace!.substring(to: end!)
        }
        
        let textWithSpace = textWithoutSpace!.insert(inserString: " ", afterNumberChar: 4)
        
        self.text = textWithSpace
    }
    
    func reformatAsExpireMonth() {
        var textWithoutSlash = self.text?.removeNonDigits()
        
        // 4 is maximum expire number
        let maxChar = 4
        if (textWithoutSlash!.count > maxChar) {
            let end = textWithoutSlash!.index(textWithoutSlash!.startIndex, offsetBy: maxChar)
            textWithoutSlash = textWithoutSlash!.substring(to: end)
        }
        
        let textWithSlash = textWithoutSlash!.insert(inserString: "/", afterNumberChar: 2)
        
        self.text = textWithSlash
    }
    
    func reformatAsCVC() {
        var text = self.text?.removeNonDigits()
        
        // 3 is maximum CVC number
        let maxChar = 3
        if (text!.count > maxChar) {
            let end = text!.index(text!.startIndex, offsetBy: maxChar)
            text = text!.substring(to: end)
        }
        
        self.text = text
    }
    
    func reformatAsNumber() {
        let text = self.text?.removeNonDigits()
        
        let maxNumber = 1000
        if (Int(text!)! > maxNumber) {
            self.text = "\(maxNumber)"
        } else {
            self.text = text
        }
    }
    
}
