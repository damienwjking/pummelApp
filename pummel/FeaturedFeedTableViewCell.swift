//
//  FeaturedFeedTableViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 8/25/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

protocol FeaturedFeedTableViewCellDelegate {
    func FeaturedFeedCellGoToDetail(cell : FeaturedFeedTableViewCell)
    func FeaturedFeedCellShowContext(cell : FeaturedFeedTableViewCell)
    func FeaturedFeedCellShowProfile(cell : FeaturedFeedTableViewCell)
    func FeaturedFeedCellInteractWithURL(URL: URL)
}

class FeaturedFeedTableViewCell: UITableViewCell {
    var delegate : FeaturedFeedTableViewCellDelegate? = nil
    
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
        
        self.firstContentCommentTV.linkTextAttributes = [NSFontAttributeName:UIFont.pmmMonLight16(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor(), NSUnderlineStyleAttributeName: NSNumber(value: 1)]
        
        self.likeBT.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
        
        self.imageContentIMV.isUserInteractionEnabled = true
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageContentIMVDoubleTap(sender:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.imageContentIMV.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewAllBTClicked(_:)))
        self.imageContentIMV.addGestureRecognizer(singleTapGesture)
        singleTapGesture.require(toFail: doubleTapGesture)
        
        self.likeImage?.isHidden = true
        self.likeBT.addTarget(self, action:#selector(self.imageContentIMVDoubleTap(sender:)), for: .touchUpInside)
    }
    
    func imageContentIMVDoubleTap(sender: UITapGestureRecognizer) {
        didDoubleTap = true
        self.likeImage?.isHidden = false
        self.likeImage?.alpha = 1.0
        UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseIn, animations: {
            self.likeImage?.alpha = 0
            }, completion: {
                (value:Bool) in
                
                FeedRouter.sendLikePost(postID: self.postId, completed: { (result, error) in
                    let likeSuccess = result as! Bool
                    if (likeSuccess == true) {
                        // Do nothing
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
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageContentIMV.image = nil
        self.likeBT.setBackgroundImage(nil, for: .normal)
    }
    
    @IBAction func like(sender: UIButton!) {
        if ((sender.backgroundImage(for: .normal)?.isEqual(UIImage(named: "like.png"))) ==  true) {
            sender.setBackgroundImage(UIImage(named: "liked.png"), for: .normal)
        } else {
            sender.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
        }
    }
    
    func setupData(feed: FeedModel) {
        // Name
        self.nameLB.text = feed.userName.uppercased()
        
        // Avatar
        self.avatarBT.setBackgroundImage(feed.userImageCache, for: .normal)
        
        // Time
        let timeAgo = feed.createdAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let date : NSDate = dateFormatter.date(from: timeAgo!)! as NSDate
        self.timeLB.text = date.timeAgoSinceDate()
        
        // Content image
        self.imageContentIMV.image = feed.contentImageCache
        
        // Check Coach
        self.isUserInteractionEnabled = false
        var coachLink  = kPMAPICOACH
        let coachId = String(format:"%ld", feed.userId)
        coachLink.append(coachId)
        
        self.avatarBT.layer.borderWidth = 0
        self.coachLB.text = ""
        self.coachLBTraillingConstraint.constant = 0
        
        UserRouter.checkCoachOfUser(userID: coachId) { (result, error) in
            self.isCoach = result as! Bool
            self.isUserInteractionEnabled = true
            
            if (error == nil) {
                if (self.isCoach == true) {
                    self.avatarBT.layer.borderWidth = 2
                    
                    self.coachLBTraillingConstraint.constant = 5
                    UIView.animate(withDuration: 0.3, animations: {
                        self.coachLB.layoutIfNeeded()
                        self.coachLB.text = kCoach.uppercased()
                    })
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
        
        // Like
        self.likeLB.text = feed.likeTotal + " likes"
        
        if (feed.isLiked == true) {
            self.likeBT.setBackgroundImage(UIImage(named: "liked"), for: .normal)
        } else {
            self.likeBT.setBackgroundImage(UIImage(named: "like"), for: .normal)
        }
        
        self.layoutIfNeeded()
        self.firstContentCommentTV.layoutIfNeeded()
        self.firstContentCommentTV.delegate = self
        self.firstContentCommentTV.text = feed.text
        
        let marginTopBottom = self.firstContentCommentTV.layoutMargins.top + self.firstContentCommentTV.layoutMargins.bottom
        let marginLeftRight = self.firstContentCommentTV.layoutMargins.left + self.firstContentCommentTV.layoutMargins.right
        self.firstContentTextViewConstraint.constant = (self.firstContentCommentTV.text?.heightWithConstrainedWidth(width: self.firstContentCommentTV.frame.width - marginLeftRight, font: self.firstContentCommentTV.font!))! + marginTopBottom + 1 // 1: magic number
        
        self.firstUserCommentLB.text = feed.userName.uppercased()
        
        self.postId = String(format:"%ld", feed.id)
    }
    
    @IBAction func avataImageClicked(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.FeaturedFeedCellShowProfile(cell: self)
        }
    }
    
    @IBAction func likeBTClicked(_ sender: Any) {
        // Do nothing
    }
    
    @IBAction func commentBTClicked(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.FeaturedFeedCellGoToDetail(cell: self)
        }
    }
    
    @IBAction func shareBTClicked(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.FeaturedFeedCellShowContext(cell: self)
        }
    }
    
    @IBAction func viewAllBTClicked(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.FeaturedFeedCellGoToDetail(cell: self)
        }
    }
}

extension FeaturedFeedTableViewCell : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (self.delegate != nil) {
            self.delegate?.FeaturedFeedCellInteractWithURL(URL: URL)
        }
    
        return false
    }
    
}
