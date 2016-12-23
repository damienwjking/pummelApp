//
//  BookSessionToUserViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class BookSessionToUserViewController: UIViewController {
    
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var contentTF: UITextField!
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var avatarIMV: UIImageView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var coachDetail: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.backgroundColor = UIColor.whiteColor()
        dateTF.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(BookSessionToUserViewController.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.tapView.hidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapView))
        self.tapView.addGestureRecognizer(tap)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:kCancle.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kNext.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.next))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.avatarIMV.layer.cornerRadius = self.avatarIMV.frame.size.width/2
        self.avatarIMV.clipsToBounds = true
        self.getDetail()
        
        self.contentTF.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
    }
    
    func didTapView() {
        self.contentTF.resignFirstResponder()
        self.dateTF.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kBookSession
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = " "
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "MM/dd/YYYY"
        dateTF.text = timeFormatter.stringFromDate(sender.date)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tapView.hidden = false
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tapView.hidden = true
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func next() {
        self.performSegueWithIdentifier("gotoShare", sender: nil)
    }
    
    func getDetail() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    if (response.result.value == nil) {return}
                    self.coachDetail = response.result.value as! NSDictionary
                    self.setAvatar()
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
    
    func setAvatar() {
        if !(coachDetail[kImageUrl] is NSNull) {
            let imageLink = coachDetail[kImageUrl] as! String
            var prefix = kPMAPI
            prefix.appendContentsOf(imageLink)
            let postfix = widthEqual.stringByAppendingString(avatarIMV.frame.size.width.description).stringByAppendingString(heighEqual).stringByAppendingString(avatarIMV.frame.size.width.description)
            prefix.appendContentsOf(postfix)
            if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                self.avatarIMV.image = imageRes
            } else {
                Alamofire.request(.GET, prefix)
                    .responseImage { response in
                        if (response.response?.statusCode == 200) {
                            let imageRes = response.result.value! as UIImage
                            self.avatarIMV.image = imageRes
                            NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                        }
                }
            }
        }
    }
}
