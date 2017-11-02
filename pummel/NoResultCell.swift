//
//  NoResultCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 3/1/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class NoResultCell: UICollectionViewCell {
    var delegate : CardViewCellDelegate? = nil
    
    @IBOutlet weak var noResultLB: UILabel!
    @IBOutlet weak var noResultContentLB: UILabel!
    @IBOutlet weak var refindButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.refindButton.layer.cornerRadius = 5
        
        // add Swipe gesture
        if (self.gestureRecognizers == nil || (self.gestureRecognizers?.count)! < 1) {
            let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightGesture(_:)))
            swipeRightGesture.direction = .right
            self.addGestureRecognizer(swipeRightGesture)
        }
    }
    
    func swipeRightGesture(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.cardViewSwipeRight()
        }
    }
    
    func setupData(isNoResult: Bool) {
        if (isNoResult == true) {
            self.noResultLB.text = "Sorry we couldn't find any experts nearby" // No Result or first show
        } else {
            self.noResultLB.text = "Still didn't find any experts you like nearby" // End Search
        };
    }
    
    @IBAction func refindButtonClicked(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.cardViewRefineButtonClicked()
        }
    }
}
