//
//  ChangePasswordViewController.swift
//  pummel
//
//  Created by Bear Daddy on 2/1/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordViewController : BaseViewController {
   
    @IBOutlet weak var curPassTF: UITextField!
    @IBOutlet weak var newPassTF: UITextField!
    @IBOutlet weak var reTypePassTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kChangePassword
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.isTranslucent = false;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: kDone.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChangePasswordViewController.done))
        self.navigationItem.rightBarButtonItem?.setAttributeForAllStage()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kCancle.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChangePasswordViewController.cancel))
        self.navigationItem.leftBarButtonItem?.setAttributeForAllStage()
    }
    
    func done() {
        // Check new password & retype new password are the same
        if (self.newPassTF.text?.characters.count)! < 8 {
            PMHelper.showNoticeAlert(message: passWordMinCharacter)
        } else {
            if (self.newPassTF.text == self.reTypePassTF.text) {
                self.view.makeToastActivity()
                
                let currentPassword = self.curPassTF.text
                let newPassword = self.newPassTF.text
                UserRouter.changePassword(currentPassword: currentPassword!, newPassword: newPassword!, completed: { (result, error) in
                    self.view.hideToastActivity()
                    
                    if (error == nil) {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                        
                        if (error?.code == 401) {
                            PMHelper.showNoticeAlert(message: curPassWrong)
                        } else {
                            PMHelper.showNoticeAlert(message: pleaseCheckYourInformationAgain)
                        }
                    }
                }).fetchdata()
            } else {
                PMHelper.showNoticeAlert(message: passWordNotMatch)
            }
        }
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
}
