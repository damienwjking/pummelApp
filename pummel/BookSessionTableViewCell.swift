//
//  BookSessionTableViewCell.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/21/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class BookSessionTableViewCell: UITableViewCell {

    @IBOutlet weak var statusIMV: UIImageView!
    @IBOutlet weak var bookTitleLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusIMV.layer.masksToBounds = true
        self.statusIMV.layer.cornerRadius = 20
    }
 
    func setupData(tag: TagModel) {
        self.bookTitleLB.text = tag.tagTitle?.uppercased()
        self.statusIMV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
    }
}
