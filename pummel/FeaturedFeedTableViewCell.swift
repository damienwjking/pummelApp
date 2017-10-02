//
//  FeaturedFeedTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 8/25/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class FeaturedFeedTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarBT : UIButton!
    @IBOutlet weak var coachLB: UILabel!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var imageContentIMV: UIImageView!
    @IBOutlet weak var likeBT : UIButton!
    @IBOutlet weak var commentBT : UIButton!
    @IBOutlet weak var shareBT: UIButton!
    @IBOutlet weak var likeLB: UILabel!
    @IBOutlet weak var firstUserCommentLB: UILabel!
    @IBOutlet weak var firstContentCommentTV: UITextView!
    @IBOutlet weak var coachLBTraillingConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstContentTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewAllLB: UILabel!
    @IBOutlet weak var viewAllBT: UIButton!
    @IBOutlet weak var likeImage: UIImageView!
    var postId: String!
    var isCoach: Bool!
    var didDoubleTap: Bool = false
   
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarBT.layer.cornerRadius = 15
        self.avatarBT.clipsToBounds = true
        self.avatarBT.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
        self.coachLB.font = .pmmMonReg13()
        self.nameLB.font = .pmmMonLight13()
        self.timeLB.font = .pmmMonLight13()
        self.likeLB.font = .pmmMonLight13()
        self.firstUserCommentLB.font = .pmmMonLight13()
        self.firstContentCommentTV.font = .pmmMonLight16()
        self.firstContentCommentTV.linkTextAttributes = [NSFontAttributeName:UIFont.pmmMonLight16(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor(), NSUnderlineStyleAttributeName: NSNumber(int: 1)]
        self.viewAllLB.font = .pmmMonLight13()
        self.likeBT.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(FeaturedFeedTableViewCell.onDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.imageContentIMV.isUserInteractionEnabled = true
        self.imageContentIMV.addGestureRecognizer(doubleTapGesture)
        self.likeImage?.isHidden = true
        self.likeBT.addTarget(self, action:#selector(FeaturedFeedTableViewCell.onDoubleTap(_:)), for: .touchUpInside)
    }
    
    func onDoubleTap(sender: UITapGestureRecognizer) {
//        self.imageContentIMV.isUserInteractionEnabled = false
//        self.likeBT.isUserInteractionEnabled = false
        didDoubleTap = true
        self.likeImage?.isHidden = false
        self.likeImage?.alpha = 1.0
        UIView.animate(withDuration: 0.5, delay: 0.4, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.likeImage?.alpha = 0
            }, completion: {
                (value:Bool) in
                var likeLink  = kPMAPI_LIKE
                likeLink.append(self.postId)
                likeLink.append(kPM_PATH_LIKE)
                Alamofire.request(.POST, likeLink, parameters: [kPostId:self.postId])
                    .responseJSON { response in
                        if response.response?.statusCode != 200 {
                            print("cant like")
                        }
                }
                self.likeBT.setBackgroundImage(UIImage(named: "liked.png"), for: .normal)
//                self.likeBT.isUserInteractionEnabled = false
                let sLikeArr = self.likeLB.text!.characters.split{$0 == " "}.map(String.init)
                var sLike = ""
                if (sLikeArr.count > 0) {
                    sLike = sLikeArr[0]
                } else {
                    sLike = "0"
                }
                let nLike = Int(sLike)! + 1
                sLike = String(nLike)
                sLike.append(" Likes")
                self.likeLB.text = sLike
                self.likeImage?.isHidden = true
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageContentIMV.image = nil
        self.likeBT.setBackgroundImage(nil, for: .normal)
    }
    
    @IBAction func like(sender: UIButton!) {
        if ((sender.backgroundImageForState(.Normal)?.isEqual(UIImage(named: "like.png"))) ==  true) {
            sender.setBackgroundImage(UIImage(named: "liked.png"), for: .normal)
        } else {
            sender.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
