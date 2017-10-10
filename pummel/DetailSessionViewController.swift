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
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sessionTagColorString = TagRouter.getRandomColorString()
        
        // Back button
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backClicked))
        
        // Right button
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kEdit.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.editClicked))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], for: .normal)
        
        self.initLayout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSession(notification:)), name: NSNotification.Name(rawValue: k_PM_UPDATE_SESSION_NOTIFICATION), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.typeLabel.text = self.session.type?.components(separatedBy: " ").joined(separator: "")
        
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
        
        self.centerV.isHidden = true
        
        var numberInformation = 0;
        if (self.session.longtime != 0) {
            self.timeLB.text = String(format: "%ld minutes", self.session.longtime)
            self.timeV.isHidden = false
            
            numberInformation = numberInformation + 1
        } else {
            self.timeLB.text = "..."
            self.timeV.isHidden = true
        }
        
        if self.session.intensity?.isEmpty == false {
            self.intensityLB.text = self.session.intensity
            self.intensityV.isHidden = false
            
            numberInformation = numberInformation + 1
        } else {
            self.intensityLB.text = "..."
            self.intensityV.isHidden = true
        }
        
        if self.session.distance != nil && self.session.distance != 0 {
            let distanceUnit = self.defaults.object(forKey: kUnit) as? String
            if (distanceUnit == metric) {
                self.distanceLB.text = String(format: "%0.0f kms", self.session.distance!)
                self.distanceV.isHidden = false
            } else {
                self.distanceLB.text = String(format: "%0.1f mi", (Double(self.session.distance!) / 1.61))
                self.distanceV.isHidden = false
            }
            
            numberInformation = numberInformation + 1
        } else {
            self.distanceLB.text = "..."
            self.distanceV.isHidden = true
        }
        
        if (self.session.calorie != 0) {
            self.caloriesLB.text = String(format: "%ld", self.session.calorie)
            self.caloriesV.isHidden = false
            
            numberInformation = numberInformation + 1
        } else {
            self.caloriesLB.text = "..."
            self.caloriesV.isHidden = true
        }
        
        if self.session.datetime?.isEmpty == false {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = kFullDateFormat
            let date = timeFormatter.date(from: self.session.datetime!)
            timeFormatter.dateFormat = "MMM dd, YYYY hh:mm aaa"
            self.dateTF.text = timeFormatter.string(from: date!)
        }
        
        if numberInformation == 1 {
            self.centerV.isHidden = false
            
            if self.timeV.isHidden == false {
                self.centerLB.text = self.timeLB.text
                self.centerIMV.image = UIImage(named: "icon_longtime")
            } else if self.intensityV.isHidden == false {
                self.centerLB.text = self.intensityLB.text
                self.centerIMV.image = UIImage(named: "icon_insensity")
            } else if self.distanceV.isHidden == false {
                self.centerLB.text = self.distanceLB.text
                self.centerIMV.image = UIImage(named: "icon_distance")
            } else if self.caloriesV.isHidden == false {
                self.centerLB.text = self.caloriesLB.text
                self.centerIMV.image = UIImage(named: "icon_calories")
            }
            
            self.timeV.isHidden = true
            self.intensityV.isHidden = true
            self.distanceV.isHidden = true
            self.caloriesV.isHidden = true
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
        
        self.commentIMV.image = self.commentIMV.image?.withRenderingMode(.alwaysTemplate)
        self.commentIMV.tintColor = UIColor.init(hexString: sessionTagColorString)
        
        self.contentTV.font = UIFont.pmmMonReg13()
        self.contentTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
    }
    
    func setSessionImage() {
        if self.session.imageUrl?.isEmpty == false {
            let imageLink = self.session.imageUrl
            
            ImageVideoRouter.getImage(imageURLString: imageLink!, sizeString: widthHeightScreen, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.sessionIMV.image = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
    
    func setUserAvatar() {
        let userID = String(format: "%ld", self.session.userId)
        
        ImageVideoRouter.getUserAvatar(userID: userID, sizeString: widthHeight120) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.userIMV.image = imageRes
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    func setCoachAvatar() {
        let coachID = String(format: "%ld", self.session.coachId)
        
        ImageVideoRouter.getUserAvatar(userID: coachID, sizeString: widthHeight120) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.coachIMV.image = imageRes
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    func backClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func editClicked() {
        self.performSegue(withIdentifier: "editLogSession", sender: self.session)
    }
    
    // MARK: Segue
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editLogSession" {
            let destinationVC = segue.destination as! LogSessionClientViewController
            destinationVC.editSession = sender as! SessionModel
        }
    }

}
