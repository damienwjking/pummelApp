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
//            Alamofire.request(.POST, "http://52.8.5.161/api/request-password-rest", parameters: [kEmail:userEmail!])
//                .responseJSON { response in
//                    print("REQUEST-- \(response.request)")  // original URL request
//                    print("RESPONSE-- \(response.response)") // URL response
//                    print("DATA-- \(response.data)")     // server data
//                    print("RESULT-- \(response.result)")   // result of response serialization
//                    
//                    
//                    
//                    if let JSON = response.result.value {
//                        print("JSON: \(JSON)")
//
//                    }
//                }
//            // Thanks you
//            // hide buttons
//            
//            self.loginButton.setTitle("Return to Sign In", forState: .Normal)
//            self.EmailTextField.hidden = true
//            self.EmailTextField.borderStyle = UITextBorderStyle.None
//            self.EmailTextField.placeholder = "Thank you, an email has been sent to your password."
//            
//            // to do segueReturnForgottenPassword
//
        }
    }
}
