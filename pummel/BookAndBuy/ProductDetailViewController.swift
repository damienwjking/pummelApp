//
//  ProductDetailViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/27/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class ProductDetailViewController: BaseViewController {
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var qualityTextField: UITextField!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    
    @IBOutlet weak var payNowButton: UIButton!
    
    var product: ProductModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupLayout()
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fillData()
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
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProductDetailViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return ((self.product?.isBought)! == false)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let canInput = string.isNumber()
        
        if (canInput == true) {
            let oldString = textField.text! as NSString
            let qtyString = oldString.replacingCharacters(in: range, with: string)
            
            let qty = Double(qtyString)
            if (qty != nil) {
                var quality = Int(qty!)
                
                if (quality >= 1000) {
                    quality = 999
                }
                
                self.updatePrice(quality: quality)
            } else {
                self.updatePrice(quality: 0)
            }
        }
        
        return canInput
    }
    
    func updatePrice(quality: Int) {
        let numberFormat = NumberFormatter()
        numberFormat.currencySymbol = "$"
        numberFormat.numberStyle = .currency
        numberFormat.formatWidth = 3
        numberFormat.generatesDecimalNumbers = true
        numberFormat.alwaysShowsDecimalSeparator = false
        
        let totalMoney = Double((self.product?.amount)!) * Double(quality)
        let moneyString = numberFormat.string(from: NSNumber(value: totalMoney))
        
        self.totalMoneyLabel.text = moneyString
    }
}
