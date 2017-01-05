//
//  DetailSessionViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 1/4/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Alamofire

class DetailSessionViewController: UIViewController {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var sessionIMV: UIImageView!
    @IBOutlet weak var sessionScrollView: UIScrollView!
    
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var distanceLB: UILabel!
    @IBOutlet weak var intensityLB: UILabel!
    @IBOutlet weak var caloriesLB: UILabel!
    
    @IBOutlet weak var userIMV: UIImageView!
    @IBOutlet weak var coachIMV: UIImageView!
    @IBOutlet weak var coachIMVWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coachIMVLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sessionTagIMV: UIImageView!
    
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var contentTV: UITextView!
    
    @IBOutlet weak var timeV: UIView!
    @IBOutlet weak var distanceV: UIView!
    @IBOutlet weak var intensityV: UIView!
    @IBOutlet weak var caloriesV: UIView!
    
    @IBOutlet weak var tappedV: UIView!
    
    @IBOutlet weak var timeVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var intensityVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var caloriesVHeightConstraint: NSLayoutConstraint!
    
    var session = Session()
    var sessionTagColorString = "#FFFFFF"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sessionTagColorString = self.getRandomColorString()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backClicked))
        
        self.initLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.session.longtime = 90
        self.session.distance = 250
        self.session.intensity = "Light"
        self.session.calorie = 250
        
        self.typeLabel.text = self.session.type?.componentsSeparatedByString(" ").joinWithSeparator("")
        
        self.title = kSession
        
        self.setUserAvatar()
        
        if self.session.imageUrl?.isEmpty == false {
            self.setSessionImage()
        } else {
            self.sessionIMV.backgroundColor = UIColor.init(hexString: self.sessionTagColorString)
        }
        
        if self.session.coachId != nil {
            self.setCoachAvatar()
            self.coachIMVWidthConstraint.constant = 40
            self.coachIMVLeadingConstraint.constant = 8;
        } else {
            self.coachIMVWidthConstraint.constant = 0
            self.coachIMVLeadingConstraint.constant = 0;
        }
        
        self.setData()
    }
    
    func setData() {
        if self.session.text?.isEmpty == false {
            self.contentTV.text = self.session.text
        } else {
            self.contentTV.text = ""
        }
        
        if self.session.longtime != nil && self.session.longtime != 0 {
            self.timeLB.text = String(format: "%ld minutes", self.session.longtime!)
            
            self.timeV.hidden = false
            self.timeVHeightConstraint.constant = 50;
        } else {
            self.timeV.hidden = true
            self.timeVHeightConstraint.constant = 0;
        }
        
        if self.session.intensity?.isEmpty == false {
            self.intensityLB.text = self.session.intensity
            self.intensityV.hidden = false
            self.intensityVHeightConstraint.constant = 50
        } else {
            self.intensityV.hidden = true
            self.intensityVHeightConstraint.constant = 0
        }
        
        if self.session.distance != nil && self.session.distance != 0 {
            let distanceUnit = self.defaults.objectForKey(kUnit) as? String
            if (distanceUnit == metric) {
                self.distanceLB.text = String(format: "%ld kms", self.session.distance!)
            } else {
                self.distanceLB.text = String(format: "%ld mi", self.session.distance!)
            }
            
            self.distanceV.hidden = false
            self.distanceVHeightConstraint.constant = 50
        } else {
            self.distanceV.hidden = true
            self.distanceVHeightConstraint.constant = 0
        }
        
        if self.session.calorie != nil && self.session.calorie != 0 {
            self.caloriesLB.text = String(format: "%ld", self.session.calorie!)
            self.caloriesV.hidden = false
            self.caloriesVHeightConstraint.constant = 50
        } else {
            self.caloriesV.hidden = true
            self.caloriesVHeightConstraint.constant = 0
        }
        
        if self.session.datetime?.isEmpty == false {
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = kFullDateFormat
            let date = timeFormatter.dateFromString(self.session.datetime!)
            timeFormatter.dateFormat = "MMM dd, YYYY hh:mm aaa"
            self.dateTF.text = timeFormatter.stringFromDate(date!)
        }
    }
    
    func initLayout() {
        self.typeLabel.font = .pmmMonReg13()
        self.timeLB.font = .pmmMonLight13()
        self.distanceLB.font = .pmmMonLight13()
        self.intensityLB.font = .pmmMonLight13()
        self.caloriesLB.font = .pmmMonLight13()
        
        self.dateTF.font = UIFont.pmmMonReg13()
        
        self.userIMV.layer.cornerRadius = 20
        self.userIMV.clipsToBounds = true
        
        self.coachIMV.layer.cornerRadius = 20
        self.coachIMV.clipsToBounds = true

        self.sessionTagIMV.layer.cornerRadius = 20
        self.sessionTagIMV.clipsToBounds = true
        self.sessionTagIMV.backgroundColor = UIColor.init(hexString: sessionTagColorString)
        
        self.contentTV.font = UIFont.pmmMonReg13()
        self.contentTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
    }
    
    func setSessionImage() {
        if self.session.imageUrl?.isEmpty == false {
            let imageLink = self.session.imageUrl
            var prefix = kPMAPI
            prefix.appendContentsOf(imageLink!)
            let postfix = widthEqual.stringByAppendingString(self.sessionIMV.frame.size.width.description).stringByAppendingString(heighEqual).stringByAppendingString(self.sessionIMV.frame.size.width.description)
            prefix.appendContentsOf(postfix)
            if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                self.sessionIMV.image = imageRes
            } else {
                Alamofire.request(.GET, prefix)
                    .responseImage { response in
                        if (response.response?.statusCode == 200) {
                            let imageRes = response.result.value! as UIImage
                            self.sessionIMV.image = imageRes
                            NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                        }
                }
            }
        }
    }
    
    func setUserAvatar() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(String(format: "%ld", self.session.userId!))
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    if (response.result.value == nil) {return}
                    let userDetail = response.result.value as! NSDictionary
                    if !(userDetail[kImageUrl] is NSNull) {
                        let imageLink = userDetail[kImageUrl] as! String
                        var prefix = kPMAPI
                        prefix.appendContentsOf(imageLink)
                        let postfix = widthEqual.stringByAppendingString(self.userIMV.frame.size.width.description).stringByAppendingString(heighEqual).stringByAppendingString(self.userIMV.frame.size.width.description)
                        prefix.appendContentsOf(postfix)
                        if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                            let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                            self.userIMV.image = imageRes
                        } else {
                            Alamofire.request(.GET, prefix)
                                .responseImage { response in
                                    if (response.response?.statusCode == 200) {
                                        let imageRes = response.result.value! as UIImage
                                        self.userIMV.image = imageRes
                                        NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                                    }
                            }
                        }
                    }

                } else if response.response?.statusCode == 401 {
                    let alertController = UIAlertController(title: pmmNotice, message: cookieExpiredNotice, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // TODO: LOGOUT
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                }
        }
    }
    
    func setCoachAvatar() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(String(format: "%ld", self.session.coachId!))
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    if (response.result.value == nil) {return}
                    let userDetail = response.result.value as! NSDictionary
                    if !(userDetail[kImageUrl] is NSNull) {
                        let imageLink = userDetail[kImageUrl] as! String
                        var prefix = kPMAPI
                        prefix.appendContentsOf(imageLink)
                        let postfix = widthEqual.stringByAppendingString(self.coachIMV.frame.size.width.description).stringByAppendingString(heighEqual).stringByAppendingString(self.coachIMV.frame.size.width.description)
                        prefix.appendContentsOf(postfix)
                        if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                            let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                            self.coachIMV.image = imageRes
                        } else {
                            Alamofire.request(.GET, prefix)
                                .responseImage { response in
                                    if (response.response?.statusCode == 200) {
                                        let imageRes = response.result.value! as UIImage
                                        self.coachIMV.image = imageRes
                                        NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                                    }
                            }
                        }
                    }
                    
                } else if response.response?.statusCode == 401 {
                    let alertController = UIAlertController(title: pmmNotice, message: cookieExpiredNotice, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // TODO: LOGOUT
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                }
        }
    }
    
    func getRandomColorString() -> String{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed*255), Int(randomGreen*255),Int(randomBlue*255),255)
    }
    
    func backClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
