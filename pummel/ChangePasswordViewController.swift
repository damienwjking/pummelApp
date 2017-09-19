//
//  ChangePasswordViewController.swift
//  pummel
//
//  Created by Bear Daddy on 2/1/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ChangePasswordViewController : BaseViewController {
   
    @IBOutlet weak var curPassTF: UITextField!
    @IBOutlet weak var newPassTF: UITextField!
    @IBOutlet weak var reTypePassTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kChangePassword
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.translucent = false;
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"DONE", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChangePasswordViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChangePasswordViewController.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
    }
    
    func done() {
        // Check new password & retype new password are the same
        if self.newPassTF.text?.characters.count < 8 {
            let alertController = UIAlertController(title: pmmNotice, message: passWordMinCharacter, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            return
        }
        
        if self.newPassTF.text == self.reTypePassTF.text {
            self.view.makeToastActivity()
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(PMHeler.getCurrentID())
            prefix.appendContentsOf(kPMAPI_CHANGEPASS)
            
            let param = [kPassword:self.curPassTF.text!,
                         kPasswordNew: self.newPassTF.text!]
            
            Alamofire.request(.PUT, prefix, parameters: param)
                .responseJSON { response in
                    self.view.hideToastActivity()
                    print(response.response?.statusCode)
                    if response.response?.statusCode == 200 {
                        self.navigationController?.popViewControllerAnimated(true)
                    } else if response.response?.statusCode == 401 {
                        let alertController = UIAlertController(title: pmmNotice, message: curPassWrong, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                    } else {
                        self.view.hideToastActivity()
                        let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                    }
            }
        } else {
            let alertController = UIAlertController(title: pmmNotice, message: passWordNotMatch, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
