//
//  SigninViewController.swift
//  pummel
//
//  Created by Bear Daddy on 4/12/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class SigninViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailTF : UITextField!
    @IBOutlet var passwordTF : UITextField!
    @IBOutlet var forgotPasswordBT : UIButton!
    @IBOutlet var signinBT : UIButton!
    @IBOutlet var signinDistantCT: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        self.emailTF.font = .pmmMonReg13()
        self.emailTF.autocorrectionType = UITextAutocorrectionType.No

        self.passwordTF.font = .pmmMonReg13()
        self.emailTF.attributedPlaceholder = NSAttributedString(string:"EMAIL",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        self.passwordTF.attributedPlaceholder = NSAttributedString(string:"PASSWORD",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 119/225, alpha: 1.0)])
        
        self.forgotPasswordBT.titleLabel?.font = .pmmMonReg13()
        self.signinBT.layer.cornerRadius = 2
        self.signinBT.layer.borderWidth = 0.5
        self.signinBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.signinBT.titleLabel?.font = .pmmMonReg13()
        self.updateUI()
        self.emailTF.keyboardAppearance = .Dark
        self.passwordTF.keyboardAppearance = .Dark
    }
    
    func updateUI() {
        let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
        let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
        let SCREEN_MAX_LENGTH    = max(SCREEN_WIDTH, SCREEN_HEIGHT)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
//            switch SCREEN_MAX_LENGTH {
//            case 736.0:
//                self.signinDistantCT.constant = 250.0
//                break
//            
//            case 667.0:
//                self.signinDistantCT.constant = 186.0
//                break
//                
//            case 568.0:
//                self.signinDistantCT.constant = 80.0
//                break
//                
//            default:
//                self.signinDistantCT.constant = 186.0
//                break
//            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
