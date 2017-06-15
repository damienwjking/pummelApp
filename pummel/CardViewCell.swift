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
    
    @IBOutlet weak var moreInfoLabel: UILabel!
    @IBOutlet weak var moreInfoLeftView: UIView!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playVideoButton: UIButton!
    
    var videoPlayer: AVPlayer? = nil
    
    weak var delegate : CardViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.moreInfoLabel.font = UIFont.pmmMonReg13()
        self.moreInfoLeftView.layer.cornerRadius = self.moreInfoLeftView.frame.size.height/2;
        
        self.cardView.delegate = self
        self.cardView.registerTagCell()
    }
    
    func cardViewTagClicked() {
        if  self.delegate != nil {
            self.delegate?.cardViewCellTagClicked(self)
        }
    }
    
    func showVideo(videoURLString: String) {
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
        
//        self.endVideoNotification()
        self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
        self.videoPlayer?.pause()
    }
    
    func endVideoNotification(notification: NSNotification) {
        self.playVideoButton.hidden = false
        
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seekToTime(kCMTimeZero)
        self.videoPlayer?.pause()
        
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
        self.videoPlayer?.play()
        self.playVideoButton.hidden = true
    }
}
