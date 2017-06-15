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
    
    var videoLayer: AVPlayer? = nil
    
    weak var delegate : CardViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.moreInfoLabel.font = UIFont.pmmMonReg13()
        self.moreInfoLeftView.layer.cornerRadius = self.moreInfoLeftView.frame.size.height/2;
        
        self.cardView.delegate = self
        self.cardView.registerTagCell()
        
        self.playVideoButton.hidden = true
    }
    
    func cardViewTagClicked() {
        if  self.delegate != nil {
            self.delegate?.cardViewCellTagClicked(self)
        }
    }
    
    func showVideo(videoURLString: String) {
        // Hiddle image background
        self.videoView.hidden = false
        
        // Show Video
        let videoURL = NSURL(string: videoURLString)
        self.videoLayer = AVPlayer(URL: videoURL!)
        self.videoLayer!.actionAtItemEnd = .None
        self.videoLayer!.play()
        let playerLayer = AVPlayerLayer(player: self.videoLayer
        
        )
        playerLayer.frame = self.videoView!.bounds
        
        self.videoView!.layer.addSublayer(playerLayer)
        
        // Remove loop play video for
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        // Add notification for loop play video
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.endVideoNotification),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: nil)
    }
    
    func stopPlayVideo() {
        // Remove notification
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        self.endVideoNotification()
    }
    
    func endVideoNotification() {
        // Remove video layer
        self.videoView.hidden = true
        self.playVideoButton.hidden = false
        
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        self.videoLayer?.play()
        self.playVideoButton.hidden = true
    }
}
