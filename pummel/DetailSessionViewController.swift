//
//  DetailSessionViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 1/4/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class DetailSessionViewController: UIViewController {

    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var distanceLB: UILabel!
    @IBOutlet weak var intensityLB: UILabel!
    @IBOutlet weak var caloriesLB: UILabel!
    
    @IBOutlet weak var avatarIMV: UIImageView!
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
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        self.session.calorie = 100
        
        
        self.title = self.session.type?.componentsSeparatedByString(" ").joinWithSeparator("")
        
        if self.session.datetime?.isEmpty == false {
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = kFullDateFormat
            let date = timeFormatter.dateFromString(self.session.datetime!)
            timeFormatter.dateFormat = "MMM dd, YYYY hh:mm aaa"
            self.timeLB.text = timeFormatter.stringFromDate(date!)
            
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
        
        if self.session.distance != 0 {
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
        
        if self.session.calorie != 0 {
            self.caloriesLB.text = String(format: "%ld", self.session.calorie!)
            self.caloriesV.hidden = false
            self.caloriesVHeightConstraint.constant = 50
        } else {
            self.caloriesV.hidden = true
            self.caloriesVHeightConstraint.constant = 0
        }
    }
    
    func initLayout() {
        self.timeLB.font = .pmmMonLight13()
        self.distanceLB.font = .pmmMonLight13()
        self.intensityLB.font = .pmmMonLight13()
        self.caloriesLB.font = .pmmMonLight13()
        
        self.dateTF.font = UIFont.pmmMonReg13()
        
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        
        self.contentTV.font = UIFont.pmmMonReg13()
        self.contentTV.keyboardAppearance = .Dark
        self.contentTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
    }
    
    func backClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
