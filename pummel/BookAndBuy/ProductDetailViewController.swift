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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fillData()
    }
    
    func setupLayout() {
        self.borderView.layer.cornerRadius = 4
        self.borderView.layer.borderWidth = 1
        self.borderView.layer.borderColor = UIColor.lightGray.cgColor
        self.borderView.layer.masksToBounds = true
    }
    
    func fillData() {
        if (self.product != nil) {
            self.titleLabel.text = self.product?.title
            self.subTitleLabel.text = self.product?.subTitle
            self.descriptionLabel.text = self.product?.productDescription
            
//            self.totalMoneyLabel
            
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.isNumber()
    }
}
