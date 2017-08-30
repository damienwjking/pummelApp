//
//  UserViewController.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import AVKit
import AVFoundation

class UserProfileViewController: BaseViewController  {
    @IBOutlet weak var avatarIMVCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVWidthConstraint: NSLayoutConstraint!
    
    //@IBOutlet weak var titleUserLB: UILabel!
    @IBOutlet weak var smallIndicatorView: UIView!
    @IBOutlet weak var medIndicatorView: UIView!
    @IBOutlet weak var bigIndicatorView: UIView!
    @IBOutlet weak var bigBigIndicatorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailV: UIView!
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var aboutLB: UILabel!
    @IBOutlet weak var postLB: UILabel!
    @IBOutlet weak var aboutCollectionView: UICollectionView!
    @IBOutlet weak var aboutFlowLayout: FlowLayout!
    @IBOutlet weak var postV: UIView!
    @IBOutlet weak var aboutV: UIView!
    @IBOutlet weak var aboutHeightDT: NSLayoutConstraint!
    @IBOutlet weak var aboutTV: UITextView!
    @IBOutlet weak var aboutTVHeightDT: NSLayoutConstraint!
    @IBOutlet var postHeightDT: NSLayoutConstraint!
    @IBOutlet weak var ratingLB: UILabel!
    @IBOutlet weak var ratingContentLB: UILabel!
    
    @IBOutlet weak var connectionLB: UILabel!
    @IBOutlet weak var connectionContentLB: UILabel!
    
    @IBOutlet weak var postNumberLB: UILabel!
    @IBOutlet weak var postNumberContentLB: UILabel!
    
    @IBOutlet weak var userNameLB: UILabel!
    
    var statusBarDefault: Bool!
    var userDetail: NSDictionary!
    var userId: String!
    var sizingCell: TagCell?
    var tags = [Tag]()
    
    var videoView: UIView? = nil
    var videoPlayer: AVPlayer? = nil
    var videoPlayerLayer: AVPlayerLayer? = nil
    var isShowVideo: Bool = true
    let videoIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var isVideoPlaying = false
    
    var arrayPhotos: NSArray = []
    
    
    // MARK: - Function
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        // Do any additional setup after loading the view.
        self.bigBigIndicatorView.layer.cornerRadius = 374/2
        self.bigIndicatorView.layer.cornerRadius = 312/2
        self.medIndicatorView.layer.cornerRadius = 240/2
        self.smallIndicatorView.layer.cornerRadius = 180/2
        
        self.bigBigIndicatorView.clipsToBounds = true
        self.bigIndicatorView.clipsToBounds = true
        self.medIndicatorView.clipsToBounds = true
        self.smallIndicatorView.clipsToBounds = true
        
        self.aboutCollectionView.delegate = self
        self.aboutCollectionView.dataSource = self
        
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(userId)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.userDetail = response.result.value as! NSDictionary
                    self.updateUI()
                }
        }
        self.userNameLB.font = .pmmMonReg13()
        self.aboutLB.font = .pmmMonLight11()
        self.postLB.font = .pmmMonLight11()
        self.aboutTV.backgroundColor = UIColor.clearColor()
        self.aboutTV.font = .pmmMonLight13()
        self.aboutTV.scrollEnabled = false
        self.avatarIMV.layer.cornerRadius = 125/2
        self.avatarIMV.clipsToBounds = true
        self.setAvatar()
        self.getListPhoto()
        self.ratingLB.font = .pmmMonLight10()
        self.ratingContentLB.font = .pmmMonReg16()
        self.connectionLB.font = .pmmMonLight10()
        self.connectionLB.text = "SESSIONS"
        self.connectionContentLB.font = .pmmMonReg16()
        self.postNumberLB.font = .pmmMonLight10()
        self.postNumberContentLB.font = .pmmMonReg16()
        self.aboutTV.editable = false
        
        self.playVideoButton.setImage(nil, forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        postHeightDT.constant = aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
        self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + postHeightDT.constant)
        self.scrollView.scrollEnabled = true
        
        // check Video URL
//        let videoURL = self.userDetail[kVideoURL] as? String
//        let videoURL = "https://pummel-prod.s3.amazonaws.com/videos/1497331500201-0.mp4" // test
        
//        if (videoURL?.isEmpty == false && self.isShowVideo == true) {
//            self.showVideoLayout(videoURL!)
//        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // pause video and move time to 0
        if (self.videoView != nil && self.videoView?.layer != nil && self.videoView?.layer.sublayers != nil) {
            self.videoPlayer?.pause()
            
            // Remove video view
            self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
            
            self.videoPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
        }
    }
    
    func setting() {
        performSegueWithIdentifier("goSetting", sender: nil)
    }
    
    @IBAction func edit() {
        performSegueWithIdentifier("goEdit", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "goEdit")
        {
            let destinationVC = segue.destinationViewController as! EditProfileViewController
            destinationVC.userInfo = self.userDetail
        } else if segue.identifier == "goToFeedDetail" {
            let navc = segue.destinationViewController as! UINavigationController
            let destination = navc.topViewController as! FeedViewController
            destination.fromPhoto = true
            if let feed = sender as? NSDictionary {
                destination.feedDetail = feed
            }
        }
    }
    
    @IBAction func goBackToFeed(sender:UIButton) {
        self.dismissViewControllerAnimated(true) {
        }
    }
    
    func getListPhoto() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(userId)
        prefix.appendContentsOf(kPM_PATH_PHOTO_PROFILE)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                self.arrayPhotos = JSON as! NSArray
                self.aboutCollectionView.reloadData()
                self.postHeightDT.constant = self.aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
                self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: self.aboutCollectionView.frame.origin.y + self.postHeightDT.constant)
                self.scrollView.scrollEnabled = true
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func setAvatar() {
        ImageRouter.getUserAvatar(userID: self.userId, sizeString: widthHeight160) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.avatarIMV.image = imageRes
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
    }
    
    func updateUI() {
        self.userNameLB.text = (self.userDetail[kFirstname] as! String).uppercaseString
        
        self.ratingContentLB.text = String(format:"%0.f", (self.userDetail[kConnectionCount]!.doubleValue * 120) + (self.userDetail[kPostCount]!.doubleValue * 75))
        
        self.connectionContentLB.text = String(format:"%0.f", self.userDetail[kConnectionCount]!.doubleValue)
        
        self.postNumberContentLB.text = String(format:"%0.f", self.userDetail[kPostCount]!.doubleValue)
        
        self.aboutTV.text = !(self.userDetail[kBio] is NSNull) ? self.userDetail[kBio] as! String : letAddYourDetail
        
        let sizeAboutTV = self.aboutTV.sizeThatFits(self.aboutTV.frame.size)
        
        self.aboutTVHeightDT.constant = sizeAboutTV.height
        
        self.aboutHeightDT.constant = self.aboutTV.frame.origin.y + sizeAboutTV.height + 8
    }
    
    // MARK: - Video 
    func showVideoLayout(videoURLString: String) {
        // Move avatar to top left
        let newAvatarSize: CGFloat = 37.0
        let leftMargin: CGFloat = 10.0
        let topMargin: CGFloat = 50.0
        self.avatarIMVCenterXConstraint.constant = -(self.detailV.frame.width - newAvatarSize)/2 + leftMargin
        self.avatarIMVCenterYConstraint.constant = -(self.detailV.frame.height - newAvatarSize)/2 + topMargin
        self.avatarIMVWidthConstraint.constant = newAvatarSize
        
        self.avatarIMV.layer.cornerRadius = newAvatarSize/2
        
        // Hidden indicator view
        self.smallIndicatorView.hidden = true
        self.medIndicatorView.hidden = true
        self.bigIndicatorView.hidden = true
        self.bigBigIndicatorView.hidden = true
        
        // Show video
        if (self.videoView?.superview != nil) {
            self.videoView?.removeFromSuperview()
        }
        self.videoView = UIView.init(frame: self.detailV.bounds)
        let videoURL = NSURL(string: videoURLString)
        self.videoPlayer = AVPlayer(URL: videoURL!)
        self.videoPlayer!.actionAtItemEnd = .None
        self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
        self.videoPlayerLayer!.frame = self.videoView!.bounds
        self.videoView!.layer.addSublayer(self.videoPlayerLayer!)
        
        self.videoPlayer!.currentItem!.addObserver(self, forKeyPath: "status", options: [.Old, .New], context: nil)
        
        self.detailV.insertSubview(self.videoView!, atIndex: 0)
        
        // Animation
        UIView.animateWithDuration(0.5, animations: {
            self.detailV.layoutIfNeeded()
        }) { (_) in
            self.videoPlayerSetPlay(false)
        }
        
        // Add indicator for video
        if (self.videoIndicator.superview != nil) {
            self.videoIndicator.removeFromSuperview()
        }
        self.videoIndicator.startAnimating()
        self.videoIndicator.center = CGPointMake(self.detailV.frame.width/2, self.detailV.frame.height/2)
        self.detailV.insertSubview(self.videoIndicator, atIndex: 0)
        
        // Remove loop play video for
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        // Add notification for loop play video
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.endVideoNotification),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: self.videoPlayer!.currentItem)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("observed \(keyPath) \(change)")
        let currentItem = object as! AVPlayerItem
        if currentItem.status == .ReadyToPlay {
            let videoRect = self.videoPlayerLayer?.videoRect
            if (videoRect?.width > videoRect?.height) {
//                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            } else {
                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            }
        }
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        self.isVideoPlaying = !self.isVideoPlaying
        self.videoPlayerSetPlay(self.isVideoPlaying)
    }
    
    func endVideoNotification(notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        
        // Show first frame video
        playerItem.seekToTime(kCMTimeZero)
        
        self.videoPlayerSetPlay(false)
    }
    
    func videoPlayerSetPlay(isPlay: Bool) {
        if (isPlay == true) {
            self.videoPlayer!.play()
            
            self.playVideoButton.setImage(nil, forState: .Normal)
        } else {
            self.videoPlayer?.pause()
            
            let playImage = UIImage(named: "icon_play_video")
            self.playVideoButton.setImage(playImage, forState: .Normal)
            
        }
        
        // Show item above video view
        self.isVideoPlaying = isPlay
        self.avatarIMV.hidden = isPlay
    }
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kAboutCollectionViewCell, forIndexPath: indexPath) as! AboutCollectionViewCell
        self.configureAboutCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.aboutCollectionView.frame.size.width/2, self.aboutCollectionView.frame.size.width/2)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.view.makeToastActivity()
        var prefix = kPMAPI
        prefix.appendContentsOf(kPMAPI_POSTOFPHOTO)
        let photo = self.arrayPhotos[indexPath.row] as! NSDictionary
        print(photo.objectForKey(kId)!)
        Alamofire.request(.GET, prefix, parameters: ["photoId":photo["uploadId"]!])
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                if let arr = JSON as? NSArray {
                    if arr.count > 0 {
                        if let dic = arr.objectAtIndex(0) as? NSDictionary {
                            self.performSegueWithIdentifier("goToFeedDetail", sender: dic)
                            self.view.hideToastActivity()
                            return
                        }
                    }
                }
                
                let alertController = UIAlertController(title: pmmNotice, message: notfindPhoto, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
                self.view.hideToastActivity()
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
                self.view.hideToastActivity()
        }
    }
    
    func configureAboutCell(cell: AboutCollectionViewCell?, forIndexPath indexPath: NSIndexPath) {
        let photo = self.arrayPhotos[indexPath.row] as! NSDictionary
        let postfix = widthEqual.stringByAppendingString((self.view.frame.size.width).description).stringByAppendingString(heighEqual).stringByAppendingString((self.view.frame.size.width).description)
        let link = photo.objectForKey(kImageUrl) as? String
        
        if (link != nil) {
            ImageRouter.getImage(imageURLString: link!, sizeString: postfix, completed: { (result, error) in
                if (error == nil && cell != nil) {
                    let imageRes = result as! UIImage
                    
                    cell!.imageCell.image = imageRes
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
    }
}
