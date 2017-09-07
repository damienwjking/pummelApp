//
//  DetailSessionViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 1/4/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Alamofire

class DetailSessionViewController: BaseViewController {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var sessionIMV: UIImageView!
    @IBOutlet weak var sessionScrollView: UIScrollView!
    
    @IBOutlet weak var userIMV: UIImageView!
    @IBOutlet weak var coachIMV: UIImageView!
    @IBOutlet weak var coachIMVWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coachIMVLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var distanceLB: UILabel!
    @IBOutlet weak var intensityLB: UILabel!
    @IBOutlet weak var caloriesLB: UILabel!
    @IBOutlet weak var centerLB: UILabel!
    
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var commentIMV: UIImageView!
    @IBOutlet weak var contentTV: UITextView!
    
    @IBOutlet weak var centerIMV: UIImageView!
    
    @IBOutlet weak var timeV: UIView!
    @IBOutlet weak var distanceV: UIView!
    @IBOutlet weak var intensityV: UIView!
    @IBOutlet weak var caloriesV: UIView!
    @IBOutlet weak var centerV: UIView!
    
    @IBOutlet weak var tappedV: UIView!
    
    var session = SessionModel()
    var sessionTagColorString = "#FFFFFF"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sessionTagColorString = self.getRandomColorString()
        
        // Back button
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backClicked))
        
        // Right button
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kEdit.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.editClicked))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        self.initLayout()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailSessionViewController.updateSession(_:)), name: k_PM_UPDATE_SESSION_NOTIFICATION, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.typeLabel.text = self.session.type?.componentsSeparatedByString(" ").joinWithSeparator("")
        
        self.title = kSession
        
        self.setUserAvatar()
        
        if self.session.imageUrl?.isEmpty == false {
            self.setSessionImage()
        } else {
            self.sessionIMV.backgroundColor = UIColor.init(hexString: self.sessionTagColorString)
        }
        
        if self.session.coachId == 0 {
            self.setCoachAvatar()
            self.coachIMVWidthConstraint.constant = 40
            self.coachIMVLeadingConstraint.constant = 8;
        } else {
            self.coachIMVWidthConstraint.constant = 0
            self.coachIMVLeadingConstraint.constant = 0;
        }
        
        self.setData()
        
        if (self.session.calorie == 0 &&
            self.session.distance == 0 &&
            self.session.longtime == 0 &&
            self.session.intensity == nil) {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func setData() {
        if self.session.text?.isEmpty == false {
            self.contentTV.text = self.session.text
        } else {
            self.contentTV.text = ""
        }
        
        self.centerV.hidden = true
        
        var numberInformation = 0;
        if (self.session.longtime != 0) {
            self.timeLB.text = String(format: "%ld minutes", self.session.longtime)
            self.timeV.hidden = false
            
            numberInformation = numberInformation + 1
        } else {
            self.timeLB.text = "..."
            self.timeV.hidden = true
        }
        
        if self.session.intensity?.isEmpty == false {
            self.intensityLB.text = self.session.intensity
            self.intensityV.hidden = false
            
            numberInformation = numberInformation + 1
        } else {
            self.intensityLB.text = "..."
            self.intensityV.hidden = true
        }
        
        if self.session.distance != nil && self.session.distance != 0 {
            let distanceUnit = self.defaults.objectForKey(kUnit) as? String
            if (distanceUnit == metric) {
                self.distanceLB.text = String(format: "%0.0f kms", self.session.distance!)
                self.distanceV.hidden = false
            } else {
                self.distanceLB.text = String(format: "%0.1f mi", (Double(self.session.distance!) / 1.61))
                self.distanceV.hidden = false
            }
            
            numberInformation = numberInformation + 1
        } else {
            self.distanceLB.text = "..."
            self.distanceV.hidden = true
        }
        
        if (self.session.calorie != 0) {
            self.caloriesLB.text = String(format: "%ld", self.session.calorie)
            self.caloriesV.hidden = false
            
            numberInformation = numberInformation + 1
        } else {
            self.caloriesLB.text = "..."
            self.caloriesV.hidden = true
        }
        
        if self.session.datetime?.isEmpty == false {
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = kFullDateFormat
            let date = timeFormatter.dateFromString(self.session.datetime!)
            timeFormatter.dateFormat = "MMM dd, YYYY hh:mm aaa"
            self.dateTF.text = timeFormatter.stringFromDate(date!)
        }
        
        if numberInformation == 1 {
            self.centerV.hidden = false
            
            if self.timeV.hidden == false {
                self.centerLB.text = self.timeLB.text
                self.centerIMV.image = UIImage(named: "icon_longtime")
            } else if self.intensityV.hidden == false {
                self.centerLB.text = self.intensityLB.text
                self.centerIMV.image = UIImage(named: "icon_insensity")
            } else if self.distanceV.hidden == false {
                self.centerLB.text = self.distanceLB.text
                self.centerIMV.image = UIImage(named: "icon_distance")
            } else if self.caloriesV.hidden == false {
                self.centerLB.text = self.caloriesLB.text
                self.centerIMV.image = UIImage(named: "icon_calories")
            }
            
            self.timeV.hidden = true
            self.intensityV.hidden = true
            self.distanceV.hidden = true
            self.caloriesV.hidden = true
        }
    }
    
    func updateSession(notification: NSNotification) {
        if notification.object != nil {
            let session = notification.object as! SessionModel
            self.session = session
            
            setData()
        }
    }
    
    func initLayout() {
        self.typeLabel.font = .pmmMonReg20()
        self.timeLB.font = .pmmMonLight13()
        self.distanceLB.font = .pmmMonLight13()
        self.intensityLB.font = .pmmMonLight13()
        self.caloriesLB.font = .pmmMonLight13()
        self.centerLB.font = .pmmMonLight13()
        
        self.dateTF.font = UIFont.pmmMonReg13()
        
        self.userIMV.layer.cornerRadius = 20
        self.userIMV.clipsToBounds = true
        
        self.coachIMV.layer.cornerRadius = 20
        self.coachIMV.clipsToBounds = true
        
        self.commentIMV.image = self.commentIMV.image?.imageWithRenderingMode(.AlwaysTemplate)
        self.commentIMV.tintColor = UIColor.init(hexString: sessionTagColorString)
        
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
        let userID = String(format: "%ld", self.session.userId)
        
        ImageRouter.getUserAvatar(userID: userID, sizeString: widthHeight120) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.userIMV.image = imageRes
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
    }
    
    func setCoachAvatar() {
        let coachID = String(format: "%ld", self.session.coachId)
        
        ImageRouter.getUserAvatar(userID: coachID, sizeString: widthHeight120) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.coachIMV.image = imageRes
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
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
    
    func editClicked() {
        self.performSegueWithIdentifier("editLogSession", sender: self.session)
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editLogSession" {
            let destinationVC = segue.destinationViewController as! LogSessionClientViewController
            destinationVC.editSession = sender as! SessionModel
        }
    }

}
