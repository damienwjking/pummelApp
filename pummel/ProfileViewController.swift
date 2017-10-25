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
import AVFoundation

enum VideoStatus: Int {
    case normal
    case uploading
    case playing // TODO
}

enum ProfileStyle: Int {
    case currentUser
    case otherUser
}

class ProfileViewController:  BaseViewController, UITextViewDelegate {
    @IBOutlet weak var avatarIMVCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var detailV: UIView!
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var smallIndicatorView: UIView!
    @IBOutlet weak var medIndicatorView: UIView!
    @IBOutlet weak var bigIndicatorView: UIView!
    @IBOutlet weak var bigBigIndicatorView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var uploadingLabel: UILabel!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var addressIconIMV: UIImageView!
    @IBOutlet weak var addressLB: UILabel!
    @IBOutlet weak var businessIMV: UIImageView!
    
    @IBOutlet weak var connectView : UIView!
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var connectionLB: UILabel!
    @IBOutlet weak var ratingContentLB: UILabel!
    @IBOutlet weak var connectionContentLB: UILabel!
    @IBOutlet weak var postNumberContentLB: UILabel!
    
    @IBOutlet weak var specialitiesView: UIView!
    @IBOutlet weak var specialitiesCollectionView: UICollectionView!
    @IBOutlet weak var specialitiesFlowLayout: FlowLayout!
    @IBOutlet weak var specifiesCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var specifiesViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var specifiesCollectionViewTraillingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var aboutV: UIView!
    @IBOutlet weak var aboutLB: UILabel!
    @IBOutlet weak var aboutTV: UITextView!
    @IBOutlet weak var aboutFlowLayout: FlowLayout!
    @IBOutlet weak var aboutHeightDT: NSLayoutConstraint!
    @IBOutlet weak var aboutTVHeightDT: NSLayoutConstraint!
    
    @IBOutlet weak var testimonialView: UIView!
    @IBOutlet weak var testimonialTitle: UILabel!
    @IBOutlet weak var testimonialInviteButton: UIButton!
    @IBOutlet weak var testimonialCollectionView: UICollectionView!
    @IBOutlet weak var testimonialViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var webV: UIView!
    @IBOutlet weak var webTV: UITextView!
    @IBOutlet weak var webHeightDT: NSLayoutConstraint!
    @IBOutlet weak var webTVHeightDT: NSLayoutConstraint!
    
    @IBOutlet weak var qualificationV: UIView!
    @IBOutlet weak var qualificationTV: UITextView!
    @IBOutlet weak var qualificationDT: NSLayoutConstraint!
    @IBOutlet weak var qualificationTVHeightDT: NSLayoutConstraint!
    
    @IBOutlet weak var achivementV: UIView!
    @IBOutlet weak var achivementTV: UITextView!
    @IBOutlet weak var achivementDT: NSLayoutConstraint!
    @IBOutlet weak var achivementTVHeightDT: NSLayoutConstraint!
    
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var postViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postCollectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var socialLabel: UILabel!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var twiterView: UIView!
    @IBOutlet weak var twiterButton: UIButton!
    
    @IBOutlet weak var socalDT: NSLayoutConstraint!
    @IBOutlet weak var socalBTDT: NSLayoutConstraint!
    @IBOutlet weak var facebookDT: NSLayoutConstraint!
    @IBOutlet weak var twiterDT: NSLayoutConstraint!
    @IBOutlet weak var instagramDT: NSLayoutConstraint!
    
    @IBOutlet weak var bookAndBuyView: UIView!
    @IBOutlet weak var bookAndBuyButton: UIButton!
    @IBOutlet weak var bookAndBuyViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationBackgroundImageView: UIImageView!
    
    var coachDetail: NSDictionary!
    var userID = PMHelper.getCurrentID()
    var isCoach = UserDefaults.standard.bool(forKey: k_PM_IS_COACH)
    var profileStyle: ProfileStyle = .currentUser
    
    let userDefaults = UserDefaults.standard
    
    var instagramLink: String? = ""
    var twitterLink: String? = ""
    var facebookLink: String? = ""
    
    var tags = [TagModel]()
    var photoArray: NSMutableArray = []
    var testimonialArray = [TestimonialModel]()
    var offset: Int = 0
    var testimonialOffset = 0
    
    var sizingCell: TagCell?
    
    var isConnected = false
    var isFromChat = false
    var isFromFeed = false
    var isStopGetTestimonial = false
    var isStopGetListPhotos = false
    
    let imagePickerController = UIImagePickerController()
    
    var videoView: UIView? = nil
    var videoPlayer: AVPlayer? = nil
    var videoPlayerLayer: AVPlayerLayer? = nil
    var isShowVideo: Bool = true
    let videoIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var isVideoPlaying = false
    var isUploadingVideo: VideoStatus = .normal {
        didSet {
            if (self.cameraButton != nil && self.uploadingLabel != nil) {
                DispatchQueue.main.async(execute: {
                    if (self.isUploadingVideo == .normal) {
                        self.cameraButton.isHidden = false
                        self.uploadingLabel.isHidden = true
                        
                        // Remove for next time upload
                        self.uploadingLabel.text = ""
                    } else {
                        self.cameraButton.isHidden = true
                        self.uploadingLabel.isHidden = false
                    }
                })
            }
        }
    }
    
    // MARK: - View life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
        self.setupCollectionView()
        
        // Add notification for update video url
        NotificationCenter.default.addObserver(self, selector: #selector(self.profileGetNewDetail), name: NSNotification.Name(rawValue: "PROFILE_GET_DETAIL"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadVideoWithNotification), name: NSNotification.Name(rawValue: "PROFILE_UPLOAD_VIDEO"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.afterFirstLogin), name: NSNotification.Name(rawValue: "AFTER_FIRST_LOGIN"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.title = kNavProfile
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
//        self.navigationController!.navigationBar.isTranslucent = false;
        let selectedImage = UIImage(named: "profilePressed")
        self.tabBarItem.selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        
        self.setupUIForProfileStyle()
        
        self.getDetail()
        self.getConnectStatus()
        
        self.playVideoButton.setImage(nil, for: .normal)
        
        if (self.isCoach == true) {
            self.cameraButton.alpha = 1
            self.cameraButton.isUserInteractionEnabled = true
            self.avatarIMV.layer.borderWidth = 3
        } else {
            self.cameraButton.alpha = 0
            self.cameraButton.isUserInteractionEnabled = false
            self.avatarIMV.layer.borderWidth = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.isStopGetTestimonial = false
        self.testimonialOffset = 0
        self.testimonialArray.removeAll()
        self.getTestimonial()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // pause video and move time to 0
        if (self.videoView != nil && self.videoView?.layer != nil && self.videoView?.layer.sublayers != nil) {
            self.videoPlayerSetPlay(isPlay: false)
            
            // Remove video view
            self.videoPlayer?.currentItem?.seek(to: kCMTimeZero)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        if (self.profileStyle == .currentUser) {
            return false
        } else {
            return true // Hide status bar
        }
    }
    
    func afterFirstLogin() {
        if (self.profileStyle == .currentUser) {
            self.isCoach = self.userDefaults.bool(forKey: k_PM_IS_COACH)
        }
    }
    
    func setupUI() {
        self.bigBigIndicatorView.layer.cornerRadius = 374/2
        self.bigIndicatorView.layer.cornerRadius = 312/2
        self.medIndicatorView.layer.cornerRadius = 240/2
        self.smallIndicatorView.layer.cornerRadius = 180/2
        
        self.locationView.layer.cornerRadius = 2
        self.locationView.layer.masksToBounds = true
        
        self.connectionLB.text = self.isCoach ? "RATING" : "SESSIONS"
        
        self.connectButton.layer.cornerRadius = 55/2
        self.connectButton.layer.masksToBounds = true
        
        if (self.profileStyle == .otherUser && self.isCoach == false) {
            self.connectView.alpha = 0
        } else {
            self.connectView.alpha = 1
        }
        
        self.avatarIMV.layer.borderWidth = 0
        self.avatarIMV.clipsToBounds = true
        self.avatarIMV.layer.cornerRadius = 125/2
        self.avatarIMV.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
        
        self.scrollView.scrollsToTop = false
        
        self.businessIMV.isHidden = true
        self.businessIMV.clipsToBounds = true
        self.businessIMV.layer.cornerRadius = 50
        self.specifiesCollectionViewTraillingConstraint.constant = 10
        
        self.webTV.delegate = self
        
        self.postCollectionView.backgroundColor = UIColor.pmmWhiteColor()
    }
    
    func setupCollectionView() {
        // Tag collection view
        self.specialitiesFlowLayout.smaller = true
        let cellNib = UINib(nibName: kTagCell, bundle: nil)
        self.specialitiesCollectionView.register(cellNib, forCellWithReuseIdentifier: kTagCell)
        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
        
        if (CURRENT_DEVICE == .phone && SCREEN_MAX_LENGTH == 568.0) {
            self.specialitiesFlowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 8)
        } else {
            self.specialitiesFlowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        
        // Testimonial collection view
        let testimonialXib = UINib(nibName: kTestimonialCell, bundle: nil)
        self.testimonialCollectionView.register(testimonialXib, forCellWithReuseIdentifier: kTestimonialCell)
    }
    
    func setupUIForProfileStyle() {
        self.testimonialInviteButton.isHidden = true
        self.bookAndBuyButton.isHidden = true
        self.bookAndBuyViewHeightConstraint.constant = 0
        
        if (self.profileStyle == .currentUser) {
            self.backButton.isHidden = true
            self.userNameLabel.isHidden = true
            
            self.cameraButton.isHidden = false
            
            if (self.isCoach == true) {
                self.testimonialInviteButton.isHidden = false
            }
            
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"SETTINGS", style:.plain, target: self, action: #selector(self.setting))
            self.tabBarController?.navigationItem.rightBarButtonItem?.setAttributeForAllStage()
        } else if (self.profileStyle == .otherUser) {
            self.backButton.isHidden = false
            self.userNameLabel.isHidden = false
            
            self.cameraButton.isHidden = true
            
            if (self.isCoach == true) {
                self.bookAndBuyButton.isHidden = false
                self.bookAndBuyViewHeightConstraint.constant = 70
            }
        }
    }
    
    func profileGetNewDetail() {
        if (self.videoView != nil && self.videoView?.layer != nil && self.videoView?.layer.sublayers != nil) {
            self.videoPlayerLayer?.removeFromSuperlayer()
            
            self.videoView = nil
            
            self.getDetail()
        }
    }
    
    func setting() {
        performSegue(withIdentifier: "goSetting", sender: nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Go Setting"]
        mixpanel?.track("IOS.Profile", properties: properties)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goEdit") {
            let destinationVC = segue.destination as! EditProfileViewController
            destinationVC.userInfo = self.coachDetail
        } else if (segue.identifier == "goEdit") {
            let destinationVC = segue.destination as! EditCoachProfileViewController
            destinationVC.userInfo = self.coachDetail
        } else if segue.identifier == "goSetting" {
            let destinationVC = segue.destination as! SettingsViewController
            destinationVC.userInfo = self.coachDetail
        }  else if segue.identifier == "goToFeedDetail" {
            let navc = segue.destination as! UINavigationController
            let destination = navc.topViewController as! FeedViewController
            destination.fromPhoto = true
            if let feed = sender as? FeedModel {
                destination.feedDetail = feed
            }
        } else if segue.identifier == "showCamera" {
            let destination = segue.destination as! CameraViewController
            
            destination.videoURL = sender as? NSURL
        } else if (segue.identifier == kGoConnect) {
            let destimation = segue.destination as! ConnectViewController
            destimation.coachDetail = self.coachDetail
            destimation.isFromProfile = true
            destimation.isFromFeed = self.isFromFeed
            destimation.isConnected = self.isConnected
        }
    }
    
    func getDetail() {
        self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = false
        
        var prefix = kPMAPIUSER
        prefix.append(self.userID)
        
        UserRouter.getUserInfo(userID: self.userID) { (result, error) in
            self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = true
            
            if (error == nil) {
                self.coachDetail = result as! NSDictionary
                
                let firstName = self.coachDetail[kFirstname] as? String
                self.userNameLabel.text = firstName?.uppercased()
                
                if (self.profileStyle == .currentUser) {
                    self.userDefaults.set(self.coachDetail["newleadNotification"] as! Int == 0 ? false : true, forKey: kNewConnections)
                    self.userDefaults.set(self.coachDetail["messageNotification"] as! Int == 0 ? false : true, forKey: kMessage)
                    self.userDefaults.set(self.coachDetail["sessionNotification"] as! Int == 0 ? false : true, forKey: kSessions)
                    self.userDefaults.set(self.coachDetail[kUnits], forKey: kUnit)
                    self.userDefaults.set(firstName, forKey: kFirstname)
                    self.userDefaults.synchronize()
                }
                
                if let val = self.coachDetail[kId] as? Int {
                    TrackingPMAPI.sharedInstance.trackingProfileViewed(coachId: "\(val)")
                }
                
                self.setAvatar()
                if (self.isCoach == true) {
                    self.getBusinessImage()
                    self.getListTag()
                    self.updateUI()
                } else {
                    self.updateUIUser()
                }
                
                self.getListImage()
                
                // check Video URL
                let videoURL = self.coachDetail[kVideoURL] as? String
                if (videoURL?.isEmpty == false && self.isShowVideo == true) {
                    self.showVideoLayout(videoURLString: videoURL!)
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    func setAvatar() {
        if (coachDetail[kImageUrl] is NSNull == false) {
            let imageLink = coachDetail[kImageUrl] as! String
            
            ImageVideoRouter.getImage(imageURLString: imageLink, sizeString: widthHeight250, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.avatarIMV.image = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
    
    func getBusinessImage() {
        if (coachDetail[kBusinessId] is NSNull == false) {
            let businessId = String(format:"%0.f", (coachDetail[kBusinessId]! as AnyObject).doubleValue)
            
            ImageVideoRouter.getBusinessLogo(businessID: businessId, sizeString: widthHeight120, completed: { (result, error) in
                if (error == nil) {
                    self.businessIMV.isHidden = false
                    let imageRes = result as! UIImage
                    self.businessIMV.image = imageRes
                    self.specifiesCollectionViewTraillingConstraint.constant = 120
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
    
    func getListTag() {
        if (coachDetail[kTags] == nil) {
            UserRouter.getUserTagList(userID: self.userID, completed: { (result, error) in
                if (error == nil) {
                    self.tags = result as! [TagModel]
                    
                    self.reloadLayout()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        } else {
            let coachListTags = coachDetail[kTags] as! NSArray
            self.tags.removeAll()
            for i in 0 ..< coachListTags.count {
                let tagContent = coachListTags[i] as! NSDictionary
                let tag = TagModel()
                tag.tagTitle = tagContent[kTitle] as? String
                self.tags.append(tag)
            }
            
            self.reloadLayout()
        }
    }
    
    func getListImage() {
        if (self.isStopGetListPhotos == false) {
            UserRouter.getPhotoList(userID: self.userID, offset: self.offset, completed: { (result, error) in
                
                if (error == nil) {
                    if let arrayphoto = result as? NSArray {
                        if (arrayphoto.count == 0) {
                            self.isStopGetListPhotos = true
                        } else {
                            self.offset += 10
                            self.photoArray.addObjects(from: arrayphoto as [AnyObject])
                            self.getListImage()
                        }
                        
                        self.reloadLayout()
                    }
                } else {
                    self.isStopGetListPhotos = true
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
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
                        
                        testimo.parseData(data: testimonialDict as! NSDictionary)
                        
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
                    print("Request failed with error: \(String(describing: error))")
                }
                }.fetchdata()
        }
    }
    
    func updateUI() {
        var prefix = kPMAPICOACH
        prefix.append(self.userID)
        self.view.makeToastActivity(message: "Loading")
        
        UserRouter.getCoachInfo(userID: self.userID) { (result, error) in
            self.view.hideToastActivity()
            
            if (error == nil) {
                let coachInformationTotal = result as! NSDictionary
                let coachInformation = coachInformationTotal[kUser] as! NSDictionary
                
                let totalTestimonial = coachInformationTotal[kTotalTestimonial] as? Int
                if (totalTestimonial == nil) {
                    self.testimonialTitle.text = "TESTIMONIALS"
                } else {
                    self.testimonialTitle.text = "TESTIMONIALS (\(totalTestimonial!))"
                }
                
                var totalPoint = 0.0
                if (self.isCoach == true) {
                    self.connectionContentLB.text = "100%"
                } else {
                    if (coachInformation[kConnectionCount] is NSNull) {
                        self.connectionContentLB.text = "0"
                    } else {
                        self.connectionContentLB.text = String(format:"%0.f", (coachInformation[kConnectionCount]! as AnyObject).doubleValue)
                        
                        totalPoint = totalPoint + ((coachInformation[kConnectionCount]! as AnyObject).doubleValue * 120)
                    }
                }
                
                if (coachInformation[kPostCount] is NSNull) {
                    self.postNumberContentLB.text  = "0"
                } else {
                    self.postNumberContentLB.text = String(format:"%0.f", (coachInformation[kPostCount]! as AnyObject).doubleValue)
                    
                    totalPoint = totalPoint + ((coachInformation[kPostCount]! as AnyObject).doubleValue * 75)
                }
                self.ratingContentLB.text = String(format:"%0.f", totalPoint)
                
                let areaText = coachInformationTotal[kServiceArea] as? String
                if (areaText != nil && areaText!.isEmpty == false) {
                    self.locationView.isHidden = false
                    self.addressLB.text = areaText
                } else {
                    self.locationView.isHidden = true
                }
                
                let bioText = coachInformation[kBio] as? String
                if (bioText != nil && bioText?.isEmpty == false) {
                    self.aboutTV.text = coachInformation[kBio] as! String
                    
                    let sizeAboutTV = self.aboutTV.sizeThatFits(self.aboutTV.frame.size)
                    self.aboutTVHeightDT.constant = sizeAboutTV.height
                    self.aboutHeightDT.constant = self.aboutTV.frame.origin.y + sizeAboutTV.height + 8
                } else {
                    self.aboutTVHeightDT.constant = 0
                    self.aboutHeightDT.constant = 0
                }
                
                self.qualificationDT.constant = 0
                let qualificationText = coachInformationTotal[kQualification] as? String
                if (qualificationText != nil && qualificationText?.isEmpty == false) {
                    self.qualificationTV.text = qualificationText
                    let sizeQualificationTV = self.qualificationTV.sizeThatFits(self.qualificationTV.frame.size)
                    self.qualificationTVHeightDT.constant = sizeQualificationTV.height + 10
                    self.qualificationDT.constant = self.qualificationTV.frame.origin.y + sizeQualificationTV.height
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
                    self.achivementDT.constant = self.qualificationTV.frame.origin.y + sizeAchivementTV.height
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
                
                self.setupSocialView(userInfo: coachInformation)
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    func updateUIUser() {
        self.addressIconIMV.isHidden = true
        self.addressLB.isHidden = true
        
        var totalPoint = 0.0
        if (self.coachDetail[kConnectionCount] is NSNull) {
            self.connectionContentLB.text = "0"
        } else {
            self.connectionContentLB.text = String(format:"%0.f", (self.coachDetail[kConnectionCount]! as AnyObject).doubleValue)
            
            totalPoint = totalPoint + ((self.coachDetail[kConnectionCount]! as AnyObject).doubleValue * 120)
        }
        
        if (self.coachDetail[kPostCount] is NSNull) {
            self.postNumberContentLB.text  = "0"
        } else {
            self.postNumberContentLB.text = String(format:"%0.f", (self.coachDetail[kPostCount]! as AnyObject).doubleValue)
            
            totalPoint = totalPoint + ((self.coachDetail[kPostCount]! as AnyObject).doubleValue * 75)
        }
        self.ratingContentLB.text = String(format:"%0.f", totalPoint)
        
        let bioText = self.coachDetail[kBio] as? String
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
        
        self.setupSocialView(userInfo: self.coachDetail)
    }
    
    func setupSocialView(userInfo: NSDictionary) {
        if (userInfo[kInstagramUrl] is NSNull == false) {
            self.instagramLink = userInfo[kInstagramUrl] as? String
        }
        
        if (userInfo[kFacebookUrl] is NSNull == false) {
            self.facebookLink = userInfo[kFacebookUrl] as? String
        }
        
        if (userInfo[kTwitterUrl] is NSNull == false) {
            self.twitterLink = userInfo[kTwitterUrl] as? String
        }
        
        self.socalDT.constant = 94
        self.socalBTDT.constant = 50
        self.socialLabel.text = "SOCIAL"
        if (self.instagramLink == "") {
            if (self.facebookLink == "") {
                if (self.twitterLink == "") {
                    self.facebookDT.constant = 0
                    self.twiterDT.constant = 0
                    self.instagramDT.constant = 0
                    self.socalBTDT.constant = 0
                    self.socalDT.constant = 0
                    self.socialLabel.text = ""
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
    
    func getConnectStatus() {
        if (self.profileStyle == .currentUser) {
            self.connectButton.setImage(UIImage(named: "edit"), for: .normal)
            self.connectButton.backgroundColor = UIColor.pmmBrightOrangeColor()
            
            self.connectButton.addTarget(self, action: #selector(self.editButtonClicked), for: .touchUpInside)
        } else if (self.profileStyle == .otherUser) {
            self.connectButton.setImage(UIImage(named: "connect"), for: .normal)
            self.connectButton.backgroundColor = UIColor.pmmBrightOrangeColor()
            
            self.connectButton.addTarget(self, action: #selector(self.connectButtonClicked), for: .touchUpInside)
            
            self.connectButton.isUserInteractionEnabled = false
            
            let coachID = self.coachDetail[kId] as! Int
            let coachIDString = String(format:"%ld", coachID)
            UserRouter.checkConnect(coachID: coachIDString, completed: { (result, error) in
                self.connectButton.isUserInteractionEnabled = true
                
                let resultString = result as? String
                
                if (resultString?.isEmpty == false) {
                    if (resultString == "Connected") {
                        self.connectButton.setImage(UIImage(named: "mail"), for: .normal)
                        self.connectButton.backgroundColor = UIColor.pmmLightSkyBlueColor()
                        self.isConnected = true
                        
                        if self.isFromChat {
                            self.connectButton.isUserInteractionEnabled = false
                        }
                    }
                }
            }).fetchdata()
        }
    }
    
    func reloadLayout() {
        // Specialities list
        self.specialitiesCollectionView.reloadData(completion: {
            if (self.tags.count == 0) {
                self.specifiesViewHeightConstraint.constant = 0
            } else {
                let heightCollectionView = self.specialitiesCollectionView.collectionViewLayout.collectionViewContentSize.height
                
                self.specifiesCollectionViewHeightConstraint.constant = heightCollectionView < 78 ? 78 : heightCollectionView
                
                self.specifiesViewHeightConstraint.constant = ((heightCollectionView + 50) < 128) ? 128 : (heightCollectionView + 50)
            }
        })
        
        // Photo list
        self.postCollectionView.reloadData(completion: {
            if (self.photoArray.count == 0) {
                self.postViewHeightConstraint.constant = 0
            } else {
                self.postCollectionViewHeightConstraint.constant = self.postCollectionView.collectionViewLayout.collectionViewContentSize.height
                
                self.postViewHeightConstraint.constant = self.postCollectionViewHeightConstraint.constant + 50
            }
        })
    }
    
    // MARK: - Outlet function
    @IBAction func editButtonClicked() {
        if (self.isCoach != true) {
            performSegue(withIdentifier: "goEdit", sender: nil)
        } else {
            performSegue(withIdentifier: "goEditCoach", sender: nil)
        }
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Go Edit Profile"]
        mixpanel?.track("IOS.Profile", properties: properties)
    }
    
    @IBAction func connectButtonClicked() {
        if self.coachDetail != nil {
            if let firstName = self.coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Send Message", "Label":"\(firstName.uppercased())"]
                mixpanel?.track("IOS.SendMessageToCoach", properties: properties)
                let coachID = self.coachDetail[kId] as! Int
                let coachIDString = String(format:"%ld", coachID)
                
                self.view.makeToastActivity(message: "Connecting")
                UserRouter.setLead(coachID: coachIDString, completed: { (result, error) in
                    self.view.hideToastActivity()
                    
                    let isConnectSuccess = result as! Bool
                    if (isConnectSuccess == true) {
                        if let val = self.coachDetail[kId] as? Int {
                            TrackingPMAPI.sharedInstance.trackingConnectButtonCLick(coachId: "\(val)")
                        }
                    }
                    
                    self.performSegue(withIdentifier: kGoConnect, sender: self)
                }).fetchdata()
            }
        }
    }
    
    @IBAction func backButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickOnFacebook() {
        if (self.facebookLink != "") {
            let facebookUrl = NSURL(string: self.facebookLink!)
            
            if UIApplication.shared.canOpenURL(facebookUrl! as URL){
                UIApplication.shared.openURL(facebookUrl! as URL)
                
            } else {
                //redirect to safari because the user doesn't have Instagram
                UIApplication.shared.openURL(NSURL(string: "http://facebook.com/")! as URL)
            }
            
            // Tracker mixpanel
            if let firstName = coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Facebook", "Label":"\(firstName.uppercased())"]
                mixpanel?.track("IOS.SocialClick", properties: properties)
            }
            
            if (self.isCoach == true) {
                if let val = self.coachDetail[kId] as? Int {
                    TrackingPMAPI.sharedInstance.trackSocialFacebook(coachId: "\(val)")
                }
            }
        }
    }
    
    @IBAction func clickOnTwitter() {
        if (self.twitterLink != "") {
            let twitterUrl = NSURL(string: self.twitterLink!)
            
            if UIApplication.shared.canOpenURL(twitterUrl! as URL) {
                UIApplication.shared.openURL(twitterUrl! as URL)
                
            } else {
                //redirect to safari because the user doesn't have Instagram
                UIApplication.shared.openURL(NSURL(string: "http://twitter.com/")! as URL)
            }
            
            // Tracker mixpanel
            if let firstName = coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Twitter", "Label":"\(firstName.uppercased())"]
                mixpanel?.track("IOS.SocialClick", properties: properties)
            }
            
            if (self.isCoach == true) {
                if let val = self.coachDetail[kId] as? Int {
                    TrackingPMAPI.sharedInstance.trackSocialTwitter(coachId: "\(val)")
                }
            }
        }
    }
    
    @IBAction func clickOnInstagram() {
        if (self.instagramLink  != "") {
            let instagramUrl = NSURL(string: self.instagramLink!)
           
            if UIApplication.shared.canOpenURL(instagramUrl! as URL)
            {
                UIApplication.shared.openURL(instagramUrl! as URL)
                
            } else {
                //redirect to safari because the user doesn't have Instagram
                UIApplication.shared.openURL(NSURL(string: "http://instagram.com/")! as URL)
            }
            
            // Tracker mixpanel
            if let firstName = coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Instagram", "Label":"\(firstName.uppercased())"]
                mixpanel?.track("IOS.SocialClick", properties: properties)
            }
            
            if (self.isCoach == true) {
                if let val = self.coachDetail[kId] as? Int {
                    TrackingPMAPI.sharedInstance.trackSocialInstagram(coachId: "\(val)")
                }
            }
        }
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        let selectVideoFromLibrary = { (action:UIAlertAction!) -> Void in
            self.imagePickerController.allowsEditing = false
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.delegate = self
            self.imagePickerController.mediaTypes = ["public.movie"]
            
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
//            self.imagePickerController.allowsEditing = false
//            self.imagePickerController.sourceType = .Camera
//            self.imagePickerController.delegate = self
//            self.imagePickerController.mediaTypes = ["public.movie"]
//            
//            self.present(self.imagePickerController, animated: true, completion: nil)
            
            self.performSegue(withIdentifier: "showCamera", sender: nil)
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.destructive, handler: selectVideoFromLibrary))
        alertController.addAction(UIAlertAction(title: kTakeVideo, style: UIAlertActionStyle.destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func testimonialInviteButtonClicked(_ sender: Any) {
        let userID = self.coachDetail[kId] as? Int
        if (userID != nil) {
            let userIDString = String(format: "%ld", userID!)
            
            let SMSAction = UIAlertAction(title: kSMS, style: .destructive, handler: { (_) in
                if MFMessageComposeViewController.canSendText() {
                    let messageCompose = MFMessageComposeViewController()
                    messageCompose.messageComposeDelegate = self
                    
                    messageCompose.body = "Please give me a testimonial : pummel://givetestimonial/coachId=\(userIDString)"
                    
                    self.present(messageCompose, animated: true, completion: nil)
                } else {
                    PMHelper.showDoAgainAlert()
                }
            })
            
            let mailAction = UIAlertAction(title: kEmail.capitalized, style: .destructive, handler: { (_) in
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    
                    mail.setSubject("Please give me a testimonial")
                    mail.setMessageBody("Please give me a testimonial : pummel://givetestimonial/coachId=\(userIDString)", isHTML: true)
                    self.present(mail, animated: true, completion: nil)
                } else {
                    PMHelper.showDoAgainAlert()
                }
            })
            
            let cancelAction = UIAlertAction(title: kCancle, style: .cancel, handler: nil)
            
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertViewController.addAction(SMSAction)
            alertViewController.addAction(mailAction)
            alertViewController.addAction(cancelAction)
            
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Video
extension ProfileViewController {
    func videoPlayerSetPlay(isPlay: Bool) {
        if (isPlay == true) {
            self.videoPlayer!.play()
            
            self.playVideoButton.setImage(nil, for: .normal)
            
            self.locationView.alpha = 0
        } else {
            self.videoPlayer?.pause()
            
            self.playVideoButton.setImage(UIImage(named: "icon_play_video"), for: .normal)
            
            self.locationView.alpha = 1
        }
        
        self.isVideoPlaying = isPlay
        // Show/Hidden item above video view
        self.avatarIMV.isHidden = isPlay
        self.connectView.isHidden = isPlay
    }
    
    func showVideoLayout(videoURLString: String) {
        // Move avatar to top left
        let newAvatarSize: CGFloat = 37.0
        let margin: CGFloat = 15.0
        var topMargin: CGFloat = 15.0
        if (self.profileStyle == .otherUser) {
            topMargin = 55.0
        }
        
        self.avatarIMVCenterXConstraint.constant = -(self.detailV.frame.width - newAvatarSize)/2 + margin
        self.avatarIMVCenterYConstraint.constant = -(self.detailV.frame.height - newAvatarSize)/2 + topMargin
        self.avatarIMVWidthConstraint.constant = newAvatarSize
        
        self.avatarIMV.layer.cornerRadius = newAvatarSize/2
        
        // Hidden indicator view
        self.smallIndicatorView.isHidden = true
        self.medIndicatorView.isHidden = true
        self.bigIndicatorView.isHidden = true
        self.bigBigIndicatorView.isHidden = true
        
        // Show background View
        self.locationBackgroundImageView.isHidden = false
        
        // Show video
        if (self.videoView == nil) {
            self.videoView = UIView.init(frame: self.detailV.bounds)
            let videoURL = URL(string: videoURLString)
            self.videoPlayer = AVPlayer(url: videoURL! as URL)
            self.videoPlayer!.actionAtItemEnd = .none
            self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
            self.videoPlayerLayer!.frame = self.videoView!.bounds
            self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.videoView!.layer.addSublayer(self.videoPlayerLayer!)
            
            self.detailV.insertSubview(self.videoView!, at: 0)
        }
        
        // Animation
        UIView.animate(withDuration: 0.5, animations: {
            self.detailV.layoutIfNeeded()
        }) { (animation) in
            self.videoPlayerSetPlay(isPlay: false)
        }
        
        // Add indicator for video
        if (self.videoIndicator.superview != nil) {
            self.videoIndicator.removeFromSuperview()
        }
        self.videoIndicator.startAnimating()
        self.videoIndicator.center = CGPoint(x: self.detailV.frame.width/2, y: self.detailV.frame.height/2)
        self.detailV.insertSubview(self.videoIndicator, at: 0)
        
        // Remove loop play video for
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        // Add notification for loop play video
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(self.endVideoNotification),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                         object: self.videoPlayer!.currentItem)
    }
    
    func endVideoNotification(notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        
        // Show first frame video
        playerItem.seek(to: kCMTimeZero)
        
        self.videoPlayerSetPlay(isPlay: false)
    }
    
    //    func convertVideoToMP4(videoURL: NSURL, completionHandler: (exportURL:NSURL) -> Void) {
    func convertVideoToMP4AndUploadToServer(videoURL: URL) {
        //        self.getTempVideoPath()
        // Crop video to square
        let asset: AVAsset = AVAsset(url: videoURL)
        
        let exportPath = self.getTempVideoPath(fileName: "/library.mp4")
        
        let exportUrl: URL = NSURL.fileURL(withPath: exportPath) as URL
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter!.outputFileType = AVFileTypeMPEG4
        exporter!.outputURL = exportUrl as URL
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.timeRange =  CMTimeRangeMake(CMTimeMakeWithSeconds(0.0, 0), asset.duration)
        
        exporter?.exportAsynchronously(completionHandler: {
            let outputURL:NSURL = exporter!.outputURL! as NSURL
            
            self.uploadVideo(videoURL: outputURL as URL)
        })
    }
    
    func getTempVideoPath(fileName: String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        //        let filePath = "\(documentsPath)/tempFile.mp4"
        let templatePath = documentsPath.appendingFormat(fileName)
        
        // Remove file at template path
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: templatePath)) {
            do {
                try fileManager.removeItem(atPath: templatePath)
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        }
        
        return templatePath
    }
    
    func uploadVideo(videoURL: URL) {
        do {
            let videoData = try Data(contentsOf: videoURL)
            
            // Insert activity indicator
            self.isUploadingVideo = .uploading
            
            // send video by method mutipart to server
            ImageVideoRouter.uploadVideo(videoData: videoData) { (result, error) in
                if (error == nil) {
                    let percent = result as! Double
                    
                    if (percent < 100.0) {
                        self.uploadingLabel.text = String(format: "Uploading %0.0f%@", percent, "%")
                    } else {
                        self.isUploadingVideo = .normal
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PROFILE_GET_DETAIL"), object: nil, userInfo: nil)
                    }
                    
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.isUploadingVideo = .normal
                    
                    PMHelper.showDoAgainAlert()
                }
                }.fetchdata()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func uploadVideoWithNotification(notification: NSNotification) {
        let videoURL = notification.object as! NSURL
        
        self.convertVideoToMP4AndUploadToServer(videoURL: videoURL as URL)
    }
    
    @IBAction func playVideoButtonClicked(_ sender: Any) {
        if (self.videoPlayer != nil) {
            self.isVideoPlaying = !self.isVideoPlaying
            self.videoPlayerSetPlay(isPlay: self.isVideoPlaying)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type = info[UIImagePickerControllerMediaType] as! String
        
        if (type == "public.movie") {
            // Remove current video layer
            if (self.videoView != nil && self.videoView?.layer != nil && self.videoView?.layer.sublayers != nil) {
                self.videoPlayerLayer?.removeFromSuperlayer()
                
                self.videoView = nil
            }
            
            // Dismiss video pickerview
            picker.dismiss(animated: true, completion: nil)
            
            // send video by method mutipart to server
            let videoURL = info[UIImagePickerControllerMediaURL] as! URL
            
            self.convertVideoToMP4AndUploadToServer(videoURL: videoURL)
        }
    }
}

// MARK: - Mail + Message
extension ProfileViewController: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.specialitiesCollectionView) {
            return tags.count
        } else if (collectionView == self.testimonialCollectionView) {
            self.testimonialViewHeightConstraint.constant = 0
            
            if (self.isCoach == true) {
                if (self.testimonialArray.count > 0) {
                    self.testimonialViewHeightConstraint.constant = 324
                } else {
                    if (self.profileStyle == .currentUser) {
                        self.testimonialViewHeightConstraint.constant = 44
                    }
                }
            }
            
            return self.testimonialArray.count
        } else {
            return photoArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.specialitiesCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kTagCell, for: indexPath) as! TagCell
            
            let tag = self.tags[indexPath.row]
            cell.setupData(tag: tag)
            
            return cell
        } else if (collectionView == self.testimonialCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kTestimonialCell, for: indexPath) as! TestimonialCell
            
            let testimonial = self.testimonialArray[indexPath.row]
            cell.setupData(testimonial: testimonial)
            
            if (indexPath.row == self.testimonialArray.count - 2) {
                self.getTestimonial()
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAboutCollectionViewCell, for: indexPath) as! AboutCollectionViewCell
            
            let photoDictionary = self.photoArray[indexPath.row] as! NSDictionary
            cell.setupData(photoDictionary: photoDictionary)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.photoArray.count - 1 {
            self.getListImage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == self.specialitiesCollectionView) {
            self.sizingCell?.setupData(tag: self.tags[indexPath.row])
            
            var cellSize = self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            
            if (CURRENT_DEVICE == .phone && SCREEN_MAX_LENGTH == 568.0) {
                cellSize.width += 5;
            }
            
            return cellSize
        } else if (collectionView == self.testimonialCollectionView) {
            // Title: 44, Cell 280
            return CGSize(width: 175, height: 280)
        } else if (collectionView == self.postCollectionView) {
            return CGSize(width: self.postCollectionView.frame.size.width/2, height: self.postCollectionView.frame.size.width/2)
        }
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.specialitiesCollectionView) {
            // Do nothing
        } else if (collectionView == self.testimonialCollectionView) {
            // Do nothing
        } else {
            let photo = self.photoArray[indexPath.row] as! NSDictionary
            let photoID = photo["uploadId"] as! Int
            let photoIDString = String(format:"%ld", photoID)
            
            self.view.makeToastActivity()
            FeedRouter.getPhotoPost(photoID: photoIDString, completed: { (result, error) in
                self.view.hideToastActivity()
                
                let alertController = UIAlertController(title: pmmNotice, message: notfindPhoto, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: kOk, style: .default)
                alertController.addAction(OKAction)
                
                if (error == nil) {
                    if let arr = result as? NSArray {
                        if arr.count > 0 {
                            if let dic = arr.object(at: 0) as? NSDictionary {
                                let feed = FeedModel()
                                feed.parseData(data: dic)
                                
                                self.performSegue(withIdentifier: "goToFeedDetail", sender: feed)
                                return
                            }
                        }
                    }
                    
                    self.present(alertController, animated: true)
                    
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.present(alertController, animated: true)
                }
            }).fetchdata()
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (self.isCoach == true) {
            if let val = self.coachDetail[kId] as? Int {
                TrackingPMAPI.sharedInstance.trackSocialWeb(coachId: "\(val)")
            }
        }
        return true
    }
}
