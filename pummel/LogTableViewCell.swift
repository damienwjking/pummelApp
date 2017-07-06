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

@objc protocol LogCellDelegate: class {
    optional func LogCellClickAddCalendar(cell: LogTableViewCell)
}

class LogTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var textLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var actionBT: UIButton!
    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var typeLB: UILabel!
    
    var isUpComingCell = false
    
    weak var logCellDelegate: LogCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.dateLB.numberOfLines = 2
        
        self.actionView.layer.cornerRadius = 2;
        self.actionView.layer.masksToBounds = true;
        
        self.textLB.font = .pmmMonLight13()
        self.dateLB.font = .pmmMonLight13()
        self.timeLB.font = .pmmMonLight13()
        self.typeLB.font = .pmmMonReg13()
        self.actionBT.titleLabel!.font = .pmmMonReg10()
    }
    
    @IBAction func actionButtonClicked(sender: AnyObject) {
        if self.isUpComingCell {
            // Add calendar action
            self.logCellDelegate?.LogCellClickAddCalendar!(self)
        } else {
            // Rate action
        }
    }
    
    func setData(session: Session, isUpComing: Bool) {
        self.textLB.text = session.text
        
        if session.datetime?.isEmpty == false {
            let localDateTimeString = self.convertUTCTimeToLocalTime(session.datetime!)
            self.dateLB.text = self.convertDateTimeFromString(localDateTimeString)
            self.timeLB.text = self.getHourFromString(localDateTimeString)
        } else {
            self.dateLB.text = ""
            self.timeLB.text = ""
        }
        
        self.isUpComingCell = isUpComing
        if isUpComing {
            self.actionBT.setTitle("Add to Calendar", forState: .Normal)
        } else {
            self.actionBT.setTitle("Rate", forState: .Normal)
        }
        
        self.typeLB.text = session.type
        
        let userID = String(format:"%ld", session.userId!)
        ImageRouter.getUserAvatar(userID: userID, sizeString: widthHeight160) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.avatarIMV.image = imageRes
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
        
        UserRouter.checkCoachOfUser(userID: userID) { (result, error) in
            if (error == nil) {
                let isCoach = result as! Bool
                
                if isCoach {
                    self.avatarIMV.layer.borderWidth = 3
                    self.avatarIMV.layer.borderColor = UIColor.pmmBrightOrangeColor().CGColor
                }
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
        
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func convertDateTimeFromString(dateTimeString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "EEE dd MMM"
//        newDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let newDateString = newDateFormatter.stringFromDate(date!)
        
        return newDateString
    }
    
    func getHourFromString(dateTimeString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "ha"
        newDateFormatter.timeZone = NSTimeZone.localTimeZone()
        let newDateString = newDateFormatter.stringFromDate(date!).uppercaseString
        
        return newDateString
    }
    
    func convertUTCTimeToLocalTime(dateTimeString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let date = dateFormatter.dateFromString(dateTimeString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = kFullDateFormat
        newDateFormatter.timeZone = NSTimeZone.localTimeZone()
        let newDateString = newDateFormatter.stringFromDate(date!)
        
        return newDateString
    }
    
}
