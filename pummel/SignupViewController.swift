//
//  SignupViewController.swift
//  pummel
//
//  Created by Bear Daddy on 4/12/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nameTF : UITextField!
    @IBOutlet var emailTF : UITextField!
    @IBOutlet var passwordTF : UITextField!
    @IBOutlet var dobTF : UITextField!
    @IBOutlet var genderTF : UITextField!
    @IBOutlet var signupBT : UIButton!
    @IBOutlet var signinDistantCT: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.emailTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.passwordTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.dobTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.genderTF.font = UIFont(name: "Montserrat-Regular", size: 13)
       
        self.nameTF.attributedPlaceholder = NSAttributedString(string:"NAME",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.emailTF.attributedPlaceholder = NSAttributedString(string:"EMAIL",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.passwordTF.attributedPlaceholder = NSAttributedString(string:"PASSWORD",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.dobTF.attributedPlaceholder = NSAttributedString(string:"D.O.B.",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.genderTF.attributedPlaceholder = NSAttributedString(string:"GENDER",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        
        self.signupBT.layer.cornerRadius = 2
        self.signupBT.layer.borderWidth = 0.5
        self.signupBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.signupBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 13)
        
        self.updateUI()
    }
    
    func updateUI() {
        let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
        let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
        let SCREEN_MAX_LENGTH    = max(SCREEN_WIDTH, SCREEN_HEIGHT)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 736.0) {
            self.signinDistantCT.constant = 142
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (textField.isEqual(self.emailTF) == true) {
            // TODO: Show left icon
            if (self.isValidEmail(self.emailTF.text!) == false) {
                self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
            } else {
                self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
            }
        }
        if (textField.isEqual(self.passwordTF) == true) {
            // TODO: Show left icon
            if (self.passwordTF.text?.characters.count <= 8) {
                self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
            } else {
                self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
            }
        }

        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}
