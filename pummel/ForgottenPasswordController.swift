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
        
        self.emailTF.font = .pmmMonReg13()
        self.titleLB.font = .pmmMonReg13()
        self.emailTF.attributedPlaceholder = NSAttributedString(string:"EMAIL",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        
        self.doneBT.layer.cornerRadius = 2
        self.doneBT.layer.borderWidth = 0.5
        self.doneBT.layer.borderColor = UIColor.white.cgColor
        self.doneBT.titleLabel?.font = .pmmMonReg13()
        self.emailTF.keyboardAppearance = .dark
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackWithSender() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            self.doneBTDT.constant = keyboardSize.height + 15
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            self.doneBTDT.constant = 15
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func buttonSweetWithSender(sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func buttonActionWithSender() {
        let userEmail = emailTF.text
        
        // check if field empty
        
        if(userEmail!.isEmpty) {
            self.emailTF.isHighlighted = true
            
            PMHelper.showAlert(title: kResetPassword, message: kInvalidEmail)
        } else {
            self.emailTF.resignFirstResponder()
            self.view.makeToastActivity(message: "Loading")
            
            UserRouter.forgotPassword(email: userEmail!, completed: { (result, error) in
                self.view.hideToastActivity()
                
                let isDoSuccess = result as! Bool
                if (isDoSuccess == true) {
                    self.alertTitleLB.text = "Check your email"
                    self.alertMessageLB.text = String.init(format: "We sent an email to %@. Tap the link in the email to reset your password.", userEmail!)
                    
                    self.sweetBT.setTitle(kSweetThanks, for: .normal)
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.dimView.alpha = 0.5;
                        self.alertView.alpha = 1;
                        
                        self.dimView.isUserInteractionEnabled = true;
                    })
                } else {
                    PMHelper.showAlert(title: kResetPassword, message: kInvalidEmail)
                }
            }).fetchdata()
        }
    }
}
