//
//  BookAndBuyCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/24/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

protocol BookAndBuyCellDelegate {
    func bookAndBuyBuyNowButtonClicked(cell: BookAndBuyCell)
}

class BookAndBuyCell: UITableViewCell {
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var buyNowButton: UIButton!
    
    var delegate: BookAndBuyCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.borderView.layer.cornerRadius = 4
        self.borderView.layer.borderWidth = 0.5
        self.borderView.layer.borderColor = UIColor.lightGray.cgColor
        self.borderView.layer.masksToBounds = true
        
        self.buyNowButton.layer.cornerRadius = 4
        self.buyNowButton.layer.masksToBounds = true
        
        self.selectionStyle = .none
    }

    func setupData(product: ProductModel) {
        self.titleLabel.text = product.title
        self.subTitleLabel.text = product.subTitle
        
        self.priceLabel.text = String(format: "$%0.2f", product.amount)
        
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
        
        if (product.isBought == false) {
            self.buyNowButton.setTitle("BUY NOW", for: .normal)
        } else {
            self.buyNowButton.setTitle("VIEW NOW", for: .normal)
        }
    }
    
    @IBAction func buyNowButtonClicked(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.bookAndBuyBuyNowButtonClicked(cell: self)
        }
    }
    
}
