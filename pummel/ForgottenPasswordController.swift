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
    
    let loginButton:UIButton = UIButton(frame: CGRectMake(10, 600, 380, 50))
    let EmailTextField = UITextField(frame: CGRectMake(10, 100, 250, 40))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // background image
        
        // let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        // backgroundImage.image = UIImage(named: "getStarted")
        // self.view.insertSubview(backgroundImage, atIndex:0)
        
        self.view.backgroundColor = UIColor.grayColor()
        
        // Add submit button
        let buttoncolour = UIColor(red:0.75, green:0.84, blue:0.83, alpha:1.0)
        
        loginButton.backgroundColor = buttoncolour
        loginButton.setTitle("Reset Password", forState: UIControlState.Normal)
        loginButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginButton)
        
        
        // Email and password fields
        EmailTextField.placeholder = "Email Address"
        EmailTextField.backgroundColor = UIColor.whiteColor()
        EmailTextField.font = UIFont.systemFontOfSize(18)
        EmailTextField.borderStyle = UITextBorderStyle.Line
        EmailTextField.keyboardType = UIKeyboardType.Default
        EmailTextField.returnKeyType = UIReturnKeyType.Done
        EmailTextField.center = CGPointMake(160, 300)
        EmailTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        
        self.view.addSubview(EmailTextField)

        //label
        var passwordLabel : UILabel!
        passwordLabel = UILabel(frame: CGRectMake(10, 100, 250, 40))
        passwordLabel.text = "An email will be sent to you to reset your password"
        passwordLabel.textColor = UIColor.whiteColor()
        passwordLabel.center = CGPointMake(160, 354)
        view.addSubview(passwordLabel)

        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func buttonAction(sender:UIButton!) {
        
        
        let userEmail = EmailTextField.text
        
        // check if field empty
        
        if(userEmail!.isEmpty) {
        
                self.EmailTextField.highlighted = true
                
                let alertController = UIAlertController(title: "Reset Password", message: "Please enter a valid email address", preferredStyle: .Alert)
                
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true) {
                    // ...
                }

        } else {
            Alamofire.request(.POST, "http://52.8.5.161/api/request-password-rest", parameters: ["email":userEmail!])
                .responseJSON { response in
                    print("REQUEST-- \(response.request)")  // original URL request
                    print("RESPONSE-- \(response.response)") // URL response
                    print("DATA-- \(response.data)")     // server data
                    print("RESULT-- \(response.result)")   // result of response serialization
                    
                    
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")

                    }
                }
            // Thanks you
            // hide buttons
            
            self.loginButton.setTitle("Return to Sign In", forState: UIControlState.Normal)
            self.EmailTextField.hidden = true
            self.EmailTextField.borderStyle = UITextBorderStyle.None
            self.EmailTextField.placeholder = "Thank you, an email has been sent to your password."
            
            // to do segueReturnForgottenPassword
            
            
        }
    }
}