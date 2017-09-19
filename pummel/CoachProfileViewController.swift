//
//  CoachProfileViewController.swift
//  pummel
//
//  Created by Bear Daddy on 7/1/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import Mixpanel
import AVKit
import AVFoundation


class CoachProfileViewController: BaseViewController, UITextViewDelegate {
    @IBOutlet weak var avatarIMVCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarIMVWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleCoachLB: UILabel!
    @IBOutlet weak var smallIndicatorView: UIView!
    @IBOutlet weak var medIndicatorView: UIView!
    @IBOutlet weak var bigIndicatorView: UIView!
    @IBOutlet weak var bigBigIndicatorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var coachBorderV: UIView!
    @IBOutlet weak var coachBorderBackgroundV: UIView!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var actionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var phoneBT: UIButton!
    @IBOutlet weak var connectBT : UIButton!
    @IBOutlet weak var addressLB: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationBackgroundImageView: UIImageView!
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
    @IBOutlet weak var backBT: UIButton!
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
    
    @IBOutlet weak var testimonialView: UIView!
    @IBOutlet weak var testimonialTitle: UILabel!
    @IBOutlet weak var testimonialCollectionView: UICollectionView!
    @IBOutlet weak var testimonialViewHeightConstraint: NSLayoutConstraint!
    
    var instagramLink: String? = ""
    var twitterLink: String? = ""
    var facebookLink: String? = ""
    var oldPositionAboutV: CGFloat!
    var statusBarDefault: Bool!
    var coachDetail: NSDictionary!
    var sizingCell: TagCell?
    var tags = [Tag]()
    var photoArray: NSArray = []
    var testimonialArray = [TestimonialModel]()
    var isStopGetTestimonial = false
    var testimonialOffset = 0
    var isFromFeed: Bool = false
    var isFromChat: Bool = false
    var isFromListCoaches: Bool = false
    var isConnected = false
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let SCREEN_MAX_LENGTH = max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
    
    var videoView: UIView? = nil
    var videoPlayer: AVPlayer? = nil
    var videoPlayerLayer: AVPlayerLayer? = nil
    var isShowVideo: Bool = true
    let videoIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var isVideoPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.aboutTV.backgroundColor = .clearColor()
        self.aboutTV.scrollEnabled = false
        self.qualificationTV.backgroundColor = .clearColor()
        self.qualificationTV.scrollEnabled = false
        
        self.bigBigIndicatorView.layer.cornerRadius = 374/2
        self.bigIndicatorView.layer.cornerRadius = 312/2
        self.medIndicatorView.layer.cornerRadius = 240/2
        self.smallIndicatorView.layer.cornerRadius = 180/2
        
        self.bigBigIndicatorView.clipsToBounds = true
        self.bigIndicatorView.clipsToBounds = true
        self.medIndicatorView.clipsToBounds = true
        self.smallIndicatorView.clipsToBounds = true

        self.titleCoachLB.font = .pmmMonReg13()
        self.titleCoachLB.text = (self.coachDetail[kFirstname] as! String).uppercaseString
        
        self.locationView.layer.cornerRadius = 2
        self.locationView.layer.masksToBounds = true
        
        self.connectBT.layer.cornerRadius = 55/2
        self.connectBT.clipsToBounds = true
        self.connectBT.backgroundColor = UIColor(red: 255.0 / 255.0, green: 91.0 / 255.0, blue: 16.0 / 255.0, alpha: 1.0)
        self.actionViewWidthConstraint.constant = 55;
        self.phoneBT.hidden = true
        
        self.avatarIMV.layer.cornerRadius = 125/2
        self.coachBorderV.layer.cornerRadius = 135/2
        self.coachBorderBackgroundV.layer.cornerRadius = 129/2
        self.avatarIMV.clipsToBounds = true
        self.scrollView.scrollsToTop = false
        self.interestCollectionView.delegate = self
        self.interestCollectionView.dataSource = self
        self.webTV.delegate = self
        
        let imageLink = self.coachDetail[kImageUrl] as? String
        if (imageLink?.isEmpty == false) {
            self.setCoachAvatar()
        }
        
        self.businessIMV.hidden = true
        self.aboutLeftDT.constant = 10
        self.businessIMV.layer.cornerRadius = 50
        self.businessIMV.clipsToBounds = true
        if (self.coachDetail[kBusinessId] != nil) {
            self.getBusinessImage()
        } else {
            let userID = String(format:"%0.f", self.coachDetail[kId]!.doubleValue)
            UserRouter.getUserInfo(userID: userID, completed: { (result, error) in
                if (error == nil) {
                    let jsonBusiness = result as! NSDictionary
                    if (jsonBusiness[kBusinessId] != nil) {
                        let dictionary: NSMutableDictionary = NSMutableDictionary(dictionary: self.coachDetail)
                        dictionary[kBusinessId] = jsonBusiness[kBusinessId]!.doubleValue
                        self.coachDetail = dictionary
                        self.getBusinessImage()
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }

        if (self.coachDetail[kTags] == nil) {
            self.getCoachTags()
        } else {
            let coachListTags = self.coachDetail[kTags] as! NSArray
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
        getListImage()
        self.updateUI()
        self.setupViewForLabelButton()
        
        if self.isFromListCoaches == true {
            self.navigationController?.navigationBar.hidden = true
        }
        
        let testimonialXib = UINib(nibName: kTestimonialCell, bundle: nil)
        self.testimonialCollectionView.registerNib(testimonialXib, forCellWithReuseIdentifier: kTestimonialCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let val = self.coachDetail[kId] as? Int {
            TrackingPMAPI.sharedInstance.trackingProfileViewed("\(val)")
        }
        self.checkConnect()
        
        self.isStopGetTestimonial = false
        self.testimonialOffset = 0
        self.getTestimonial()
        
        self.playVideoButton.setImage(nil, forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        postHeightDT.constant = aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
        self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + postHeightDT.constant)
        self.scrollView.scrollEnabled = true
        
        // check Video URL
        let videoURL = self.coachDetail[kVideoURL] as? String
//        let videoURL = "https://pummel-prod.s3.amazonaws.com/videos/1497421626868-0.mov"
        if (videoURL?.isEmpty == false && self.isShowVideo == true) {
            self.showVideoLayout(videoURL!)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // pause video and move time to 0
        if (self.videoView != nil && self.videoView?.layer != nil && self.videoView?.layer.sublayers != nil) {
            self.videoPlayer?.pause()
            
            // Remove video view
            self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
            
//            self.videoPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
        }
    }
    
    func getBusinessImage() {
        if (self.coachDetail[kBusinessId] is NSNull == false) {
            let businessID = String(format:"%0.f", self.coachDetail[kBusinessId]!.doubleValue)
            
            ImageRouter.getBusinessLogo(businessID: businessID, sizeString: widthHeight120, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.businessIMV.image = imageRes
                    
                    self.businessIMV.hidden = false
                    self.aboutLeftDT.constant = 120
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
    }
    
    func getCoachTags() {
        let userID = String(format:"%0.f", self.coachDetail[kId]!.doubleValue)
        var tagLink = kPMAPIUSER
        tagLink.appendContentsOf(userID)
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
    }
    
    func getTestimonial() {
        if (self.isStopGetTestimonial == false) {
            let userIDNumber = self.coachDetail[kId] as! Double
            let userID = String(format: "%0.f", userIDNumber)
            
            UserRouter.getTestimonial(userID: userID, offset: self.testimonialOffset) { (result, error) in
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
    
    func setCoachAvatar() {
        let imageLink = self.coachDetail[kImageUrl] as! String
        var prefix = kPMAPI
        prefix.appendContentsOf(imageLink)
        let postfix = widthEqual.stringByAppendingString(avatarIMV.frame.size.width.description).stringByAppendingString(heighEqual).stringByAppendingString(avatarIMV.frame.size.width.description)
        prefix.appendContentsOf(postfix)
        if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
            let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
            self.avatarIMV.image = imageRes
        } else {
            Alamofire.request(.GET, prefix)
                .responseImage { response in
                    if (response.response?.statusCode == 200) {
                        let imageRes = response.result.value! as UIImage
                        self.avatarIMV.image = imageRes
                        NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                    }
            }
        }
    }
    
    func setupViewForLabelButton() {
        self.addressLB.font = .pmmMonReg11()
        self.interestLB.font = .pmmMonReg11()
        self.specialitiesLB.font = .pmmMonLight11()
        self.qualificationTV.font = .pmmMonLight13()
        self.socailLB.font = .pmmMonLight11()
        self.postLB.font = .pmmMonLight11()
        self.aboutLB.font = .pmmMonLight11()
        self.aboutTV.font = .pmmMonLight13()
        self.qualificationTV.font = .pmmMonLight13()
        self.facebookBT.titleLabel?.font = .pmmMonReg11()
        self.twiterBT.titleLabel?.font = .pmmMonReg11()
        self.instagramBT.titleLabel?.font = .pmmMonReg11()
        self.ratingLB.font = .pmmMonLight10()
        self.ratingContentLB.font = .pmmMonReg16()
        self.connectionLB.font = .pmmMonLight10()
        self.connectionLB.text = "RATING"
        self.connectionContentLB.font = .pmmMonReg16()
        self.postNumberLB.font = .pmmMonLight10()
        self.postNumberContentLB.font = .pmmMonReg16()
        self.aboutCollectionView.backgroundColor = UIColor.pmmWhiteColor()
    }
    
    func getListImage() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(String(format:"%0.f", self.coachDetail[kId]!.doubleValue))
        prefix.appendContentsOf(kPM_PATH_PHOTO_PROFILE)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                self.photoArray = JSON as! NSArray
                self.aboutCollectionView.reloadData()
                self.postHeightDT.constant = self.aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
                self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: self.aboutCollectionView.frame.origin.y + self.postHeightDT.constant)
                self.scrollView.scrollEnabled = true
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func updateUI() {
        var prefix = kPMAPICOACH
        prefix.appendContentsOf(String(format:"%0.f", self.coachDetail[kId]!.doubleValue))
        self.view.makeToastActivity(message: "Loading")
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                if (JSON is NSNull == true) {
                    return
                }
                
                let coachInformationTotal = JSON as! NSDictionary
                let coachInformation = coachInformationTotal[kUser] as! NSDictionary
                
                var totalPoint = 0.0
                //if (coachInformation[kConnectionCount] is NSNull) {
                    self.connectionContentLB.text = "100%"
//                } else {
//                    self.connectionContentLB.text = String(format:"%0.f", coachInformation[kConnectionCount]!.doubleValue)
//                    
//                    totalPoint = totalPoint + (coachInformation[kConnectionCount]!.doubleValue * 120)
//                }
                
                
                
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
                if (areaText != nil && areaText?.isEmpty == false) {
                    self.locationView.hidden = false
                    self.addressLB.text = areaText
                } else {
                    self.locationView.hidden = true
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
                
                let qualificationText = coachInformationTotal[kQualification] as? String
                if (qualificationText != nil && qualificationText?.isEmpty == false) {
                    self.qualificationTV.text = qualificationText
                    let sizeQualificationTV = self.qualificationTV.sizeThatFits(self.qualificationTV.frame.size)
                    self.qualificationTVHeightDT.constant = sizeQualificationTV.height + 10
                    self.qualificationDT.constant = self.qualificationTV.frame.origin.y + sizeQualificationTV.height
                } else {
                    self.qualificationTV.text = " "
                    self.qualificationDT.constant = 0
                }
                
                let achivementText = coachInformationTotal[kAchievement] as? String
                if (achivementText != nil && achivementText?.isEmpty == false) {
                    self.achivementTV.text = achivementText
                    let sizeAchivementTV = self.achivementTV.sizeThatFits(self.achivementTV.frame.size)
                    self.achivementTVHeightDT.constant = sizeAchivementTV.height + 10
                    self.achivementDT.constant = self.qualificationTV.frame.origin.y + sizeAchivementTV.height
                } else {
                    self.achivementTV.text = " "
                    self.achivementDT.constant = 0
                }
                
                let webText = coachInformationTotal[kWebsiteUrl] as? String
                if (webText != nil && webText?.isEmpty == false) {
                    self.webTV.text = webText
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
    
    func checkConnect() {
        self.view.makeToastActivity(message: "Loading")
        let prefix = kPMAPICHECKUSERCONNECT
        let param = [kUserId: PMHeler.getCurrentID(),
                     kCoachId : self.coachDetail[kId]!]
        
        self.connectBT.userInteractionEnabled = false
        
        Alamofire.request(.POST, prefix, parameters: param)
            .responseString(completionHandler: { (Response) in
                self.view.hideToastActivity()
                self.connectBT.userInteractionEnabled = true
                
                switch (Response.result) {
                case .Success(let resultValue) :
                    let resultString = resultValue as String
                    
                    if (resultString.isEmpty == false) {
                        if (resultString == "Connected") {
                            self.connectBT.setImage(UIImage(named: "mail"), forState: .Normal)
                            self.connectBT.backgroundColor = UIColor(red: 80.0 / 255.0, green: 227.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
                            self.isConnected = true
                            
                            if self.isFromChat {
                                self.connectBT.userInteractionEnabled = false
                            }
                        } else if (resultString == "Not yet") {
                            self.connectBT.setImage(UIImage(named: "connect"), forState: .Normal)
                            self.connectBT.backgroundColor = UIColor(red: 255.0 / 255.0, green: 91.0 / 255.0, blue: 16.0 / 255.0, alpha: 1.0)
                        }
                    } else {
                        self.connectBT.setImage(UIImage(named: "connect"), forState: .Normal)
                        self.connectBT.backgroundColor = UIColor(red: 255.0 / 255.0, green: 91.0 / 255.0, blue: 16.0 / 255.0, alpha: 1.0)
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
                
                
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackToResult() {
        if isFromListCoaches == true {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        self.dismissViewControllerAnimated(true) { 
        }
    }
    
    @IBAction func phoneBTClicked(sender: AnyObject) {
    
    }
    
    @IBAction func goConnection() {
        // Tracker mixpanel
        if self.coachDetail != nil {
            if let firstName = self.coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Send Message", "Label":"\(firstName.uppercaseString)"]
                mixpanel.track("IOS.SendMessageToCoach", properties: properties)
                
                self.view.makeToastActivity(message: "Connecting")
                
                var prefix = kPMAPIUSER
                prefix.appendContentsOf(PMHeler.getCurrentID())
                prefix.appendContentsOf(kPMAPI_LEAD)
                prefix.appendContentsOf("/")
                
                let param = [kUserId : PMHeler.getCurrentID(),
                             kCoachId : self.coachDetail[kId]!]
                
                Alamofire.request(.POST, prefix, parameters: param)
                    .responseJSON { response in
                        self.view.hideToastActivity()
                        
                        if self.isFromChat {
                            self.dismissViewControllerAnimated(true, completion:nil)
                        } else {
                            if let val = self.coachDetail[kId] as? Int {
                                TrackingPMAPI.sharedInstance.trackingConnectButtonCLick("\(val)")
                            }

                            self.performSegueWithIdentifier(kGoConnect, sender: self)
                        }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == kGoConnect) {
            let destimation = segue.destinationViewController as! ConnectViewController
            destimation.coachDetail = self.coachDetail
            destimation.isFromProfile = true
            destimation.isFromFeed = self.isFromFeed
            destimation.isConnected = self.isConnected
        } else if segue.identifier == "goToFeedDetail" {
            let navc = segue.destinationViewController as! UINavigationController
            let destination = navc.topViewController as! FeedViewController
            destination.fromPhoto = true
            if let feed = sender as? NSDictionary {
                destination.feedDetail = feed
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
            self.backBT.setImage(UIImage(named:"blackArrow"), forState: .Normal)
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
            self.backBT.setImage(UIImage(named:"back"), forState: .Normal)
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
            if let firstName = self.coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Facebook", "Label":"\(firstName.uppercaseString)"]
                mixpanel.track("IOS.SocialClick", properties: properties)
            }
            
            if let val = self.coachDetail[kId] as? Int {
                TrackingPMAPI.sharedInstance.trackSocialFacebook("\(val)")
            }
        }
    }
    
    @IBAction func clickOnTwitter() {
        if (self.twitterLink != "") {
            let twitterUrl = NSURL(string: self.twitterLink!)
            var userTwitter = self.twitterLink?.substringFromIndex((self.twitterLink!.rangeOfString("twitter.com/")?.endIndex)!)
            if ((userTwitter!.rangeOfString("/")?.startIndex) != nil) {
                userTwitter = userTwitter?.substringToIndex((userTwitter!.rangeOfString("/")?.startIndex)!)
            }
            
            let twitterLink = NSURL(string: "tweetie://user?screen_name=".stringByAppendingString(userTwitter!))
            if (UIApplication.sharedApplication().canOpenURL(twitterLink!)) {
                UIApplication.sharedApplication().openURL(twitterLink!)
            } else if UIApplication.sharedApplication().canOpenURL(twitterUrl!)
            {
                UIApplication.sharedApplication().openURL(twitterUrl!)
                
            } else {
                //redirect to safari because the user doesn't have Instagram
                UIApplication.sharedApplication().openURL(NSURL(string: "http://twitter.com/")!)
            }
            // Tracker mixpanel
            if let firstName = self.coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Twitter", "Label":"\(firstName.uppercaseString)"]
                mixpanel.track("IOS.SocialClick", properties: properties)
            }
            
            if let val = self.coachDetail[kId] as? Int {
                TrackingPMAPI.sharedInstance.trackSocialTwitter("\(val)")
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
            if let firstName = self.coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Instagram", "Label":"\(firstName.uppercaseString)"]
                mixpanel.track("IOS.SocialClick", properties: properties)
            }
            
            if let val = self.coachDetail[kId] as? Int {
                TrackingPMAPI.sharedInstance.trackSocialInstagram("\(val)")
            }
        }
    }
}

//MARK: - Video
extension CoachProfileViewController {
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
        self.coachBorderV.hidden = isPlay
        self.coachBorderBackgroundV.hidden = isPlay
        self.actionView.hidden = isPlay
    }
    
    
    func showVideoLayout(videoURLString: String) {
        // Move avatar to top left
        let newAvatarSize: CGFloat = 37.0
        let leftMargin: CGFloat = 15.0
        let topMargin: CGFloat = 55.0
        self.avatarIMVCenterXConstraint.constant = -(self.detailV.frame.width - newAvatarSize)/2 + leftMargin
        self.avatarIMVCenterYConstraint.constant = -(self.detailV.frame.height - newAvatarSize)/2 + topMargin
        self.avatarIMVWidthConstraint.constant = newAvatarSize
        
        self.avatarIMV.layer.cornerRadius = newAvatarSize/2
        
        
        self.coachBorderV.layer.cornerRadius = (newAvatarSize + 10)/2
        self.coachBorderBackgroundV.layer.cornerRadius = (newAvatarSize + 4)/2
        
        // Hidden indicator view
        self.smallIndicatorView.hidden = true
        self.medIndicatorView.hidden = true
        self.bigIndicatorView.hidden = true
        self.bigBigIndicatorView.hidden = true
        
        // Show location background
        self.locationBackgroundImageView.hidden = false
        
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
        self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.videoView!.layer.addSublayer(self.videoPlayerLayer!)
        
        //        self.videoPlayer!.currentItem!.addObserver(self, forKeyPath: "status", options: [.Old, .New], context: nil)
        
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
        //        print("observed \(keyPath) \(change)")
        //        let currentItem = object as! AVPlayerItem
        //        if currentItem.status == .ReadyToPlay {
        //            let videoRect = self.videoPlayerLayer?.videoRect
        //            if (videoRect?.width > videoRect?.height) {
        ////                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        //                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        //            } else {
        //                self.videoPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        //            }
        //
        //            self.videoPlayerSetPlay(false)
        //        }
    }
    
    @IBAction func playVideoButtonClicked(sender: AnyObject) {
        if (self.videoPlayer != nil) {
            self.isVideoPlaying = !self.isVideoPlaying
            self.videoPlayerSetPlay(self.isVideoPlaying)
        }
    }
    
    func endVideoNotification(notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        
        // Show first video frame
        playerItem.seekToTime(kCMTimeZero)
        self.videoPlayer?.pause()
        
        // Show item above video view
        self.videoPlayerSetPlay(false)
    }
}

// MARK: - UICollectionViewDataSource
extension CoachProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.interestCollectionView) {
            return tags.count
        } else if (collectionView == self.testimonialCollectionView) {
            if (self.testimonialArray.count > 0) {
                
                self.testimonialViewHeightConstraint.constant = 324
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
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (collectionView == self.interestCollectionView) {
            self.configureCell(self.sizingCell!, forIndexPath: indexPath)
            var cellSize = self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            
            if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
                cellSize.width += 10;
            }
            
            return cellSize
        } else if (collectionView == self.testimonialCollectionView) {
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
        
        if (photo.objectForKey(kImageUrl) is NSNull == false) {
            let link = photo.objectForKey(kImageUrl) as! String
            let postfix = widthEqual.stringByAppendingString((self.view.frame.size.width).description).stringByAppendingString(heighEqual).stringByAppendingString((self.view.frame.size.width).description)
            
            ImageRouter.getImage(imageURLString: link, sizeString: postfix) { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    cell.imageCell.image = imageRes
                } else {
                    print("Request failed with error: \(error)")
                }
                }.fetchdata()
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if let val = self.coachDetail[kId] as? Int {
            TrackingPMAPI.sharedInstance.trackSocialWeb("\(val)")
        }
        return true
    }
}
