//
//  CardViewCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 2/22/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

@objc protocol CardViewCellDelegate {
    func cardViewCellTagClicked(cell: CardViewCell)
}

class CardViewCell: UICollectionViewCell, CardViewDelegate {
    @IBOutlet weak var cardView: CardView!
    
    weak var delegate : CardViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardView.delegate = self
        self.cardView.registerTagCell()
    }
    
    func cardViewTagClicked() {
        if  self.delegate != nil {
            self.delegate?.cardViewCellTagClicked(self)
        }
    }
}
