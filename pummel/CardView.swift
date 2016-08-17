//
//  CardView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/24/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class CardView: UIView {
   
    @IBOutlet var connectV : UIView!
    @IBOutlet var nameLB: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    @IBOutlet weak var avatarIMV : UIImageView!
    @IBOutlet weak var connectBT : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        // Shadow
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSizeMake(0, 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        // Corner Radius
        layer.cornerRadius = 5.0;
    }
}