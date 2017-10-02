//
//  FeedFirstPartTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class FeedFirstPartTableViewCell: UITableViewCell {
   
    @IBOutlet weak var avatarBT : UIButton!
    @IBOutlet weak var coachLB: UILabel!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var nameBT: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var imageContentIMV: UIImageView!
    @IBOutlet weak var likeBT : UIButton!
    @IBOutlet weak var shareBT: UIButton!
    @IBOutlet weak var coachLBTraillingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.avatarBT.layer.cornerRadius = 15
        self.avatarBT.clipsToBounds = true
        self.avatarBT.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
        self.nameLB.font = UIFont.pmmMonLight13()
        self.timeLB.font = UIFont.pmmMonLight13()
        self.coachLB.font = UIFont.pmmMonReg13()
        self.likeBT.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
    }
    
    @IBAction func like(sender: UIButton!) {
        if ((sender.backgroundImage(for: .normal)?.isEqual(UIImage(named: "like.png"))) ==  true) {
            sender.setBackgroundImage(UIImage(named: "liked.png"), for: .normal)
        } else {
            sender.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
