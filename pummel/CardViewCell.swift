//
//  CardViewCell.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 2/22/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

@objc protocol CardViewCellDelegate {
    func cardViewCellTagClicked(cell: CardViewCell)
    func cardViewCellMoreInfoClicked(cell: CardViewCell)
    func cardViewSwipeLeft()
    func cardViewSwipeRight()
    func cardViewRefineButtonClicked()
}

class CardViewCell: UICollectionViewCell, CardViewDelegate {
    @IBOutlet weak var cardView: CardView!
    
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var moreInfoLabel: UILabel!
    @IBOutlet weak var moreInfoLeftView: UIView!
    
    @IBOutlet weak var avatarBorderView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playVideoButton: UIButton!
    
    var firstShowVideo = false
    var videoPlayer: AVPlayer? = nil
    var videoPlayerLayer: AVPlayerLayer? = nil
    var isVideoPlaying = false
    
    var delegate : CardViewCellDelegate? = nil
    
    @IBOutlet weak var avatarImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.moreInfoLabel.font = UIFont.pmmMonReg13()
        self.moreInfoLeftView.layer.cornerRadius = self.moreInfoLeftView.frame.size.height/2;
        
        self.cardView.delegate = self
        self.cardView.registerTagCell()
        
        self.avatarBorderView.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
        self.avatarBorderView.layer.cornerRadius = 0
        self.avatarBorderView.layer.masksToBounds = true
        
        self.cardView.avatarIMV.layer.masksToBounds = true
        
        self.playVideoButton.isHidden = true
        
        self.clipsToBounds = false
        
        // add Swipe gesture
        if (self.gestureRecognizers == nil || (self.gestureRecognizers?.count)! < 2) {
            
            let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftGesture(_:)))
            swipeLeftGesture.direction = .left
            self.addGestureRecognizer(swipeLeftGesture)
            
            let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightGesture(_:)))
            swipeRightGesture.direction = .right
            self.addGestureRecognizer(swipeRightGesture)
        }
    }
    
    func swipeLeftGesture(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.cardViewSwipeLeft()
        }
    }
    
    func swipeRightGesture(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.cardViewSwipeRight()
        }
    }
    
    func setupData(coachTotalDetail: NSDictionary) {
        let coachDetail = coachTotalDetail[kUser] as! NSDictionary
        
        // Tag
        let coachListTags = coachDetail[kTags] as! NSArray
        
        self.cardView.tags.removeAll()
        for i in 0 ..< coachListTags.count {
            let tagContent = coachListTags[i] as! NSDictionary
            let tag = TagModel()
            tag.tagTitle = tagContent[kTitle] as? String
            self.cardView.tags.append(tag)
        }
        self.cardView.collectionView.reloadData()
        
        // Coach detail
        self.cardView.avatarIMV.image = nil
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.backgroundColor = self.cardView.backgroundColor
        self.cardView.connectV.layer.cornerRadius = 50
        self.cardView.connectV.clipsToBounds = true
        self.cardView.nameLB.font = .pmmPlayFairReg24()
        
        let firstName = coachDetail[kFirstname] as! String
        if (coachDetail[kLastName] is NSNull == false) {
            let lastName = coachDetail[kLastName] as! String
            
            self.cardView.nameLB.text = firstName + " " + lastName
        } else {
            self.cardView.nameLB.text = firstName
        }
        
        // Coach avatar
        self.cardView.addressLB.font = .pmmPlayFairReg11()
        if (coachTotalDetail[kServiceArea] is NSNull == false) {
            self.cardView.addressLB.text = coachTotalDetail[kServiceArea] as? String
        }
        
        if (coachDetail[kImageUrl] is NSNull == false) {
            let imageLink = coachDetail[kImageUrl] as! String
            
            ImageVideoRouter.getImage(imageURLString: imageLink, sizeString: widthHeightScreen, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.cardView.avatarIMV.image = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
        // Business ImageView
        self.cardView.connectV.isHidden = true
        if (coachDetail[kBusinessId] is NSNull == false) {
            let businessId = String(format:"%0.f", (coachDetail[kBusinessId]! as AnyObject).doubleValue)
            
            ImageVideoRouter.getBusinessLogo(businessID: businessId, sizeString: widthHeight120, completed: { (result, error) in
                if (error == nil) {
                    self.cardView.connectV.isHidden = false
                    
                    let imageRes = result as! UIImage
                    self.cardView.businessIMV.image = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
        // Video
        let videoURL = coachDetail[kVideoURL] as? String
        if (videoURL != nil && videoURL!.isEmpty == false) {
            self.playVideoButton.isHidden = false
            self.playVideoButton.isUserInteractionEnabled = false
        }
    }
    
    func cardViewTagClicked() {
        if  self.delegate != nil {
            self.delegate?.cardViewCellTagClicked(cell: self)
        }
    }
    
    @IBAction func moreInfoViewClicked(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate?.cardViewCellMoreInfoClicked(cell: self)
        }
    }
}
