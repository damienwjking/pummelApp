//
//  ProductDetailViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/27/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var qualityTextField: UITextField!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    
    @IBOutlet weak var payNowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupLayout()
    }
    
    func setupLayout() {
        self.borderView.layer.cornerRadius = 4
        self.borderView.layer.borderWidth = 1
        self.borderView.layer.borderColor = UIColor.lightGray.cgColor
        self.borderView.layer.masksToBounds = true
    }

    @IBAction func payNowButtonClicked(_ sender: Any) {
        // TODO: Call pay API and dissmiss view
        self.dismiss(animated: true, completion: nil)
    }
}
