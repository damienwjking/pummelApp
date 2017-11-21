//
//  InputVisaViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 11/20/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Stripe

class InputVisaViewController: UIViewController {
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expireTimeTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var moneyTextField: UITextField!
    
    var totalMoney: Int = 0
    var product: ProductModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupLayout()
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateLayout()
    }
    
    func setupNavigationBar() {
        // Titlte
        self.navigationItem.title = kNavBookBuy
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.isTranslucent = false;
        
        // Left button
        let closeImage = UIImage(named: "close")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(self.leftBarButtonClicked(_:)))
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // Right button
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func setupLayout() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard(_:)))
        
        self.view.addGestureRecognizer(tapGesture)
        
        self.cardNumberTextField.addTarget(self.cardNumberTextField, action: #selector(self.cardNumberTextField.reformatAsCardNumber), for: UIControlEvents.editingChanged)
        
        self.expireTimeTextField.addTarget(self.expireTimeTextField, action: #selector(self.expireTimeTextField.reformatAsExpireMonth), for: UIControlEvents.editingChanged)
        
        self.cvcTextField.addTarget(self.cvcTextField, action: #selector(self.cvcTextField.reformatAsCVC), for: UIControlEvents.editingChanged)
    }
    
    func updateLayout() {
        self.moneyTextField.text = self.totalMoney.toCurrency(withSymbol: "$")
    }

    func leftBarButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func dissmissKeyboard(_ sender: Any) {
        self.cardNumberTextField.resignFirstResponder()
        self.expireTimeTextField.resignFirstResponder()
        self.cvcTextField.resignFirstResponder()
        self.moneyTextField.resignFirstResponder()
    }
    
    @IBAction func payNowButtonClicked(_ sender: Any) {
        if (self.product != nil) {
            if (self.validateCardNumber() == true &&
                self.validateExpireTime() == true &&
                self.validateCVC() == true) {
                // Call Stripe API to get token
                let cardParam = STPCardParams()
                cardParam.number = self.cardNumberTextField.text?.removeNonDigits()
                cardParam.cvc = self.cvcTextField.text?.removeNonDigits()
                
                let expirationDate = self.expireTimeTextField.text?.components(separatedBy: "/")
                if (expirationDate != nil && expirationDate?.count == 2) {
                    cardParam.expMonth = UInt(expirationDate![0])!
                    cardParam.expYear = UInt(expirationDate![1])!
                }
                
                self.view.makeToastActivity()
                
                STPAPIClient.shared().publishableKey = "pk_test_6UV44nTQUrJ6911Jy27aFKRL"
                STPAPIClient.shared().createToken(withCard: cardParam) { (token, error) in
                    self.view.hideToastActivity()
                    
                    if (error == nil) {
                        // Sent token to server
                        let tokenString = token?.description
                        ProductRouter.buyProduct(productID: (self.product?.id)!, amount: self.totalMoney, token: tokenString!, completed: { (result, error) in
                            if (error == nil) {
                                
                            } else {
                                print("Request failed with error: \(String(describing: error))")
                            }
                        }).fetchdata()
                        
                    } else {
                        print(error!)
                        PMHelper.showDoAgainAlert()
                    }
                }
            } else {
                PMHelper.showNoticeAlert(message: "Please fill all infomation")
            }
        }
    }
    
}

extension InputVisaViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.cardNumberTextField) {
            
        } else if (textField == self.expireTimeTextField) {
           
        } else if (textField == self.cvcTextField) {
            
        }
        
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == self.cardNumberTextField) {
            let _ = self.validateCardNumber()
        } else if (textField == self.expireTimeTextField) {
            let _ = self.validateExpireTime()
        } else if (textField == self.cvcTextField) {
            let _ = self.validateCVC()
        }
    }
    
    func validateCardNumber() -> Bool {
        let cardNumberText = self.cardNumberTextField.text?.removeNonDigits() as! String
        
        if (cardNumberText.count == 0) {
            return false
        } else {
            return true
        }
    }
    
    func validateExpireTime() -> Bool {
        let expireTimeText = self.expireTimeTextField.text?.removeNonDigits()
        
        if (expireTimeText!.count == 4) {
            self.expireTimeTextField.textColor = UIColor.black
            
            return true
        } else {
            self.expireTimeTextField.textColor = UIColor.pmmRougeColor()
            
            return false
        }
    }
    
    func validateCVC() -> Bool {
        let cvcText = self.cvcTextField.text?.removeNonDigits()
        
        if (cvcText!.count == 3) {
            self.cvcTextField.textColor = UIColor.black
            
            return true
        } else {
            self.cvcTextField.textColor = UIColor.pmmRougeColor()
            
            return false
        }
    }

    
}
