//
//  LogTableViewCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 12/19/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import Foundation


class LogTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var textLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet weak var typeLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.dateLB.numberOfLines = 2
        
        self.rateButton.layer.cornerRadius = 2;
        
        self.textLB.font = .pmmMonLight13()
        self.dateLB.font = .pmmMonLight13()
        self.timeLB.font = .pmmMonLight13()
        self.typeLB.font = .pmmMonReg13()
    }
    
    @IBAction func rateButtonClicked(sender: AnyObject) {
        
    }
    
    func setData(session: Session, hiddenRateButton: Bool) {
        self.textLB.text = session.text
        
        if session.createdAt?.isEmpty == false {
            self.dateLB.text = self.convertDateTimeFromString(session.createdAt!)
        } else {
            self.dateLB.text = ""
        }
        
        if session.datetime?.isEmpty == false {
            self.timeLB.text = self.getHourFromString(session.datetime!)
        } else {
            self.timeLB.text = ""
        }
        
        self.rateButton.hidden = hiddenRateButton
        
        self.typeLB.text = session.type
        
        var prefix = kPMAPIUSER
        //        if session.coachId != nil {
        //            prefix.appendContentsOf(String(format:"%ld", session.coachId!))
        //        } else {
        //            prefix.appendContentsOf(String(format:"%ld", session.userId!))
        //        }
        prefix.appendContentsOf(String(format:"%ld", session.userId!))
        
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetail = JSON as! NSDictionary
                if !(userDetail[kImageUrl] is NSNull) {
                    var link = kPMAPI
                    link.appendContentsOf(userDetail[kImageUrl] as! String)
                    link.appendContentsOf(widthHeight160)
                    if (NSCache.sharedInstance.objectForKey(link) != nil) {
                        let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                        self.avatarIMV.image = imageRes
                    } else {
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                self.avatarIMV.image = imageRes
                                NSCache.sharedInstance.setObject(imageRes, forKey: link)
                        }
                    }
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
        
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func convertDateTimeFromString(dateTimeString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "EEE F MMM"
        newDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let newDateString = newDateFormatter.stringFromDate(date!)
        
        return newDateString
    }
    
    func getHourFromString(dateTimeString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "ha"
        newDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let newDateString = newDateFormatter.stringFromDate(date!).uppercaseString
        
        return newDateString
    }

    
}
