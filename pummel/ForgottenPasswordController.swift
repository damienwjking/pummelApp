//
//  ForgottenPasswordController.swift
//  pummel
//
//  Created by Damien King on 2/03/2016.
//  Copyright © 2016 pummel. All rights reserved.
//

//
//  RegisterViewController.swift
//  pummel
//
//  Created by Damien King on 29/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class ForgottenPasswordController: UIViewController {
    
    @IBOutlet var doneBT:UIButton!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var titleLB: UILabel!
    @IBOutlet var doneBTDT: NSLayoutConstraint!
    @IBOutlet var dimView: UIView!
    @IBOutlet var alertView: UIView!
    @IBOutlet var alertTitleLB: UILabel!
    @IBOutlet var alertMessageLB: UILabel!
    @IBOutlet var sweetBT: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTF.font = .pmmMonReg10()
        self.titleLB.font = .pmmMonReg13()
        self.emailTF.attributedPlaceholder = NSAttributedString(string:"EMAIL",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        
        self.doneBT.layer.cornerRadius = 2
        self.doneBT.layer.borderWidth = 0.5
        self.doneBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.doneBT.titleLabel?.font = .pmmMonReg13()
        self.emailTF.keyboardAppearance = .Dark
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginAndRegisterViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginAndRegisterViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackWithSender() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.doneBTDT.constant = keyboardSize.height + 15
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.doneBTDT.constant = 15
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func buttonSweetWithSender(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func buttonActionWithSender() {
        
        
        let userEmail = emailTF.text
        
        // check if field empty
        
        if(userEmail!.isEmpty) {
            
            self.emailTF.highlighted = true
            
            let alertController = UIAlertController(title: "Reset Password", message: "Please enter a valid email address", preferredStyle: .Alert)
            
            
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            
        } else {
            Alamofire.request(.POST, kPMAPI_FORGOT, parameters: [kEmail:userEmail!])
                .responseJSON { response in
                    if (response.response?.statusCode == 200) {
                        self.alertTitleLB.text = String.init(format: "Check your email")
                        self.alertMessageLB.text = String.init(format: "We sent an email to %@. Tap the link in the email to reset your password.", userEmail!)
                        self.sweetBT.setTitle(kSweetThanks, forState: .Normal)
                        
                        UIView.animateWithDuration(0.3, animations: { 
                            self.dimView.alpha = 0.5;
                            self.alertView.alpha = 1;
                            
                            self.dimView.userInteractionEnabled = true;
                        })
                    } else {
                        let alertController = UIAlertController(title: "Reset Password", message: "Please enter a valid email address", preferredStyle: .Alert)
                        
                        
                        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                    }
            }
        }
    }
}
