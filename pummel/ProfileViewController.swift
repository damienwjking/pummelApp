//
//  ProfileViewController.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
// This will be the profile view controller



import UIKit
import Alamofire
import Mixpanel
import AVKit
import AVFoundation
import PhotosUI

class ProfileViewController:  BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var avatarIMVCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var smallIndicatorView: UIView!
    @IBOutlet weak var medIndicatorView: UIView!
    @IBOutlet weak var bigIndicatorView: UIView!
    @IBOutlet weak var bigBigIndicatorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var coachBorderV: UIView!
    @IBOutlet weak var coachBorderBackgroundV: UIView!
    @IBOutlet weak var connectV : UIView!
    @IBOutlet weak var connectBT : UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var addressLB: UILabel!
    @IBOutlet weak var addressIconIMV: UIImageView!
    @IBOutlet weak var interestLB: UILabel!
    @IBOutlet weak var specialitiesLB: UILabel!
    @IBOutlet weak var aboutLB: UILabel!
    @IBOutlet weak var qualificaitonLB: UILabel!
    @IBOutlet weak var socailLB: UILabel!
    @IBOutlet weak var postLB: UILabel!
    @IBOutlet weak var interestCollectionView: UICollectionView!
    @IBOutlet weak var interestFlowLayout: FlowLayout!
    @IBOutlet weak var aboutCollectionView: UICollectionView!
    @IBOutlet weak var aboutFlowLayout: FlowLayout!
    @IBOutlet weak var aboutLeftDT: NSLayoutConstraint!
    @IBOutlet weak var businessIMV: UIImageView!
    @IBOutlet weak var postHeightDT: NSLayoutConstraint!
    @IBOutlet weak var interestHeightDT: NSLayoutConstraint!
    @IBOutlet weak var postV: UIView!
    @IBOutlet weak var imageV: UIView!
    @IBOutlet weak var detailV: UIView!
    @IBOutlet weak var interestV: UIView!
    @IBOutlet weak var aboutV: UIView!
    @IBOutlet weak var aboutHeightDT: NSLayoutConstraint!
    @IBOutlet weak var qualificationV: UIView!
    @IBOutlet weak var qualificationDT: NSLayoutConstraint!
    @IBOutlet weak var achivementDT: NSLayoutConstraint!
    @IBOutlet weak var socailV: UIView!
    @IBOutlet weak var facebookV: UIView!
    @IBOutlet weak var facebookBT: UIButton!
    @IBOutlet weak var twiterV: UIView!
    @IBOutlet weak var twiterBT: UIButton!
    @IBOutlet weak var instagramV: UIView!
    @IBOutlet weak var instagramBT: UIButton!
    @IBOutlet weak var facebookDT: NSLayoutConstraint!
    @IBOutlet weak var twiterDT: NSLayoutConstraint!
    @IBOutlet weak var instagramDT: NSLayoutConstraint!
    @IBOutlet weak var socalDT: NSLayoutConstraint!
    @IBOutlet weak var socalBTDT: NSLayoutConstraint!
    @IBOutlet weak var aboutTV: UITextView!
    @IBOutlet weak var aboutTVHeightDT: NSLayoutConstraint!
    @IBOutlet weak var webTV: UITextView!
    @IBOutlet weak var webTVHeightDT: NSLayoutConstraint!
    @IBOutlet weak var webHeightDT: NSLayoutConstraint!
    @IBOutlet weak var qualificationTV: UITextView!
    @IBOutlet weak var qualificationTVHeightDT: NSLayoutConstraint!
    @IBOutlet weak var achivementTV: UITextView!
    @IBOutlet weak var achivementTVHeightDT: NSLayoutConstraint!
    @IBOutlet weak var specifiesDT: NSLayoutConstraint!
    
    @IBOutlet weak var ratingLB: UILabel!
    @IBOutlet weak var ratingContentLB: UILabel!
    
    @IBOutlet weak var connectionLB: UILabel!
    @IBOutlet weak var connectionContentLB: UILabel!
    
    @IBOutlet weak var postNumberLB: UILabel!
    @IBOutlet weak var postNumberContentLB: UILabel!
    
    var instagramLink: String? = ""
    var twitterLink: String? = ""
    var facebookLink: String? = ""
    var oldPositionAboutV: CGFloat!
    var statusBarDefault: Bool!
    var coachDetail: NSDictionary!
    var sizingCell: TagCell?
    var tags = [Tag]()
    var arrayPhotos: NSMutableArray = []
    var isFromFeed: Bool = false
    var offset: Int = 0
    var isStopGetListPhotos : Bool = false
    let SCREEN_MAX_LENGTH = max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
    
    let imagePickerController = UIImagePickerController()
    var videoView: UIView? = nil
    var videoPlayer: AVPlayer? = nil
    var isShowVideo: Bool = true
    let videoIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.bigBigIndicatorView.alpha = 0.005
        self.bigIndicatorView.alpha = 0.01
        self.medIndicatorView.alpha = 0.025
        self.smallIndicatorView.alpha = 0.05
        
        self.bigBigIndicatorView.layer.cornerRadius = 374/2
        self.bigIndicatorView.layer.cornerRadius = 312/2
        self.medIndicatorView.layer.cornerRadius = 240/2
        self.smallIndicatorView.layer.cornerRadius = 180/2
        
        self.bigBigIndicatorView.clipsToBounds = true
        self.bigIndicatorView.clipsToBounds = true
        self.medIndicatorView.clipsToBounds = true
        self.smallIndicatorView.clipsToBounds = true
        
        self.connectV.layer.cornerRadius = 55/2
        self.connectV.clipsToBounds = true
        self.connectV.backgroundColor = UIColor(red: 255.0 / 255.0, green: 91.0 / 255.0, blue: 16.0 / 255.0, alpha: 1.0)
        self.addressLB.font = .pmmMonReg11()
        self.interestLB.font = .pmmMonReg11()
        self.specialitiesLB.font = .pmmMonLight11()
        self.qualificationTV.font = .pmmMonLight13()
        self.socailLB.font = .pmmMonLight11()
        self.postLB.font = .pmmMonLight11()
        self.aboutLB.font = .pmmMonLight11()
        self.aboutTV.backgroundColor = .clearColor()
        self.aboutTV.font = .pmmMonLight13()
        self.aboutTV.scrollEnabled = false
        self.qualificationTV.backgroundColor = .clearColor()
        self.qualificationTV.font = .pmmMonLight13()
        self.qualificationTV.scrollEnabled = false
        self.facebookBT.titleLabel?.font = .pmmMonReg11()
        self.twiterBT.titleLabel?.font = .pmmMonReg11()
        self.instagramBT.titleLabel?.font = .pmmMonReg11()
        self.avatarIMV.layer.cornerRadius = 125/2
        self.coachBorderV.layer.cornerRadius = 135/2
        self.coachBorderBackgroundV.layer.cornerRadius = 129/2
        self.avatarIMV.clipsToBounds = true
        self.coachBorderBackgroundV.hidden = true
        self.coachBorderV.hidden = true
        self.scrollView.scrollsToTop = false
        self.interestCollectionView.delegate = self
        self.interestCollectionView.dataSource = self
        
        self.businessIMV.hidden = true
        self.aboutLeftDT.constant = 10
        self.businessIMV.layer.cornerRadius = 50
        self.businessIMV.clipsToBounds = true
        
        self.interestFlowLayout.smaller = true
        let cellNib = UINib(nibName: kTagCell, bundle: nil)
        self.interestCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: kTagCell)
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
            self.interestFlowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 8)
        } else {
            self.interestFlowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        
        self.interestCollectionView.backgroundColor = UIColor.clearColor()
        self.aboutCollectionView.backgroundColor = UIColor.clearColor()
        self.statusBarDefault = false
        self.aboutCollectionView.delegate = self
        self.aboutCollectionView.dataSource = self
        self.ratingLB.font = .pmmMonLight10()
        self.ratingContentLB.font = .pmmMonReg16()
        self.connectionLB.font = .pmmMonLight10()
        self.connectionLB.text = (defaults.boolForKey(k_PM_IS_COACH)) ? "RATING" : "SESSIONS"
        self.connectionContentLB.font = .pmmMonReg16()
        self.postNumberLB.font = .pmmMonLight10()
        self.postNumberContentLB.font = .pmmMonReg16()
        self.aboutCollectionView.backgroundColor = UIColor.pmmWhiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.title = kNavProfile
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.translucent = false;
        let selectedImage = UIImage(named: "profilePressed")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"SETTINGS", style:.Plain, target: self, action: #selector(ProfileViewController.setting))
        self.tabBarController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState:.Normal)
        
        self.getDetail()
        
        self.playVideoButton.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove video layer
        if (self.videoView != nil && self.videoView?.layer != nil && self.videoView?.layer.sublayers != nil) {
            for layer in (self.videoView?.layer.sublayers)! {
                layer.removeFromSuperlayer()
            }
            
            self.videoPlayer?.pause()
            
            // Remove video view
            self.videoView?.removeFromSuperview()
        }
    }
    
    func showVideoLayout(videoURLString: String) {
        // Move avatar to top left
        let newAvatarSize: CGFloat = 37.0
        let margin: CGFloat = 10.0
        self.avatarIMVCenterXConstraint.constant = -(self.detailV.frame.width - newAvatarSize)/2 + margin
        self.avatarIMVCenterYConstraint.constant = -(self.detailV.frame.height - newAvatarSize)/2 + margin
        self.avatarIMVWidthConstraint.constant = newAvatarSize
        
        self.avatarIMV.layer.cornerRadius = newAvatarSize/2
        self.coachBorderV.layer.cornerRadius = (newAvatarSize + 10)/2
        self.coachBorderBackgroundV.layer.cornerRadius = (newAvatarSize + 4)/2
        
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
        let playerLayer = AVPlayerLayer(player: self.videoPlayer)
        playerLayer.frame = self.videoView!.bounds
        self.videoView!.layer.addSublayer(playerLayer)
        
        self.detailV.insertSubview(self.videoView!, atIndex: 0)
        
        // Animation
        UIView.animateWithDuration(0.5, animations: {
            self.detailV.layoutIfNeeded()
            }) { (_) in
                self.videoPlayer!.play()
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
    
    func endVideoNotification(notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        
        playerItem.seekToTime(kCMTimeZero)
        
        self.videoPlayer?.pause()
        self.playVideoButton.hidden = false
    }
    
    func setting() {
        performSegueWithIdentifier("goSetting", sender: nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Go Setting"]
        mixpanel.track("IOS.Profile", properties: properties)
    }
    
    @IBAction func edit() {
        if (self.defaults.boolForKey(k_PM_IS_COACH) != true) {
            performSegueWithIdentifier("goEdit", sender: nil)
        } else {
            performSegueWithIdentifier("goEditCoach", sender: nil)
        }
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Go Edit Profile"]
        mixpanel.track("IOS.Profile", properties: properties)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "goEdit")
        {
            let destinationVC = segue.destinationViewController as! EditProfileViewController
            destinationVC.userInfo = self.coachDetail
        } else if (segue.identifier == "goEdit") {
            let destinationVC = segue.destinationViewController as! EditCoachProfileViewController
            destinationVC.userInfo = self.coachDetail
        } else if segue.identifier == "goSetting" {
            let destinationVC = segue.destinationViewController as! SettingsViewController
            destinationVC.userInfo = self.coachDetail
        }  else if segue.identifier == "goToFeedDetail" {
            let navc = segue.destinationViewController as! UINavigationController
            let destination = navc.topViewController as! FeedViewController
            destination.fromPhoto = true
            if let feed = sender as? NSDictionary {
                destination.feedDetail = feed
            }
        }
    }
    
    func getDetail() {
        self.tabBarController?.navigationItem.rightBarButtonItem?.enabled = false
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                self.tabBarController?.navigationItem.rightBarButtonItem?.enabled = true
                if response.response?.statusCode == 200 {
                    if (response.result.value == nil) {return}
                    self.coachDetail = response.result.value as! NSDictionary
                    self.defaults.setObject(self.coachDetail["newleadNotification"] as! Int == 0 ? false : true, forKey: kNewConnections)
                    self.defaults.setObject(self.coachDetail["messageNotification"] as! Int == 0 ? false : true, forKey: kMessage)
                    self.defaults.setObject(self.coachDetail["sessionNotification"] as! Int == 0 ? false : true, forKey: kSessions)
                    self.defaults.setObject(self.coachDetail[kUnits], forKey: kUnit)
                    self.defaults.setObject(self.coachDetail[kFirstname], forKey: kFirstname)
                    kFirstname
                    self.setAvatar()
                    if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
                        self.setBusiness()
                        self.setTag()
                        self.updateUI()
                        self.getListImage()
                    } else {
                        self.updateUIUser()
                        self.getListImage()
                    }
                    
                    // check Video URL
                    let videoURL = self.coachDetail[kVideoURL] as? String
                    if (videoURL?.isEmpty == false && self.isShowVideo == true) {
                        self.showVideoLayout(videoURL!)
                    }
                } else if response.response?.statusCode == 401 {
                    let alertController = UIAlertController(title: pmmNotice, message: cookieExpiredNotice, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // TODO: LOGOUT
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                }
        }
    }
    
    func setAvatar() {
        if !(coachDetail[kImageUrl] is NSNull) {
            let imageLink = coachDetail[kImageUrl] as! String
            var prefix = kPMAPI
            prefix.appendContentsOf(imageLink)
            let postfix = widthHeight250
            prefix.appendContentsOf(postfix)
            if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                self.avatarIMV.image = imageRes
                self.coachBorderBackgroundV.hidden = false
                
                if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
                    self.coachBorderV.hidden = false
                } else {
                    self.coachBorderV.hidden = true
                }
            } else {
                Alamofire.request(.GET, prefix)
                    .responseImage { response in
                        if (response.response?.statusCode == 200) {
                            let imageRes = response.result.value! as UIImage
                            self.avatarIMV.image = imageRes
                            NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                            self.coachBorderBackgroundV.hidden = false
                            
                            if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
                                self.coachBorderV.hidden = false
                            } else {
                                self.coachBorderV.hidden = true
                            }
                        }
                }
            }
        }
    }
    
    func setBusiness() {
        if !(coachDetail[kBusinessId] is NSNull) {
            if (coachDetail[kBusinessId] != nil) {
                let businessId = String(format:"%0.f", coachDetail[kBusinessId]!.doubleValue)
                var linkBusinessId = kPMAPI_BUSINESS
                linkBusinessId.appendContentsOf(businessId)
                Alamofire.request(.GET, linkBusinessId)
                    .responseJSON { response in
                        if response.response?.statusCode == 200 {
                            
                            let jsonBusiness = response.result.value as! NSDictionary
                            if !(jsonBusiness[kImageUrl] is NSNull) {
                                let businessLogoUrl = jsonBusiness[kImageUrl] as! String
                                var prefixLogo = kPMAPI
                                prefixLogo.appendContentsOf(businessLogoUrl)
                                prefixLogo.appendContentsOf(widthHeight120)
                                if (NSCache.sharedInstance.objectForKey(prefixLogo) != nil) {
                                    self.businessIMV.hidden = false
                                    let imageRes = NSCache.sharedInstance.objectForKey(prefixLogo) as! UIImage
                                    self.businessIMV.image = imageRes
                                    self.aboutLeftDT.constant = 120
                                } else {
                                    Alamofire.request(.GET, prefixLogo)
                                        .responseImage { response in
                                            if (response.response?.statusCode == 200) {
                                                self.businessIMV.hidden = false
                                                let imageRes = response.result.value! as UIImage
                                                self.businessIMV.image = imageRes
                                                self.aboutLeftDT.constant = 120
                                                NSCache.sharedInstance.setObject(imageRes, forKey: prefixLogo)
                                            }
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func setTag() {
        if (coachDetail[kTags] == nil) {
            let feedId = String(format:"%0.f", coachDetail[kId]!.doubleValue)
            var tagLink = kPMAPIUSER
            tagLink.appendContentsOf(feedId)
            tagLink.appendContentsOf("/tags")
            Alamofire.request(.GET, tagLink)
                .responseJSON { response in
                    if (response.response?.statusCode == 200) {
                        let tagArr = response.result.value as! [NSDictionary]
                        self.tags.removeAll()
                        for i in 0 ..< tagArr.count {
                            let tagContent = tagArr[i]
                            let tag = Tag()
                            tag.name = tagContent[kTitle] as? String
                            self.tags.append(tag)
                        }
                        self.interestCollectionView.reloadData({
                            self.specifiesDT.constant = self.interestCollectionView.collectionViewLayout.collectionViewContentSize().height < 78 ? 78 : self.interestCollectionView.collectionViewLayout.collectionViewContentSize().height
                            self.interestHeightDT.constant = ((self.interestCollectionView.collectionViewLayout.collectionViewContentSize().height + 50) < 128) ? 128 : (self.interestCollectionView.collectionViewLayout.collectionViewContentSize().height + 50)
                        })
                    }
            }
        } else {
            let coachListTags = coachDetail[kTags] as! NSArray
            self.tags.removeAll()
            for i in 0 ..< coachListTags.count {
                let tagContent = coachListTags[i] as! NSDictionary
                let tag = Tag()
                tag.name = tagContent[kTitle] as? String
                self.tags.append(tag)
            }
            self.interestCollectionView.reloadData({
                self.specifiesDT.constant = self.interestCollectionView.collectionViewLayout.collectionViewContentSize().height < 78 ? 78 : self.interestCollectionView.collectionViewLayout.collectionViewContentSize().height
                self.interestHeightDT.constant = (self.specifiesDT.constant + 50 < 128) ? 128 : (self.specifiesDT.constant + 50)
            })
        }
    }
    
    func getListImage() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(String(format:"%0.f", coachDetail[kId]!.doubleValue))
        prefix.appendContentsOf(kPM_PATH_PHOTOV2)
        prefix.appendContentsOf("\(self.offset)")
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                if let arrayphoto = JSON as? NSArray {
                    if arrayphoto.count > 0 {
                        self.offset += 10
                        self.arrayPhotos.addObjectsFromArray(arrayphoto as [AnyObject])
                        self.getListImage()
                    } else {
                        self.isStopGetListPhotos = true
                        self.aboutCollectionView.reloadData()
                        self.postHeightDT.constant = self.aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
                        self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: self.aboutCollectionView.frame.origin.y + self.postHeightDT.constant)
                        self.scrollView.scrollEnabled = true
                    }
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func updateUI() {
        var prefix = kPMAPICOACH
        prefix.appendContentsOf(String(format:"%0.f", coachDetail[kId]!.doubleValue))
        self.view.makeToastActivity(message: "Loading")
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let coachInformationTotal = JSON as! NSDictionary
                let coachInformation = coachInformationTotal[kUser] as! NSDictionary
                
                var totalPoint = 0.0
                if (self.defaults.boolForKey(k_PM_IS_COACH)) {
                    self.connectionContentLB.text = "100%"
                } else {
                    if (coachInformation[kConnectionCount] is NSNull) {
                        self.connectionContentLB.text = "0"
                    } else {
                        self.connectionContentLB.text = String(format:"%0.f", coachInformation[kConnectionCount]!.doubleValue)
                
                        totalPoint = totalPoint + (coachInformation[kConnectionCount]!.doubleValue * 120)
                    }
                }
                
                if (coachInformation[kPostCount] is NSNull) {
                    self.postNumberContentLB.text  = "0"
                } else {
                    self.postNumberContentLB.text = String(format:"%0.f", coachInformation[kPostCount]!.doubleValue)
                    
                    totalPoint = totalPoint + (coachInformation[kPostCount]!.doubleValue * 75)
                }
                self.ratingContentLB.text = String(format:"%0.f", totalPoint)
                
                if !(coachInformationTotal[kServiceArea] is NSNull) {
                    self.addressLB.text = coachInformationTotal[kServiceArea] as? String
                }
                
                if !(coachInformation[kBio] is NSNull) {
                    self.aboutTV.text = coachInformation[kBio] as! String
                }
                
                let sizeAboutTV = self.aboutTV.sizeThatFits(self.aboutTV.frame.size)
                self.aboutTVHeightDT.constant = sizeAboutTV.height
                if (self.aboutTV.text.isEmpty == true) {
                    self.aboutHeightDT.constant = 0;
                } else {
                    self.aboutHeightDT.constant = self.aboutTV.frame.origin.y + sizeAboutTV.height + 8
                }
                
                self.qualificationDT.constant = 0
                if !(coachInformationTotal[kQualification] is NSNull) {
                    let qualificationText = coachInformationTotal[kQualification] as! String
                    self.qualificationTV.text = qualificationText
                    let sizeQualificationTV = self.qualificationTV.sizeThatFits(self.qualificationTV.frame.size)
                    self.qualificationTVHeightDT.constant = sizeQualificationTV.height + 10
                    if qualificationText != "" {
                        self.qualificationDT.constant = self.qualificationTV.frame.origin.y + sizeQualificationTV.height
                    }
                } else {
                    self.qualificationTV.text = " "
                }
                
                self.achivementDT.constant = 0
                if !(coachInformationTotal[kAchievement] is NSNull) {
                    let achivementText = coachInformationTotal[kAchievement] as! String
                    self.achivementTV.text = achivementText
                    let sizeAchivementTV = self.achivementTV.sizeThatFits(self.achivementTV.frame.size)
                    self.achivementTVHeightDT.constant = sizeAchivementTV.height + 10
                    if achivementText != "" {
                        self.achivementDT.constant = self.qualificationTV.frame.origin.y + sizeAchivementTV.height
                    }
                } else {
                    self.achivementTV.text = " "
                }
                
                if !(coachInformationTotal[kWebsiteUrl] is NSNull) {
                    let achivementText = coachInformationTotal[kWebsiteUrl] as! String
                    self.webTV.text = achivementText
                    let sizeWebTV = self.webTV.sizeThatFits(self.webTV.frame.size)
                    self.webTVHeightDT.constant = sizeWebTV.height + 10
                    self.webHeightDT.constant = self.webTV.frame.origin.y + sizeWebTV.height
                } else {
                    self.webTV.text = " "
                    self.webHeightDT.constant = 0
                }
                
                if !(coachInformation[kInstagramUrl] is NSNull) {
                    self.instagramLink = coachInformation[kInstagramUrl] as? String
                }
                if !(coachInformation[kFacebookUrl] is NSNull) {
                    self.facebookLink = coachInformation[kFacebookUrl] as? String
                }
                if !(coachInformation[kTwitterUrl] is NSNull) {
                    self.twitterLink = coachInformation[kTwitterUrl] as? String
                }
                
                self.socalDT.constant = 94
                self.socalBTDT.constant = 50
                self.socailLB.text = "SOCIAL"
                if (self.instagramLink == "") {
                    if (self.facebookLink == "") {
                        if (self.twitterLink == "") {
                            self.facebookDT.constant = 0
                            self.twiterDT.constant = 0
                            self.instagramDT.constant = 0
                            self.socalBTDT.constant = 0
                            self.socalDT.constant = 0
                            self.socailLB.text = ""
                        } else {
                            self.facebookDT.constant = 0
                            self.twiterDT.constant = self.view.frame.size.width
                            self.instagramDT.constant = 0
                        }
                    } else {
                        if (self.twitterLink == "") {
                            self.facebookDT.constant = self.view.frame.size.width
                            self.twiterDT.constant = 0
                            self.instagramDT.constant = 0
                        } else {
                            self.facebookDT.constant =  self.view.frame.size.width/2
                            self.twiterDT.constant = self.view.frame.size.width/2
                            self.instagramDT.constant = 0
                        }
                    }
                } else {
                    if (self.facebookLink == "") {
                        if (self.twitterLink == "") {
                            self.facebookDT.constant = 0
                            self.twiterDT.constant = 0
                            self.instagramDT.constant = self.view.frame.size.width
                        } else {
                            self.facebookDT.constant = 0
                            self.twiterDT.constant = self.view.frame.size.width/2
                            self.instagramDT.constant = self.view.frame.size.width/2
                        }
                    } else {
                        if (self.twitterLink == "") {
                            self.facebookDT.constant = self.view.frame.size.width/2
                            self.twiterDT.constant = 0
                            self.instagramDT.constant = self.view.frame.size.width/2
                        } else {
                            self.facebookDT.constant = self.view.frame.size.width/3
                            self.twiterDT.constant = self.view.frame.size.width/3
                            self.instagramDT.constant = self.view.frame.size.width/3
                        }
                    }
                }
                self.view.hideToastActivity()
            case .Failure(let error):
                print("Request failed with error: \(error)")
                self.view.hideToastActivity()
                }
        }
        
    }
    
    func updateUIUser() {
        
        self.interestHeightDT.constant = 0
        self.coachBorderBackgroundV.hidden = true
        self.coachBorderV.hidden = true
        self.addressIconIMV.hidden = true
        
        var totalPoint = 0.0
        if (coachDetail[kConnectionCount] is NSNull) {
            self.connectionContentLB.text = "0"
        } else {
            self.connectionContentLB.text = String(format:"%0.f", coachDetail[kConnectionCount]!.doubleValue)
            
            totalPoint = totalPoint + (coachDetail[kConnectionCount]!.doubleValue * 120)
        }
        
        if (coachDetail[kPostCount] is NSNull) {
            self.postNumberContentLB.text  = "0"
        } else {
            self.postNumberContentLB.text = String(format:"%0.f", coachDetail[kPostCount]!.doubleValue)
            
            totalPoint = totalPoint + (coachDetail[kPostCount]!.doubleValue * 75)
        }
        self.ratingContentLB.text = String(format:"%0.f", totalPoint)
        
        self.addressLB.hidden = true
        
        if !(coachDetail[kBio] is NSNull) {
            self.aboutTV.text = coachDetail[kBio] as! String
        }
        
        let sizeAboutTV = self.aboutTV.sizeThatFits(self.aboutTV.frame.size)
        self.aboutTVHeightDT.constant = sizeAboutTV.height
        if (self.aboutTV.text.isEmpty == true) {
            self.aboutHeightDT.constant = 0;
        } else {
            self.aboutHeightDT.constant = self.aboutTV.frame.origin.y + sizeAboutTV.height + 8
        }
        
        self.qualificationTV.text = " "
        self.qualificationDT.constant = 0
        
        self.achivementTV.text = " "
        self.achivementDT.constant = 0
        
        self.webTV.text = " "
        self.webHeightDT.constant = 0
        
        if !(coachDetail[kInstagramUrl] is NSNull) {
            self.instagramLink = coachDetail[kInstagramUrl] as? String
        }
        if !(coachDetail[kFacebookUrl] is NSNull) {
            self.facebookLink = coachDetail[kFacebookUrl] as? String
        }
        if !(coachDetail[kTwitterUrl] is NSNull) {
            self.twitterLink = coachDetail[kTwitterUrl] as? String
        }
        
        self.socalDT.constant = 94
        self.socalBTDT.constant = 50
        self.socailLB.text = "SOCIAL"
        if (self.instagramLink == "") {
            if (self.facebookLink == "") {
                if (self.twitterLink == "") {
                    self.facebookDT.constant = 0
                    self.twiterDT.constant = 0
                    self.instagramDT.constant = 0
                    self.socalBTDT.constant = 0
                    self.socalDT.constant = 0
                    self.socailLB.text = ""
                } else {
                    self.facebookDT.constant = 0
                    self.twiterDT.constant = self.view.frame.size.width
                    self.instagramDT.constant = 0
                }
            } else {
                if (self.twitterLink == "") {
                    self.facebookDT.constant = self.view.frame.size.width
                    self.twiterDT.constant = 0
                    self.instagramDT.constant = 0
                } else {
                    self.facebookDT.constant =  self.view.frame.size.width/2
                    self.twiterDT.constant = self.view.frame.size.width/2
                    self.instagramDT.constant = 0
                }
            }
        } else {
            if (self.facebookLink == "") {
                if (self.twitterLink == "") {
                    self.facebookDT.constant = 0
                    self.twiterDT.constant = 0
                    self.instagramDT.constant = self.view.frame.size.width
                } else {
                    self.facebookDT.constant = 0
                    self.twiterDT.constant = self.view.frame.size.width/2
                    self.instagramDT.constant = self.view.frame.size.width/2
                }
            } else {
                if (self.twitterLink == "") {
                    self.facebookDT.constant = self.view.frame.size.width/2
                    self.twiterDT.constant = 0
                    self.instagramDT.constant = self.view.frame.size.width/2
                } else {
                    self.facebookDT.constant = self.view.frame.size.width/3
                    self.twiterDT.constant = self.view.frame.size.width/3
                    self.instagramDT.constant = self.view.frame.size.width/3
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        postHeightDT.constant = aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
        self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + postHeightDT.constant)
        self.scrollView.scrollEnabled = true
    }
    
    
    @IBAction func goBackToResult() {
        self.dismissViewControllerAnimated(true) {
        }
    }
    
    @IBAction func goConnection() {
        self.performSegueWithIdentifier(kGoConnect, sender: self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if (statusBarDefault == true) {
            return UIStatusBarStyle.Default
        } else {
            return UIStatusBarStyle.LightContent
        }
    }
    
    @IBAction func expandInterest(sender:UIButton) {
        if (self.interestHeightDT.constant == 50) {
            self.interestHeightDT.constant = 128
            self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + postHeightDT.constant)
            
        } else {
            self.interestHeightDT.constant = 50
            self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + postHeightDT.constant)
            
        }
    }
    
    @IBAction func expandAboutDetail(sender: UIButton) {
        if (self.postHeightDT.constant == 50) {
            self.postHeightDT.constant = 70
        } else {
            self.postHeightDT.constant = 50
        }
        if (self.view.frame.origin.y == 0.0) {
            self.oldPositionAboutV = self.view.frame.size.height - (self.postV.frame.size.height +
                self.aboutCollectionView.frame.size.height)
            var frameV : CGRect!
            frameV = self.view.frame
            frameV.origin.y = -self.postV.frame.origin.y
            frameV.size.height += self.oldPositionAboutV
            self.view.frame = frameV
            self.aboutLB.hidden = true
            self.statusBarDefault = true
            self.setNeedsStatusBarAppearanceUpdate()
            
        } else {
            self.statusBarDefault = false
            self.setNeedsStatusBarAppearanceUpdate()
            self.aboutLB.hidden = false
            var frameV : CGRect!
            frameV = self.view.frame
            frameV.origin.y = 0
            frameV.size.height -= self.oldPositionAboutV
            self.view.frame = frameV
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.interestCollectionView) {
            return tags.count
        } else {
            return arrayPhotos.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (collectionView == self.interestCollectionView) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTagCell, forIndexPath: indexPath) as! TagCell
            self.configureCell(cell, forIndexPath: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kAboutCollectionViewCell, forIndexPath: indexPath) as! AboutCollectionViewCell
            self.configureAboutCell(cell, forIndexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.arrayPhotos.count - 1 && self.isStopGetListPhotos == false {
            self.getListImage()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (collectionView == self.interestCollectionView) {
            self.configureCell(self.sizingCell!, forIndexPath: indexPath)
            var cellSize = self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            
            if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
                cellSize.width += 5;
            }
            
            return cellSize
        } else {
            return CGSizeMake(self.aboutCollectionView.frame.size.width/2, self.aboutCollectionView.frame.size.width/2)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.view.makeToastActivity()
        var prefix = kPMAPI
        prefix.appendContentsOf(kPMAPI_POSTOFPHOTO)
        let photo = self.arrayPhotos[indexPath.row] as! NSDictionary
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
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagName.textColor = UIColor.blackColor()
        cell.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    func configureAboutCell(cell: AboutCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        var prefix = kPMAPI
        let photo = self.arrayPhotos[indexPath.row] as! NSDictionary
        let postfix = widthEqual.stringByAppendingString((self.view.frame.size.width).description).stringByAppendingString(heighEqual).stringByAppendingString((self.view.frame.size.width).description)
        var link = photo.objectForKey(kImageUrl) as! String
        link.appendContentsOf(postfix)
        prefix.appendContentsOf(link)
        Alamofire.request(.GET, prefix)
            .responseImage { response in
                let imageRes = response.result.value! as UIImage
                cell.imageCell.image = imageRes
        }
    }
    
    @IBAction func clickOnFacebook() {
        if (self.facebookLink != "") {
            let facebookUrl = NSURL(string: self.facebookLink!)
            
            if UIApplication.sharedApplication().canOpenURL(facebookUrl!)
            {
                UIApplication.sharedApplication().openURL(facebookUrl!)
                
            } else {
                //redirect to safari because the user doesn't have Instagram
                UIApplication.sharedApplication().openURL(NSURL(string: "http://facebook.com/")!)
            }
            // Tracker mixpanel
            if let firstName = coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Facebook", "Label":"\(firstName.uppercaseString)"]
                mixpanel.track("IOS.SocialClick", properties: properties)
            }
        }
    }
    
    @IBAction func clickOnTwitter() {
        if (self.twitterLink != "") {
            let twitterUrl = NSURL(string: self.twitterLink!)
            
            if UIApplication.sharedApplication().canOpenURL(twitterUrl!)
            {
                UIApplication.sharedApplication().openURL(twitterUrl!)
                
            } else {
                //redirect to safari because the user doesn't have Instagram
                UIApplication.sharedApplication().openURL(NSURL(string: "http://twitter.com/")!)
            }
            // Tracker mixpanel
            if let firstName = coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Twitter", "Label":"\(firstName.uppercaseString)"]
                mixpanel.track("IOS.SocialClick", properties: properties)
            }
        }
    }
    
    @IBAction func clickOnInstagram() {
        if (self.instagramLink  != "") {
            let instagramUrl = NSURL(string: self.instagramLink!)
           
            if UIApplication.sharedApplication().canOpenURL(instagramUrl!)
            {
                UIApplication.sharedApplication().openURL(instagramUrl!)
                
            } else {
                //redirect to safari because the user doesn't have Instagram
                UIApplication.sharedApplication().openURL(NSURL(string: "http://instagram.com/")!)
            }
            // Tracker mixpanel
            if let firstName = coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Instagram", "Label":"\(firstName.uppercaseString)"]
                mixpanel.track("IOS.SocialClick", properties: properties)
            }
        }
    }
    
    @IBAction func cameraButtonClicked(sender: AnyObject) {
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        self.videoPlayer?.play()
        
        self.playVideoButton.hidden = true
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // send video by method mutipart to server
        let videoPath = info[UIImagePickerControllerMediaURL] as! NSURL
        let videoData = NSData(contentsOfURL: videoPath)
        let videoExtend = (videoPath.absoluteString!.componentsSeparatedByString(".").last?.lowercaseString)!
        let videoType = "video/" + videoExtend
        let videoName = "video." + videoExtend
        
        // Insert activity indicator
        self.view.makeToastActivity(message: "Uploading")
        
        // send video by method mutipart to server
        var prefix = kPMAPIUSER
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_VIDEO)
        var parameters = [String:AnyObject]()
        
        self.isShowVideo = false
        parameters = [kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String, kProfileVideo : "1"]
        Alamofire.upload(
            .POST,
            prefix,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: videoData!,
                    name: "file",
                    fileName:videoName,
                    mimeType:videoType)
                for (key, value) in parameters {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    
                case .Success(let upload, _, _):
                    upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                    }
                    upload.validate()
                    upload.responseJSON { response in
                        self.view.hideToastActivity()
                        
                        if (response.response?.statusCode == 200) {
                            let dictionary = response.result.value as! [NSDictionary]
                            let videoURL = dictionary.first![kVideoURL] as! String
                            
                            // Update videoURL for coach detail
                            let newCoachDetail = NSMutableDictionary.init(dictionary: self.coachDetail)
                            newCoachDetail.setValue(videoURL, forKey: KVideoUrl)
                            self.coachDetail = newCoachDetail
                            
                            self.isShowVideo = true
                            self.showVideoLayout(videoURL)
                        }
                    }
                    
                case .Failure( _): break
                    // Do nothing
                }
            }
        )
        
        
        imagePickerController.dismissViewControllerAnimated(true, completion: nil)
    }
}
