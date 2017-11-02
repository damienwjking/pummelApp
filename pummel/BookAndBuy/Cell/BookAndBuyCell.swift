//
//  BookAndBuyCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 10/24/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class BookAndBuyCell: UITableViewCell {
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var buyNowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.borderView.layer.cornerRadius = 4
        self.borderView.layer.borderWidth = 1
        self.borderView.layer.borderColor = UIColor.lightGray.cgColor
        self.borderView.layer.masksToBounds = true
        
        self.buyNowButton.layer.cornerRadius = 4
        self.buyNowButton.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupData(product: ProductModel) {
        
    }
    
}
