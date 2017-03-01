//
//  NoResultCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 3/1/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class NoResultCell: UICollectionViewCell {
    
    @IBOutlet weak var noResultLB: UILabel!
    @IBOutlet weak var noResultContentLB: UILabel!
    @IBOutlet weak var refineSearchBT: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.noResultLB.font = .pmmPlayFairReg18()
        self.noResultContentLB.font = .pmmMonLight13()
        self.refineSearchBT.titleLabel!.font = .pmmMonReg12()
    }
}
