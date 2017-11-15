//
//  ProductPurchasedCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/31/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class ProductPurchasedCell: UICollectionViewCell {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.borderView.layer.cornerRadius = 4
        self.borderView.layer.shadowColor = UIColor.lightGray.cgColor
        self.borderView.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.borderView.layer.shadowRadius = 3
        self.borderView.layer.shadowOpacity = 0.3
    }

    func setupData(product: ProductModel) {
        self.productNameLabel.text = product.title
        self.productDescriptionLabel.text = product.subTitle
        
        if (product.imageUrl.isEmpty == false) {
            ImageVideoRouter.getImage(imageURLString: product.imageUrl, sizeString: widthHeight200, completed: { (result, error) in
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
