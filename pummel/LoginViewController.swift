//
//  LoginViewController.swift
//  pummel
//
//  Created by Damien King on 29/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    let loginButton:UIButton = UIButton(frame: CGRectMake(10, 600, 380, 50))
    let EmailTextField = UITextField(frame: CGRectMake(10, 100, 250, 40))
    let PasswordTextField = UITextField(frame: CGRectMake(10, 100, 250, 40))
    let forgottenPasswordButton:UIButton = UIButton(frame: CGRectMake(10, 640, 200, 50))

    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBarHidden = true
        
        // background image
        
       // let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
       // backgroundImage.image = UIImage(named: "getStarted")
       // self.view.insertSubview(backgroundImage, atIndex:0)
        
        // Add submit button
        let buttoncolour = UIColor(red:0.75, green:0.84, blue:0.83, alpha:1.0)
        
        loginButton.backgroundColor = buttoncolour
        loginButton.setTitle("Sign In", forState: UIControlState.Normal)
        loginButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        loginButton.tag = 01;
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
        var emailLabel : UILabel!
        emailLabel = UILabel(frame: CGRectMake(10, 110, 250, 40))
        emailLabel.text = "Enter email"
        emailLabel.center = CGPointMake(160, 260)
        emailLabel.textColor = UIColor.whiteColor()
        view.addSubview(emailLabel)

        PasswordTextField.placeholder = "Password"
        PasswordTextField.secureTextEntry = true
        PasswordTextField.font = UIFont.systemFontOfSize(18)
        PasswordTextField.borderStyle = UITextBorderStyle.Line
        PasswordTextField.backgroundColor = UIColor.whiteColor()
        
        EmailTextField.keyboardType = UIKeyboardType.Default
        PasswordTextField.returnKeyType = UIReturnKeyType.Done
        PasswordTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        PasswordTextField.center = CGPointMake(160, 384)
        self.view.addSubview(PasswordTextField)
        
        //label
        var passwordLabel : UILabel!
        passwordLabel = UILabel(frame: CGRectMake(10, 100, 250, 40))
        passwordLabel.text = "Enter password"
        passwordLabel.textColor = UIColor.whiteColor()
        passwordLabel.center = CGPointMake(160, 354)
        view.addSubview(passwordLabel)

        // Add forgotten password button
        
        forgottenPasswordButton.setTitle("Forgotten Password", forState: UIControlState.Normal)
        forgottenPasswordButton.addTarget(self, action: "forgottenPasswordButton:", forControlEvents: UIControlEvents.TouchUpInside)
        forgottenPasswordButton.tag = 02;
        self.view.addSubview(forgottenPasswordButton)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    // forgotten Password
    
    func forgottenPasswordButton(sender:UIButton!) {
        let btnsendtag:UIButton = sender
        print("forgoten password clicked")
        if btnsendtag.tag == 02 {
        
            performSegueWithIdentifier("segueForgottenPassword", sender: nil)
        } else {
            print("forgoten password clicked")
        }
        
    }
    func buttonAction(sender:UIButton!) {
        
            let btnsendtag:UIButton = sender
        
            if btnsendtag.tag == 01 {
        
                print("button 01 pushed")
                
                let userEmail = EmailTextField.text
                let userPassword = PasswordTextField.text
                print("Email and password \(userEmail) and \(userPassword)")
                
                Alamofire.request(.POST, "http://52.8.5.161/api/users/login", parameters: ["email":userEmail!, "password":userPassword!])
                        .responseJSON { response in
                            print("REQUEST-- \(response.request)")  // original URL request
                            print("RESPONSE-- \(response.response)") // URL response
                            print("DATA-- \(response.data)")     // server data
                            print("RESULT-- \(response.result)")   // result of response serialization
                            
                            if let JSON = response.result.value {
                                print("JSON: \(JSON)")
                                
                            } else {
                                    let alertController = UIAlertController(title: "Sign In Issues", message: "Please check email and password", preferredStyle: .Alert)
                            
                            
                                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
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