//
//  FirstThirdPartTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class FirstThirdPartTableViewCell: UITableViewCell {

    @IBOutlet weak var userCommentLB: UILabel!
    @IBOutlet weak var contentCommentLB: UILabel!
    @IBOutlet weak var contentCommentConstrant: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
