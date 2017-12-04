//
//  ProductDetailViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/27/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class ProductDetailViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var qualityTextField: UITextField!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var payNowButtonBottomConstraint: NSLayoutConstraint!
    
    var product: ProductModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupLayout()
        self.setupNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)
            ), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fillData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.keyboardWillHide(notification: NSNotification(name: NSNotification.Name.UIKeyboardWillHide, object: nil))
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        self.payNowButtonBottomConstraint.constant = keyboardHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            self.payNowButton.layoutIfNeeded()
        }) { (animated) in
            let contentOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.frame.size.height)
            self.scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.payNowButtonBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.payNowButton.layoutIfNeeded()
        }
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
        self.borderView.layer.cornerRadius = 4
        self.borderView.layer.borderWidth = 1
        self.borderView.layer.borderColor = UIColor.lightGray.cgColor
        self.borderView.layer.masksToBounds = true
        
        self.payNowButton.isHidden = (self.product?.isBought)!
        
        self.qualityTextField.addTarget(self, action: #selector(self.qualityTextFieldDidChange), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func dissmissKeyboard() {
        self.qualityTextField.resignFirstResponder()
    }
    
    func leftBarButtonClicked(_ sender: Any) {
        if (self.product?.isBought == false) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func fillData() {
        if (self.product != nil) {
            self.titleLabel.text = self.product?.title
            self.subTitleLabel.text = self.product?.subTitle
            self.descriptionLabel.text = self.product?.productDescription
            
            self.qualityTextField.text = "1"
            self.updatePrice(quality: 1)
            
            if (self.product?.imageUrl.isEmpty == false) {
                ImageVideoRouter.getImage(imageURLString: (self.product?.imageUrl)!, sizeString: widthHeight320, completed: { (result, error) in
                    if (error == nil) {
                        let imageRes = result as! UIImage
                        self.productImageView.image = imageRes
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
            }
        }
    }

    @IBAction func payNowButtonClicked(_ sender: Any) {
        // TODO: Call pay API and dissmiss view
        self.performSegue(withIdentifier: "goPurchase", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goPurchase") {
            let destination = segue.destination as! InputVisaViewController
            
            let totalMoneyText = self.totalMoneyLabel.text?.removeNonDigits()
            let totalMoney = Int(totalMoneyText!)
            destination.totalMoney = totalMoney!
            destination.product = self.product
        }
    }
}

extension ProductDetailViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return ((self.product?.isBought)! == false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let quality = Int(textField.text!)
        self.updatePrice(quality: quality!)
    }
    
    func qualityTextFieldDidChange() {
        var text = self.qualityTextField.text?.removeNonDigits()
        
        if (text?.isEmpty == true) {
            text = "0"
        } else {
            let maxNumber = 1000
            
            if (Int(text!)! > maxNumber) {
                text = "\(maxNumber)"
            }
            
            let intText = Int(text!)!
            text = "\(intText)" // Remove first 0
        }
        self.qualityTextField.text = text
        
        let quality = Int(text!)
        self.updatePrice(quality: quality!)
    }
    
    func updatePrice(quality: Int) {
        let totalMoney = Double((self.product?.amount)!) * Double(quality)
        
        self.totalMoneyLabel.text = totalMoney.toCurrency(withSymbol: "$")
    }
}
