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
}

class CardViewCell: UICollectionViewCell, CardViewDelegate {
    @IBOutlet weak var cardView: CardView!
    
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var moreInfoLabel: UILabel!
    @IBOutlet weak var moreInfoLeftView: UIView!
    
    @IBOutlet weak var avatarBorderView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playVideoButton: UIButton!
    
    var videoPlayer: AVPlayer? = nil
    
    weak var delegate : CardViewCellDelegate? = nil
    
    @IBOutlet weak var avatarImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.moreInfoLabel.font = UIFont.pmmMonReg13()
        self.moreInfoLeftView.layer.cornerRadius = self.moreInfoLeftView.frame.size.height/2;
        
        self.cardView.delegate = self
        self.cardView.registerTagCell()
        
        self.avatarBorderView.layer.borderColor = UIColor.pmmBrightOrangeColor().CGColor
        self.avatarBorderView.layer.cornerRadius = 0
        self.avatarBorderView.layer.masksToBounds = true
        
        self.cardView.avatarIMV.layer.masksToBounds = true
    }
    
    func cardViewTagClicked() {
        if  self.delegate != nil {
            self.delegate?.cardViewCellTagClicked(self)
        }
    }
    
    func showVideoLayout() {
        let avatarSize: CGFloat = 37.0
        
        self.avatarImageViewTopConstraint.constant = 10
        self.avatarImageViewLeadingConstraint.constant = 10
        self.avatarImageViewWidthConstraint.constant = avatarSize - self.frame.width
        
        UIView.animateWithDuration(0.3) { 
            self.layoutIfNeeded()
            
            self.avatarBorderView.layer.cornerRadius = (avatarSize + 2)/2
            self.avatarBorderView.layer.borderWidth = 3
            
            self.cardView.avatarIMV.layer.cornerRadius = avatarSize/2
        }
    }
    
    func showVideo(videoURLString: String) {
        // check Video URL
        if (videoURLString.isEmpty == true) {
            return
        }
        
        self.showVideoLayout()
        
        // show play button
        self.playVideoButton.hidden = false
        
        // Show Video
        let videoURL = NSURL(string: videoURLString)
        self.videoPlayer = AVPlayer(URL: videoURL!)
        self.videoPlayer!.actionAtItemEnd = .None
        let playerLayer = AVPlayerLayer(player: self.videoPlayer)
        playerLayer.frame = self.videoView!.bounds
        
        self.videoView!.layer.addSublayer(playerLayer)
        
        // Remove loop play video for reuser cell
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        // Add notification for loop play video
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.endVideoNotification),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: videoPlayer?.currentItem)
    }
    
    func stopPlayVideo() {
        // Remove notification
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
        self.videoPlayer?.pause()
    }
    
    func endVideoNotification(notification: NSNotification) {
        // Show play button + info view
        self.playVideoButton.setImage(UIImage(named: "icon_play_video"), forState: .Normal)
        self.moreInfoView.hidden = false
        
        // Show first frame video
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seekToTime(kCMTimeZero)
        self.videoPlayer?.pause()
        
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        if (self.playVideoButton.imageView != nil) {
            // Play video in 0
            self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
            self.videoPlayer?.play()
            
            // Hidden play button + info view
            self.playVideoButton.setImage(nil, forState: .Normal)
            self.moreInfoView.hidden = true
        }
    }
}
