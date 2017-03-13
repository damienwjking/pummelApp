//
//  FirstThirdPartTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class FeedThirdPartTableViewCell: UITableViewCell {

    @IBOutlet weak var userCommentLB: UILabel!
    @IBOutlet weak var contentCommentTV: UITextView!
    @IBOutlet weak var contentCommentTVConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userCommentLB.font = .pmmMonLight13()
        self.contentCommentTV.font = .pmmMonLight16()
        self.contentCommentTV.linkTextAttributes = [NSFontAttributeName:UIFont.pmmMonLight16(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor(), NSUnderlineStyleAttributeName: NSNumber(int: 1)]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
