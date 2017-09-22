//
//  ProfileViewController.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
// This will be the profile view controller



import UIKit
import AVKit
import Mixpanel
import PhotosUI
import MessageUI
import Alamofire
import AVFoundation

enum UploadVideoStatus: Int {
    case normal
    case uploading
}

enum ProfileState: Int {
    case currentUserProfile
    case otherUserProfile
}

class ProfileViewController:  BaseViewController, UITextViewDelegate {
    @IBOutlet weak var avatarIMVCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var smallIndicatorView: UIView!
    @IBOutlet weak var medIndicatorView: UIView!
    @IBOutlet weak var bigIndicatorView: UIView!
    @IBOutlet weak var bigBigIndicatorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var connectV : UIView!
    @IBOutlet weak var connectBT : UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var uploadingLabel: UILabel!
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
    @IBOutlet weak var webV: UIView!
    @IBOutlet weak var webTV: UITextView!
    @IBOutlet weak var webTVHeightDT: NSLayoutConstraint!
    @IBOutlet weak var webHeightDT: NSLayoutConstraint!
    @IBOutlet weak var qualificationV: UIView!
    @IBOutlet weak var qualificationDT: NSLayoutConstraint!
    @IBOutlet weak var qualificationTV: UITextView!
    @IBOutlet weak var qualificationTVHeightDT: NSLayoutConstraint!
    @IBOutlet weak var achivementV: UIView!
    @IBOutlet weak var achivementTV: UITextView!
    @IBOutlet weak var achivementTVHeightDT: NSLayoutConstraint!
    @IBOutlet weak var specifiesDT: NSLayoutConstraint!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationBackgroundImageView: UIImageView!
    
    @IBOutlet weak var ratingLB: UILabel!
    @IBOutlet weak var ratingContentLB: UILabel!
    
    @IBOutlet weak var connectionLB: UILabel!
    @IBOutlet weak var connectionContentLB: UILabel!
    
    @IBOutlet weak var postNumberLB: UILabel!
    @IBOutlet weak var postNumberContentLB: UILabel!
    
    @IBOutlet weak var testimonialView: UIView!
    @IBOutlet weak var testimonialTitle: UILabel!
    @IBOutlet weak var testimonialInviteButton: UIButton!
    @IBOutlet weak var testimonialCollectionView: UICollectionView!
    @IBOutlet weak var testimonialViewHeightConstraint: NSLayoutConstraint!
    
    var coachDetail: NSDictionary!
    var userID = PMHelper.getCurrentID()
    
    var instagramLink: String? = ""
    var twitterLink: String? = ""
    var facebookLink: String? = ""
    var oldPositionAboutV: CGFloat!
    var statusBarDefault: Bool!
    var sizingCell: TagCell?
    var tags = [Tag]()
    var photoArray: NSMutableArray = []
    var testimonialArray = [TestimonialModel]()
    var isFromFeed: Bool = false
    var offset: Int = 0
    var testimonialOffset = 0
    var isStopGetListPhotos : Bool = false
    var isStopGetTestimonial = false
    
    let imagePickerController = UIImagePickerController()
    var videoView: UIView? = nil
    var videoPlayer: AVPlayer? = nil
    var videoPlayerLayer: AVPlayerLayer? = nil
    var isShowVideo: Bool = true
    let videoIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var isVideoPlaying = false
    var isUploadingVideo: UploadVideoStatus = .normal {
        didSet {
            if (self.cameraButton != nil && self.uploadingLabel != nil) {
                dispatch_async(dispatch_get_main_queue(),{
                    if (self.isUploadingVideo == .normal) {
                        self.cameraButton.hidden = false
                        self.uploadingLabel.hidden = true
                        
                        // Remove for next time upload
                        self.uploadingLabel.text = ""
                    } else {
                        self.cameraButton.hidden = true
                        self.uploadingLabel.hidden = false
                    }
                })
            }
        }
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: View life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
        
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
        self.connectionLB.text = (self.defaults.boolForKey(k_PM_IS_COACH)) ? "RATING" : "SESSIONS"
        self.connectionContentLB.font = .pmmMonReg16()
        self.postNumberLB.font = .pmmMonLight10()
        self.postNumberContentLB.font = .pmmMonReg16()
        self.aboutCollectionView.backgroundColor = UIColor.pmmWhiteColor()
        
        let cameraImage = UIImage(named: "profile_camera")
        self.cameraButton.setImage(cameraImage, forState: .Normal)
        self.cameraButton.tintColor = UIColor.pmmBrightOrangeColor()
        
        // Add notification for update video url
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.profileGetNewDetail), name: "profileGetDetail", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.uploadVideoWithNotification), name: "profileUploadVideo", object: nil)
        
        let testimonialXib = UINib(nibName: kTestimonialCell, bundle: nil)
        self.testimonialCollectionView.registerNib(testimonialXib, forCellWithReuseIdentifier: kTestimonialCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.title = kNavProfile
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
//        self.navigationController!.navigationBar.translucent = false;
        let selectedImage = UIImage(named: "profilePressed")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"SETTINGS", style:.Plain, target: self, action: #selector(ProfileViewController.setting))
        self.tabBarController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState:.Normal)
        
        self.getDetail()
        
        self.playVideoButton.setImage(nil, forState: .Normal)
        
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            self.cameraButton.alpha = 1
            self.cameraButton.userInteractionEnabled = true
            self.avatarIMV.layer.borderWidth = 3
            
            self.testimonialInviteButton.hidden = false
        } else {
            self.cameraButton.alpha = 0
            self.cameraButton.userInteractionEnabled = false
            self.avatarIMV.layer.borderWidth = 0
            
            self.testimonialInviteButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        postHeightDT.constant = aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
        self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + postHeightDT.constant)
        self.scrollView.scrollEnabled = true
        
        self.isStopGetTestimonial = false
        self.testimonialOffset = 0
        self.testimonialArray.removeAll()
        self.getTestimonial()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // pause video and move time to 0
        if (self.videoView != nil && self.videoView?.layer != nil && self.videoView?.layer.sublayers != nil) {
            self.videoPlayerSetPlay(false)
            
            // Remove video view
            self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
        }
    }
    
    func setupUI() {
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
        
        self.locationView.layer.cornerRadius = 2
        self.locationView.layer.masksToBounds = true
        
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
        self.testimonialTitle.font = .pmmMonLight11()
        self.testimonialInviteButton.titleLabel?.font = .pmmMonReg11()
        self.avatarIMV.layer.cornerRadius = 125/2
        self.avatarIMV.clipsToBounds = true
        self.avatarIMV.layer.borderColor = UIColor.pmmBrightOrangeColor().CGColor
        self.avatarIMV.layer.borderWidth = 0
        self.scrollView.scrollsToTop = false
        self.interestCollectionView.delegate = self
        self.interestCollectionView.dataSource = self
        
        self.businessIMV.hidden = true
        self.aboutLeftDT.constant = 10
        self.businessIMV.layer.cornerRadius = 50
        self.businessIMV.clipsToBounds = true
        self.webTV.delegate = self
    }
    
    func profileGetNewDetail() {
        if (self.videoView != nil && self.videoView?.layer != nil && self.videoView?.layer.sublayers != nil) {
            self.videoPlayerLayer?.removeFromSuperlayer()
            
            self.videoView = nil
            
            self.getDetail()
        }
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
        if (segue.identifier == "goEdit") {
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
        } else if segue.identifier == "showCamera" {
            let destination = segue.destinationViewController as! CameraViewController
            
            destination.videoURL = sender as? NSURL
        }
    }
    
    func getDetail() {
        self.tabBarController?.navigationItem.rightBarButtonItem?.enabled = false
        
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(self.userID)
        
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
                    PMHelper.showLogoutAlert()
                }
        }
    }
    
    func setAvatar() {
        if (coachDetail[kImageUrl] is NSNull == false) {
            let imageLink = coachDetail[kImageUrl] as! String
            
            ImageRouter.getImage(imageURLString: imageLink, sizeString: widthHeight250, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.avatarIMV.image = imageRes
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
    }
    
    func setBusiness() {
        if (coachDetail[kBusinessId] is NSNull == false) {
            let businessId = String(format:"%0.f", coachDetail[kBusinessId]!.doubleValue)
            
            ImageRouter.getBusinessLogo(businessID: businessId, sizeString: widthHeight120, completed: { (result, error) in
                if (error == nil) {
                    self.businessIMV.hidden = false
                    let imageRes = result as! UIImage
                    self.businessIMV.image = imageRes
                    self.aboutLeftDT.constant = 120
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
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
                        self.photoArray.addObjectsFromArray(arrayphoto as [AnyObject])
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
    
    func getTestimonial() {
        if (self.isStopGetTestimonial == false) {
            UserRouter.getTestimonial(userID: self.userID, offset: self.testimonialOffset) { (result, error) in
                if (error == nil) {
                    let testimonialDicts = result as! NSArray
                    
                    if (testimonialDicts.count == 0) {
                        self.isStopGetTestimonial = true
                    }
                    
                    for testimonialDict in testimonialDicts {
                        let testimo = TestimonialModel()
                        
                        testimo.parseData(testimonialDict as! NSDictionary)
                        
                        var isExist = false
                        for test in self.testimonialArray {
                            if (test.id == testimo.id) {
                                isExist = true
                                break
                            }
                        }
                        
                        if (isExist == false) {
                            self.testimonialArray.append(testimo)
                        }
                    }
                    
                    self.testimonialOffset = self.testimonialOffset + 20
                    
                    self.testimonialCollectionView.reloadData()
                } else {
                    print("Request failed with error: \(error)")
                }
                }.fetchdata()
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
                
                let totalTestimonial = coachInformationTotal[kTotalTestimonial] as? Int
                if (totalTestimonial == nil) {
                    self.testimonialTitle.text = "TESTIMONIALS"
                } else {
                    self.testimonialTitle.text = "TESTIMONIALS (\(totalTestimonial!))"
                }
                
                if (coachInformation[kPostCount] is NSNull) {
                    self.postNumberContentLB.text  = "0"
                } else {
                    self.postNumberContentLB.text = String(format:"%0.f", coachInformation[kPostCount]!.doubleValue)
                    
                    totalPoint = totalPoint + (coachInformation[kPostCount]!.doubleValue * 75)
                }
                self.ratingContentLB.text = String(format:"%0.f", totalPoint)
                
                let areaText = coachInformationTotal[kServiceArea] as? String
                if (areaText != nil && areaText!.isEmpty == false) {
                    self.locationView.hidden = false
                    self.addressLB.text = areaText
                } else {
                    self.locationView.hidden = true
                }
                
                let bioText = coachInformation[kBio] as? String
                if (bioText != nil && bioText?.isEmpty == false) {
                    self.aboutTV.text = bioText
                }
                
                let sizeAboutTV = self.aboutTV.sizeThatFits(self.aboutTV.frame.size)
                self.aboutTVHeightDT.constant = sizeAboutTV.height
                if (self.aboutTV.text.isEmpty == true) {
                    self.aboutHeightDT.constant = 0;
                } else {
                    self.aboutHeightDT.constant = self.aboutTV.frame.origin.y + sizeAboutTV.height + 8
                }
                
                self.qualificationDT.constant = 0
                let qualificationText = coachInformationTotal[kQualification] as? String
                if (qualificationText != nil && qualificationText?.isEmpty == false) {
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
                self.achivementTV.text = " "
                let achivementText = coachInformationTotal[kAchievement] as? String
                if (achivementText != nil && achivementText?.isEmpty == false) {
                    self.achivementTV.text = achivementText
                    let sizeAchivementTV = self.achivementTV.sizeThatFits(self.achivementTV.frame.size)
                    self.achivementTVHeightDT.constant = sizeAchivementTV.height + 10
                    if achivementText != "" {
                        self.achivementDT.constant = self.qualificationTV.frame.origin.y + sizeAchivementTV.height
                    }
                }
                
                let websiteText = coachInformationTotal[kWebsiteUrl] as? String
                if (websiteText != nil && websiteText?.isEmpty == false) {
                    self.webTV.text = websiteText
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
        
        let bioText = coachDetail[kBio] as? String
        if (bioText != nil && bioText?.isEmpty == false) {
            self.aboutTV.text = bioText
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
    
    // MARK: - Outlet function
    @IBAction func goBackToResult() {
        self.dismissViewControllerAnimated(true) {
        }
    }
    
    @IBAction func goConnection() {
        self.performSegueWithIdentifier(kGoConnect, sender: self)
        
        if defaults.boolForKey(k_PM_IS_COACH) == true {
            if let val = self.coachDetail[kId] as? Int {
                TrackingPMAPI.sharedInstance.trackingConnectButtonCLick("\(val)")
            }
        }
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
            
            if defaults.boolForKey(k_PM_IS_COACH) == true {
                if let val = self.coachDetail[kId] as? Int {
                    TrackingPMAPI.sharedInstance.trackSocialFacebook("\(val)")
                }
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
            
            if defaults.boolForKey(k_PM_IS_COACH) == true {
                if let val = self.coachDetail[kId] as? Int {
                    TrackingPMAPI.sharedInstance.trackSocialTwitter("\(val)")
                }
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
            
            if defaults.boolForKey(k_PM_IS_COACH) == true {
                if let val = self.coachDetail[kId] as? Int {
                    TrackingPMAPI.sharedInstance.trackSocialInstagram("\(val)")
                }
            }
        }
    }
    
    @IBAction func cameraButtonClicked(sender: AnyObject) {
        let selectVideoFromLibrary = { (action:UIAlertAction!) -> Void in
            self.imagePickerController.allowsEditing = false
            self.imagePickerController.sourceType = .PhotoLibrary
            self.imagePickerController.delegate = self
            self.imagePickerController.mediaTypes = ["public.movie"]
            
            self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        }
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
//            self.imagePickerController.allowsEditing = false
//            self.imagePickerController.sourceType = .Camera
//            self.imagePickerController.delegate = self
//            self.imagePickerController.mediaTypes = ["public.movie"]
//            
//            self.presentViewController(self.imagePickerController, animated: true, completion: nil)
            
            self.performSegueWithIdentifier("showCamera", sender: nil)
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.Destructive, handler: selectVideoFromLibrary))
        alertController.addAction(UIAlertAction(title: kTakeVideo, style: UIAlertActionStyle.Destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func testimonialInviteButtonClicked(sender: AnyObject) {
        let userID = self.coachDetail[kId] as? Int
        if (userID != nil) {
            let userIDString = String(format: "%ld", userID!)
            
            let SMSAction = UIAlertAction(title: kSMS, style: .Destructive, handler: { (_) in
                if MFMessageComposeViewController.canSendText() {
                    let messageCompose = MFMessageComposeViewController()
                    messageCompose.messageComposeDelegate = self
                    
                    messageCompose.body = "Please give me a testimonial : pummel://givetestimonial/coachId=\(userIDString)"
                    
                    self.presentViewController(messageCompose, animated: true, completion: nil)
                } else {
                    PMHelper.showDoAgainAlert()
                }
            })
            
            let mailAction = UIAlertAction(title: kEmail.localizedCapitalizedString, style: .Destructive, handler: { (_) in
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    
                    mail.setSubject("Please give me a testimonial")
                    mail.setMessageBody("Please give me a testimonial : pummel://givetestimonial/coachId=\(userIDString)", isHTML: true)
                    self.presentViewController(mail, animated: true, completion: nil)
                } else {
                    PMHelper.showDoAgainAlert()
                }
            })
            
            let cancelAction = UIAlertAction(title: kCancle, style: .Cancel, handler: nil)
            
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alertViewController.addAction(SMSAction)
            alertViewController.addAction(mailAction)
            alertViewController.addAction(cancelAction)
            
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        if (self.videoPlayer != nil) {
            self.isVideoPlaying = !self.isVideoPlaying
            self.videoPlayerSetPlay(self.isVideoPlaying)
        }
    }
}

// MARK: - Video
extension ProfileViewController {
    func videoPlayerSetPlay(isPlay: Bool) {
        if (isPlay == true) {
            self.videoPlayer!.play()
            
            self.playVideoButton.setImage(nil, forState: .Normal)
            
            self.locationView.alpha = 0
        } else {
            self.videoPlayer?.pause()
            
            self.playVideoButton.setImage(UIImage(named: "icon_play_video"), forState: .Normal)
            
            self.locationView.alpha = 1
        }
        
        self.isVideoPlaying = isPlay
        // Show/Hidden item above video view
        self.avatarIMV.hidden = isPlay
        
        self.connectV.hidden = isPlay
    }
    
    func showVideoLayout(videoURLString: String) {
        // Move avatar to top left
        let newAvatarSize: CGFloat = 37.0
        let margin: CGFloat = 10.0
        let topMargin: CGFloat = 55.0
        self.avatarIMVCenterXConstraint.constant = -(self.detailV.frame.width - newAvatarSize)/2 + margin
        self.avatarIMVCenterYConstraint.constant = -(self.detailV.frame.height - newAvatarSize)/2 + topMargin
        self.avatarIMVWidthConstraint.constant = newAvatarSize
        
        self.avatarIMV.layer.cornerRadius = newAvatarSize/2
        
        // Hidden indicator view
        self.smallIndicatorView.hidden = true
        self.medIndicatorView.hidden = true
        self.bigIndicatorView.hidden = true
        self.bigBigIndicatorView.hidden = true
        
        // Show background View
        self.locationBackgroundImageView.hidden = false
        
        // Show video
        if (self.videoView == nil) {
            self.videoView = UIView.init(frame: self.detailV.bounds)
            let videoURL = NSURL(string: videoURLString)
            self.videoPlayer = AVPlayer(URL: videoURL!)
            self.videoPlayer!.actionAtItemEnd = .None
            self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
            self.videoPlayerLayer!.frame = self.videoView!.bounds
            self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.videoView!.layer.addSublayer(self.videoPlayerLayer!)
            
            //            self.videoPlayer!.currentItem!.addObserver(self, forKeyPath: "status", options: [.Old, .New], context: nil)
            
            self.detailV.insertSubview(self.videoView!, atIndex: 0)
        }
        
        // Animation
        UIView.animateWithDuration(0.5, animations: {
            self.detailV.layoutIfNeeded()
        }) { (animation) in
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
        //        let currentItem = object as! AVPlayerItem
        //        if currentItem.status == .ReadyToPlay {
        //            let videoRect = self.videoPlayerLayer?.videoRect
        //            if (videoRect?.width > videoRect?.height) {
        //                //                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        //                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        //            } else {
        //                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        //            }
        //
        ////            self.videoPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
        //
        //            self.videoPlayerSetPlay(false)
        //        }
    }
    
    func endVideoNotification(notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        
        // Show first frame video
        playerItem.seekToTime(kCMTimeZero)
        
        self.videoPlayerSetPlay(false)
    }
    
    //    func convertVideoToMP4(videoURL: NSURL, completionHandler: (exportURL:NSURL) -> Void) {
    func convertVideoToMP4AndUploadToServer(videoURL: NSURL) {
        //        self.getTempVideoPath()
        // Crop video to square
        let asset: AVAsset = AVAsset(URL: videoURL)
        
        let exportPath = self.getTempVideoPath("/library.mp4")
        
        let exportUrl: NSURL = NSURL.fileURLWithPath(exportPath)
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter!.outputFileType = AVFileTypeMPEG4
        exporter!.outputURL = exportUrl
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.timeRange =  CMTimeRangeMake(CMTimeMakeWithSeconds(0.0, 0), asset.duration)
        
        exporter?.exportAsynchronouslyWithCompletionHandler({
            let outputURL:NSURL = exporter!.outputURL!
            
            self.uploadVideo(outputURL)
        })
    }
    
    func getTempVideoPath(fileName: String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        //        let filePath = "\(documentsPath)/tempFile.mp4"
        let templatePath = documentsPath.stringByAppendingFormat(fileName)
        
        // Remove file at template path
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(templatePath)) {
            do {
                try fileManager.removeItemAtPath(templatePath)
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        }
        
        return templatePath
    }
    
    func uploadVideo(videoURL: NSURL) {
        let videoData = NSData(contentsOfURL: videoURL)
        let videoExtend = (videoURL.absoluteString!.componentsSeparatedByString(".").last?.lowercaseString)!
        let videoType = "video/" + videoExtend
        let videoName = "video." + videoExtend
        
        // Insert activity indicator
        self.isUploadingVideo = .uploading
        
        // send video by method mutipart to server
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(self.userID)
        prefix.appendContentsOf(kPM_PATH_VIDEO)
        var parameters = [String:AnyObject]()
        
        parameters = [kUserId:self.userID,
                      kProfileVideo : "1"]
        
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
                        
                        dispatch_async(dispatch_get_main_queue(),{
                            let percentWritten = (CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)) * 100
                            self.uploadingLabel.text = String(format: "Uploading %0.0f%@", percentWritten, "%")
                        })
                    }
                    upload.validate()
                    upload.responseJSON { response in
                        dispatch_async(dispatch_get_main_queue(),{
                            self.isUploadingVideo = .normal
                            
                            if (response.response?.statusCode == 200) {
                                NSNotificationCenter.defaultCenter().postNotificationName("profileGetDetail", object: nil, userInfo: nil)
                            } else {
                                let alertController = UIAlertController(title: pmmNotice, message: "Please try again", preferredStyle: .Alert)
                                let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                                alertController.addAction(OKAction)
                                self.presentViewController(alertController, animated: true) {
                                    
                                }
                            }
                        })
                    }
                    
                case .Failure( _):
                    self.isUploadingVideo = .normal
                }
        })
    }
    
    func uploadVideoWithNotification(notification: NSNotification) {
        let videoURL = notification.object as! NSURL
        
        self.convertVideoToMP4AndUploadToServer(videoURL)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let type = info[UIImagePickerControllerMediaType] as! String
        
        if (type == "public.movie") {
            // Remove current video layer
            if (self.videoView != nil && self.videoView?.layer != nil && self.videoView?.layer.sublayers != nil) {
                self.videoPlayerLayer?.removeFromSuperlayer()
                
                self.videoView = nil
            }
            
            // Dismiss video pickerview
            picker.dismissViewControllerAnimated(true, completion: nil)
            
            // send video by method mutipart to server
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            
            self.convertVideoToMP4AndUploadToServer(videoURL)
        }
    }
}

// MARK: - Mail + Message
extension ProfileViewController: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.interestCollectionView) {
            return tags.count
        } else if (collectionView == self.testimonialCollectionView) {
            if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
                if (self.testimonialArray.count > 0) {
                    self.testimonialViewHeightConstraint.constant = 324
                } else {
                    // Title: 44, Cell 280 --> 324
                    self.testimonialViewHeightConstraint.constant = 44
                }
            } else {
                self.testimonialViewHeightConstraint.constant = 0
            }
            
            
            return self.testimonialArray.count
        } else {
            return photoArray.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (collectionView == self.interestCollectionView) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTagCell, forIndexPath: indexPath) as! TagCell
            self.configureCell(cell, forIndexPath: indexPath)
            return cell
        } else if (collectionView == self.testimonialCollectionView) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTestimonialCell, forIndexPath: indexPath) as! TestimonialCell
            
            let testimonial = self.testimonialArray[indexPath.row]
            cell.setupData(testimonial)
            
            if (indexPath.row == self.testimonialArray.count - 2) {
                self.getTestimonial()
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kAboutCollectionViewCell, forIndexPath: indexPath) as! AboutCollectionViewCell
            self.configureAboutCell(cell, forIndexPath: indexPath)
            return cell
        }    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.photoArray.count - 1 && self.isStopGetListPhotos == false {
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
        } else if (collectionView == self.testimonialCollectionView) {
            // Title: 44, Cell 280
            return CGSize(width: 175, height: 280)
        } else {
            return CGSizeMake(self.aboutCollectionView.frame.size.width/2, self.aboutCollectionView.frame.size.width/2)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView == self.interestCollectionView) {
            // Do nothing
        } else if (collectionView == self.testimonialCollectionView) {
            // Do nothing
        } else {
            self.view.makeToastActivity()
            
            var prefix = kPMAPI
            prefix.appendContentsOf(kPMAPI_POSTOFPHOTO)
            let photo = self.photoArray[indexPath.row] as! NSDictionary
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
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagName.textColor = UIColor.blackColor()
        cell.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    func configureAboutCell(cell: AboutCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        let photo = self.photoArray[indexPath.row] as! NSDictionary
        let postfix = widthEqual.stringByAppendingString((self.view.frame.size.width).description).stringByAppendingString(heighEqual).stringByAppendingString((self.view.frame.size.width).description)
        
        if (photo[kImageUrl] is NSNull == false) {
            let imageURLString = photo.objectForKey(kImageUrl) as! String
            
            ImageRouter.getImage(imageURLString: imageURLString, sizeString: postfix, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    cell.imageCell.image = imageRes
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if defaults.boolForKey(k_PM_IS_COACH) == true {
            if let val = self.coachDetail[kId] as? Int {
                TrackingPMAPI.sharedInstance.trackSocialWeb("\(val)")
            }
        }
        return true
    }
}
