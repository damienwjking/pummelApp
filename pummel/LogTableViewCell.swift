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
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var messageLB: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet weak var typeLBHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeLBBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.messageLB.numberOfLines = 2
        
        self.rateButton.layer.cornerRadius = 2;
        
        self.nameLB.font = .pmmMonLight16()
        self.messageLB.font = .pmmMonLight13()
        self.timeLB.font = .pmmMonLight13()
        self.typeLB.font = .pmmMonLight13()
    }
    
    @IBAction func rateButtonClicked(sender: AnyObject) {
        
    }
    
    func setData(session: Session, hiddenRateButton: Bool) {
        self.nameLB.text = session.text
        self.messageLB.text = self.convertDateTimeFromString(session.createdAt!)
        self.timeLB.text = self.getHourFromString(session.datetime!)
        self.rateButton.hidden = hiddenRateButton
        
        self.typeLB.text = session.type
        if session.type?.isEmpty == true {
            self.typeLBHeightConstraint.constant = 0
            self.typeLBBottomConstraint.constant = 0
        } else {
            self.typeLBHeightConstraint.constant = 21
            self.typeLBBottomConstraint.constant = 5.5
        }
        
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
    
    func convertDateTimeFromString(dateTimeString: String) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "EEE F MMM"
        let newDateString = newDateFormatter.stringFromDate(date!)
        
        return newDateString
    }
    
    func getHourFromString(dateTimeString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "ha"
        let newDateString = newDateFormatter.stringFromDate(date!).uppercaseString
        
        return newDateString
    }

    
}
