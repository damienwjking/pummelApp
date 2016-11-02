//
//  FirstSecondPartTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class FeedSecondPartTableViewCell: UITableViewCell {


    @IBOutlet weak var likeLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.likeLB.font = .pmmMonReg13()
        // Initialization code
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
