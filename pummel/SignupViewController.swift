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
    @IBOutlet var continuingLB : UILabel!
    @IBOutlet var signinDistantCT: NSLayoutConstraint!
    @IBOutlet var passwordAttentionIM: UIImageView!
    @IBOutlet var emailAttentionIM: UIImageView!
    @IBOutlet var dobAttentionIM: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.nameTF.autocorrectionType = UITextAutocorrectionType.No
        self.emailTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.emailTF.autocorrectionType = UITextAutocorrectionType.No
        self.passwordTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.dobTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.genderTF.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.continuingLB.font = UIFont(name: "Montserrat-Regular", size: 10)
       
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
        
        self.passwordAttentionIM.hidden = true
        self.emailAttentionIM.hidden = true
        self.dobAttentionIM.hidden = true

        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(SignupViewController.dismissKeyboard)))
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.updateUI()
        
        self.nameTF.keyboardAppearance = .Dark
        self.passwordTF.keyboardAppearance = .Dark
        self.emailTF.keyboardAppearance = .Dark
        
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
        if textField.isEqual(self.emailTF) == true {
            if (self.isValidEmail(self.emailTF.text!) == false) {
                self.emailAttentionIM.hidden = false
                self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
            } else {
                self.emailAttentionIM.hidden = true
                self.emailTF.attributedText = NSAttributedString(string:self.emailTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
            }
        }
        if textField.isEqual(self.passwordTF) == true {
            // TODO: Show left icon
            if (self.passwordTF.text?.characters.count < 8) {
                self.passwordAttentionIM.hidden = false
                self.passwordTF.attributedText = NSAttributedString(string:self.passwordTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
                let alertController = UIAlertController(title: "Password is weak", message: " Please try a combination of numbers and letters", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
                
            } else {
                self.passwordAttentionIM.hidden = true
                self.passwordTF.attributedText = NSAttributedString(string:self.passwordTF.text!,
                    attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.isEqual(self.genderTF) == true {
            return false
        } else {
            return true
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func textFieldEditing(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.backgroundColor = UIColor.blackColor()
        datePickerView.setValue(UIColor.whiteColor(), forKey: "textColor")
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action:#selector(SignupViewController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        self.dobTF.text = dateFormatter.stringFromDate(sender.date)
        let dateDOB = dateFormatter.dateFromString(self.dobTF.text!)
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        let componentsDOB = calendar.components([.Day , .Month , .Year], fromDate:dateDOB!)
        let year =  components.year
        let yearDOB = componentsDOB.year
        
        if (12 < (year - yearDOB)) && ((year - yearDOB) < 1001)  {
            self.dobAttentionIM.hidden = true
            self.dobTF.attributedText = NSAttributedString(string:self.dobTF.text!,
                attributes:[NSForegroundColorAttributeName: UIColor(white: 225, alpha: 1.0)])
        } else {
            self.dobAttentionIM.hidden = false
            self.dobTF.attributedText = NSAttributedString(string:self.dobTF.text!,
                attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
        }
    }
    
    @IBAction func showPopupToSelectGender(sender:UIDatePicker) {
        self.dobTF.resignFirstResponder()
        self.emailTF.resignFirstResponder()
        self.passwordTF.resignFirstResponder()
        self.nameTF.resignFirstResponder()
        let selectMale = { (action:UIAlertAction!) -> Void in
            self.genderTF.text = "MALE"
        }
        let selectFemale = { (action:UIAlertAction!) -> Void in
            self.genderTF.text = "FEMALE"
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "MALE", style: UIAlertActionStyle.Default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: "FEMALE", style: UIAlertActionStyle.Default, handler: selectFemale))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func dismissKeyboard() {
        self.dobTF.resignFirstResponder()
    }
}
