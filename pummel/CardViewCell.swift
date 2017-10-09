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
        
        self.avatarBorderView.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
        self.avatarBorderView.layer.cornerRadius = 0
        self.avatarBorderView.layer.masksToBounds = true
        
        self.cardView.avatarIMV.layer.masksToBounds = true
        
        self.playVideoButton.isHidden = true
    }
    
    func cardViewTagClicked() {
        if  self.delegate != nil {
            self.delegate?.cardViewCellTagClicked(cell: self)
        }
    }
    
    func showVideoLayout() {
        let avatarSize: CGFloat = 37.0
        
        self.avatarImageViewTopConstraint.constant = 10
        self.avatarImageViewLeadingConstraint.constant = 10
        self.avatarImageViewWidthConstraint.constant = avatarSize - self.frame.width
        
        UIView.animate(withDuration: 0.3) { 
            self.layoutIfNeeded()
            
            self.avatarBorderView.layer.cornerRadius = (avatarSize + 2)/2
            self.avatarBorderView.layer.borderWidth = 3
            
            self.cardView.avatarIMV.layer.cornerRadius = avatarSize/2
        }
    }
    
    func showVideo(videoURLString: String) {
        if (self.firstShowVideo == false) {
            self.firstShowVideo = true
            // check Video URL
            if (videoURLString.isEmpty == true) {
                return
            }
            
            self.showVideoLayout()
            
            // show play button
            self.playVideoButton.isHidden = false
            
            // Show Video
            let videoURL = NSURL(string: videoURLString)
            self.videoPlayer = AVPlayer(url: videoURL! as URL)
            self.videoPlayer!.actionAtItemEnd = .none
            self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
            self.videoPlayerLayer?.frame = self.videoView!.bounds
            
            self.videoView!.layer.addSublayer(self.videoPlayerLayer!)
            
            self.videoPlayer?.currentItem?.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
            
            // Remove loop play video for reuser cell
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            // Add notification for loop play video
            NotificationCenter.default.addObserver(self,
                                                             selector: #selector(self.endVideoNotification),
                                                             name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                             object: videoPlayer?.currentItem)
        }
    }
    
    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
        let currentItem = object as! AVPlayerItem
        if currentItem.status == .readyToPlay {
            let videoRect = self.videoPlayerLayer?.videoRect
            if (Int((videoRect?.width)!) > Int((videoRect?.height)!)) {
//                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            } else {
                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            }
            
            self.videoPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
        }
    }
    
    func stopPlayVideo() {
        if (self.videoPlayer != nil )  {
            // Remove notification
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            self.videoPlayer?.currentItem?.seek(to: kCMTimeZero)
            self.videoPlayer?.pause()
            
            self.isVideoPlaying = true // Set for stop play video
            self.playVideoButtonClicked(sender: self.playVideoButton)
        }
    }
    
    func endVideoNotification(notification: NSNotification) {
        // Show play button + info view
        self.playVideoButton.setImage(UIImage(named: "icon_play_video"), for: .normal)
        self.moreInfoView.isHidden = false
        
        // Show first frame video
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: kCMTimeZero)
        self.videoPlayer?.pause()
        
        self.isVideoPlaying = false
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        self.isVideoPlaying = !self.isVideoPlaying
        if (self.isVideoPlaying == true) {
            self.videoPlayer?.play()
            
            // Hidden play button + info view
            self.playVideoButton.setImage(nil, for: .normal)
        } else {
            self.videoPlayer?.pause()
            
            // Show play button + info view
            self.playVideoButton.setImage(UIImage(named: "icon_play_video"), for: .normal)
        }
        
        self.moreInfoView.isHidden = self.isVideoPlaying
        self.cardView.avatarIMV.isHidden = self.isVideoPlaying
        self.avatarBorderView.isHidden = self.isVideoPlaying
    }
    
    @IBAction func moreInfoViewClicked(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.cardViewCellMoreInfoClicked(cell: self)
        }
    }
}
