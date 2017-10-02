//
//  EditProfileViewController.swift
//  pummel
//
//  Created by ThongNguyen on 4/8/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Mixpanel

class EditCoachProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarIMW: UIImageView!
    @IBOutlet weak var changeAvatarIMW: UIImageView!
    
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var nameContentTF: UITextField!
    @IBOutlet weak var aboutLB: UILabel!
    @IBOutlet weak var aboutContentTV: TextViewAutoHeight!
    @IBOutlet weak var aboutContentDT: NSLayoutConstraint!
    
    @IBOutlet weak var privateInformationLB: UILabel!
    @IBOutlet weak var emailLB: UILabel!
    @IBOutlet weak var emailContentTF: UITextField!
    @IBOutlet weak var mobileLB: UILabel!
    @IBOutlet weak var mobileContentTF: UITextField!
    @IBOutlet weak var genderLB: UILabel!
    @IBOutlet weak var genderContentTF: UITextField!
    @IBOutlet weak var dobLB: UILabel!
    @IBOutlet weak var dobContentTF: UITextField!
    @IBOutlet weak var facebookLB: UILabel!
    @IBOutlet weak var facebookUrlTF: UITextField!
    @IBOutlet weak var instagramLB: UILabel!
    @IBOutlet weak var instagramUrlTF: UITextField!
    @IBOutlet weak var twitterLB: UILabel!
    @IBOutlet weak var twitterUrlTF: UITextField!
    @IBOutlet weak var websiteLB: UILabel!
    @IBOutlet weak var websiteUrlTF: UITextField!
    
    @IBOutlet weak var emergencyInformationLB: UILabel!
    @IBOutlet weak var emergencyNameLB: UILabel!
    @IBOutlet weak var emergencyNameTF: UITextField!
    @IBOutlet weak var emergencyMobileLB: UILabel!
    @IBOutlet weak var emergencyMobileTF: UITextField!
    
    @IBOutlet weak var trainerInfomationLB: UILabel!
    @IBOutlet weak var achivementLB: UILabel!
    @IBOutlet weak var achivementContentTF: TextViewAutoHeight!
    @IBOutlet weak var qualificationLB: UILabel!
    @IBOutlet weak var qualificationContentTF: TextViewAutoHeight!
    @IBOutlet weak var specialites: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    @IBOutlet weak var tagHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var choseAsManyLB: UILabel!
    @IBOutlet weak var tapView: UIView!
    
    var isFirstTVS : Bool = false
    var sizingCell: TagCell?
    
    var tags = [Tag]()
    var arrayTags : [NSDictionary] = []
    var tagIdsArray : NSMutableArray = []
    var offset: Int = 0
    var isStopGetListTag : Bool = false
    var isStopGetListCoachTag: Bool = false
    var userInfo: NSDictionary!
    
    let imagePicker = UIImagePickerController()
    var currentId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentId = PMHelper.getCurrentID()
        
        self.navigationItem.title = kNavEditProfile
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.isTranslucent = false;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"DONE", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditProfileViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"CANCEL", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditProfileViewController.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        
        avatarIMW.layer.cornerRadius = 50
        avatarIMW.clipsToBounds = true
        imagePicker.delegate = self
        
        changeAvatarIMW.layer.cornerRadius = changeAvatarIMW.frame.height/2
        changeAvatarIMW.clipsToBounds = true
        
        self.nameLB.font = .pmmMonLight11()
        self.aboutLB.font = .pmmMonLight11()
        self.emailLB.font = .pmmMonLight11()
        self.genderLB.font = .pmmMonLight11()
        self.mobileLB.font = .pmmMonLight11()
        self.emergencyNameLB.font = .pmmMonLight11()
        self.emergencyMobileLB.font = .pmmMonLight11()
        self.qualificationLB.font = .pmmMonLight11()
        self.achivementLB.font = .pmmMonLight11()
        self.specialites.font = .pmmMonLight11()
        
        self.privateInformationLB.font = .pmmMonReg11()
        self.trainerInfomationLB.font = .pmmMonReg11()
        self.emergencyInformationLB.font = .pmmMonReg11()
        
        self.nameContentTF.font = .pmmMonLight13()
        self.aboutContentTV.font = .pmmMonLight13()
        self.emailContentTF.font = .pmmMonLight13()
        self.genderContentTF.font = .pmmMonLight13()
        self.dobContentTF.font = .pmmMonLight13()
        self.dobContentTF.placeholder = "YYYY-MM-DD"
        self.mobileContentTF.font = .pmmMonLight13()
        self.mobileContentTF.placeholder = "+64..."
        self.achivementContentTF.font = .pmmMonLight13()
        self.qualificationContentTF.font = .pmmMonLight13()
        self.choseAsManyLB.font = .pmmMonLight13()
        self.facebookUrlTF.font = .pmmMonLight13()
        self.facebookUrlTF.placeholder = "http://facebook.com"
        self.instagramUrlTF.font = .pmmMonLight13()
        self.instagramUrlTF.placeholder = "http://instagram.com"
        self.twitterUrlTF.font = .pmmMonLight13()
        self.twitterUrlTF.placeholder = "http://twitter.com"
        self.websiteUrlTF.font = .pmmMonLight13()
        self.emergencyNameTF.font = .pmmMonLight13()
        self.emergencyMobileTF.font = .pmmMonLight13()
        
        self.nameContentTF.delegate = self
        self.emailContentTF.delegate = self
        self.genderContentTF.delegate = self
        self.dobContentTF.delegate = self
        self.mobileContentTF.delegate = self
        self.aboutContentTV.delegate = self
        self.facebookUrlTF.delegate = self
        self.instagramUrlTF.delegate = self
        self.twitterUrlTF.delegate = self
        self.websiteUrlTF.delegate = self
        self.emergencyNameTF.delegate = self
        self.emergencyMobileTF.delegate = self
        self.achivementContentTF.maxHeight = 200
        self.aboutContentTV.maxHeight = 200
        self.qualificationContentTF.maxHeight = 200
        
        self.changeAvatarIMW.layer.cornerRadius = 15
        self.changeAvatarIMW.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(LoginAndRegisterViewController.imageTapped)))
        self.changeAvatarIMW.isUserInteractionEnabled = true
        self.changeAvatarIMW.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditCoachProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditCoachProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let cellNib = UINib(nibName: kTagCell, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: kTagCell)
        self.collectionView.backgroundColor = UIColor.clear
        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
        self.sizingCell?.isSearch = true
        
        if (CURRENT_DEVICE == .phone && SCREEN_MAX_LENGTH == 568.0) {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 8)
        } else {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        
        self.flowLayout.isSearch = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.tapView.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(EditCoachProfileViewController.didTapView))
        self.tapView.addGestureRecognizer(tap)
    }
    
    func didTapView() {
        self.aboutContentTV.resignFirstResponder()
        self.achivementContentTF.resignFirstResponder()
        self.qualificationContentTF.resignFirstResponder()
        self.emailContentTF.resignFirstResponder()
        self.mobileContentTF.resignFirstResponder()
        self.nameContentTF.resignFirstResponder()
        self.dobContentTF.resignFirstResponder()
        self.facebookUrlTF.resignFirstResponder()
        self.twitterUrlTF.resignFirstResponder()
        self.websiteUrlTF.resignFirstResponder()
        self.instagramUrlTF.resignFirstResponder()
        self.emergencyNameTF.resignFirstResponder()
        self.emergencyMobileTF.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setAvatar()
        self.updateUI()
        offset = 0
        isStopGetListTag = false
        self.getListTags()
    }
    
    
    func getListTags() {
        if (isStopGetListTag == false) {
            var listTagsLink = kPMAPI_TAG_OFFSET
            listTagsLink.append(String(offset))
            Alamofire.request(.GET, listTagsLink)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    self.arrayTags = JSON as! [NSDictionary]
                    if (self.arrayTags.count > 0) {
                        for i in 0 ..< self.arrayTags.count {
                            let tagContent = self.arrayTags[i]
                            let tag = Tag()
                            tag.name = tagContent[kTitle] as? String
                            tag.tagId = String(format:"%0.f", (tagContent[kId]! as AnyObject).doubleValue)
                            tag.tagColor = self.getRandomColorString()
                            self.tags.append(tag)
                        }
                        self.offset += 10
                        self.collectionView.reloadData({
                            self.tagHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                        })
                    } else {
                        self.isStopGetListTag = true
                        if !(self.isStopGetListCoachTag) {
                            var tagLink = kPMAPIUSER
                            tagLink.append(self.currentId)
                            tagLink.append("/tags")
                            Alamofire.request(.GET, tagLink)
                                .responseJSON { response in
                                    if (response.response?.statusCode == 200) {
                                        self.isStopGetListCoachTag = true
                                        let tagArr = response.result.value as! [NSDictionary]
                                        for i in 0 ..< tagArr.count {
                                            let tagContent = tagArr[i]
                                            let tagT = Tag()
                                            tagT.name = tagContent[kTitle] as? String
                                            tagT.tagId = String(format:"%0.f", (tagContent[kId]! as AnyObject).doubleValue)
                                            tagT.tagColor = self.getRandomColorString()
                                            let index = self.tags.indexOf({ $0.name == tagT.name
                                            })
                                        
                                            if (index != nil) {
                                                tagT.selected = true
                                                self.tags.removeAtIndex(index!)
                                                self.tags.insert(tagT, atIndex: index!)
                                            }
                                        }
                                        self.collectionView.reloadData()                                        
                                    }
                            }
                        }
                }
                    
                case .Failure(let error):
                    print("Request failed with error: \(String(describing: error))")
                    }
            }
        } else
        {
            self.isStopGetListTag = true
        }
    }
    
    func updateUI() {
        if (self.userInfo == nil) {
            var prefix = kPMAPIUSER
            prefix.append(currentId)
            Alamofire.request(.GET, prefix)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        if (response.result.value == nil) {return}
                        self.userInfo = response.result.value as! NSDictionary
                        if (self.userInfo[kLastName] is NSNull == false) {
                            self.nameContentTF.text = ((self.userInfo[kFirstname] as! String).stringByAppendingString(" ")).stringByAppendingString((self.userInfo[kLastName] as! String))
                        } else {
                            self.nameContentTF.text = self.userInfo[kFirstname] as? String
                        }
                        if (self.userInfo[kBio] is NSNull == false) {
                            self.aboutContentTV.text = self.userInfo[kBio] as! String
                        } else {
                            self.aboutContentTV.text = ""
                        }
                        
//                        let sizeAboutTV = self.aboutContentTV.sizeThatFits(self.aboutContentTV.frame.size)
//                        self.aboutContentDT.constant = sizeAboutTV.height + 20
                        
                        self.genderContentTF.text = self.userInfo[kGender] as? String
                        self.emailContentTF.text = self.userInfo[kEmail] as? String
                        
                        if (self.userInfo[kDob] is NSNull == false) {
                            let stringDob = self.userInfo[kDob] as! String
                            self.dobContentTF.text = stringDob.substringToIndex(stringDob.startIndex.advancedBy(10))
                        }
                        
                        if (self.userInfo[kMobile] is NSNull == false) {
                            self.mobileContentTF.text = self.userInfo[kMobile] as? String
                        }
                        
                        if (self.userInfo[kFacebookUrl] is NSNull == false) {
                            self.facebookUrlTF.text = self.userInfo[kFacebookUrl] as? String
                        }
                        
                        if (self.userInfo[kInstagramUrl] is NSNull == false) {
                            self.instagramUrlTF.text = self.userInfo[kInstagramUrl] as? String
                        }
                        
                        if (self.userInfo[kTwitterUrl] is NSNull == false) {
                            self.twitterUrlTF.text = self.userInfo[kTwitterUrl] as? String
                        }
                        
                        if (self.userInfo[kEmergencyName] is NSNull == false) {
                            self.emergencyNameTF.text = self.userInfo[kEmergencyName] as? String
                        }
                        
                        if (self.userInfo[kEmergencyMobile] is NSNull == false) {
                            self.emergencyMobileTF.text = self.userInfo[kEmergencyMobile] as? String
                        }
                    } else if response.response?.statusCode == 401 {
                        PMHelper.showLogoutAlert()
                    }
            }
        } else {
            if (self.userInfo[kLastName] is NSNull == false) {
                self.nameContentTF.text = ((self.userInfo[kFirstname] as! String).stringByAppendingString(" ")).stringByAppendingString((self.userInfo[kLastName] as! String))
            } else {
                self.nameContentTF.text = self.userInfo[kFirstname] as? String
            }
            
            if (self.userInfo[kBio] is NSNull == false) {
                self.aboutContentTV.text = self.userInfo[kBio] as! String
            } else {
                self.aboutContentTV.text = ""
            }
            
            _ = self.aboutContentTV.sizeThatFits(self.aboutContentTV.frame.size)
//            self.aboutContentDT.constant = sizeAboutTV.height + 20
            self.genderContentTF.text = self.userInfo[kGender] as? String
            self.emailContentTF.text = self.userInfo[kEmail] as? String
            
            if (self.userInfo[kDob] is NSNull == false) {
                let stringDob = self.userInfo[kDob] as! String
                self.dobContentTF.text = stringDob.substringToIndex(stringDob.startIndex.advancedBy(10))
            }
            
            if (self.userInfo[kMobile] is NSNull == false) {
                self.mobileContentTF.text = self.userInfo[kMobile] as? String
            }
            
            if (self.userInfo[kFacebookUrl] is NSNull == false) {
                self.facebookUrlTF.text = self.userInfo[kFacebookUrl] as? String
            }
            
            if (self.userInfo[kInstagramUrl] is NSNull == false) {
                self.instagramUrlTF.text = self.userInfo[kInstagramUrl] as? String
            }
            
            if (self.userInfo[kTwitterUrl] is NSNull == false) {
                self.twitterUrlTF.text = self.userInfo[kTwitterUrl] as? String
            }
            
            if (self.userInfo[kEmergencyName] is NSNull == false) {
                self.emergencyNameTF.text = self.userInfo[kEmergencyName] as? String
            }
            
            if (self.userInfo[kEmergencyMobile] is NSNull == false) {
                self.emergencyMobileTF.text = self.userInfo[kEmergencyMobile] as? String
            }
        }
        
        var prefixC = kPMAPICOACH
        prefixC.append(PMHelper.getCurrentID())
        
        Alamofire.request(.GET, prefixC)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let coachInformationTotal = JSON as! NSDictionary
                
                if (coachInformationTotal[kQualification] is NSNull == false) {
                    let qualificationText = coachInformationTotal[kQualification] as! String
                    self.qualificationContentTF.text = qualificationText
//                    let sizeQualificationTV = self.qualificationContentTF.sizeThatFits(self.qualificationContentTF.frame.size)
//                    self.qualificationContentDT.constant = sizeQualificationTV.height + 20
                } else {
                    self.qualificationContentTF.text = ""
                }
                
                if (coachInformationTotal[kAchievement] is NSNull == false) {
                    let achivementText = coachInformationTotal[kAchievement] as! String
                    self.achivementContentTF.text = achivementText
//                    let sizeAchivementTV = self.achivementContentTF.sizeThatFits(self.achivementContentTF.frame.size)
//                    self.achivementContentTFDT.constant = sizeAchivementTV.height  + 20
                } else {
                    self.achivementContentTF.text = ""
                }
                
                if (coachInformationTotal[kWebsiteUrl] is NSNull == false) {
                    self.websiteUrlTF.text = coachInformationTotal[kWebsiteUrl] as? String
                } else {
                    self.websiteUrlTF.text = ""
                }
                
            case .Failure(let error):
                print("Request failed with error: \(String(describing: error))")
                }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tapView.isHidden = false
        if let keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            if (self.view.frame.origin.y >= 0 && self.isFirstTVS == false) {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tapView.isHidden = true
        if (self.isFirstTVS == true) {
            self.isFirstTVS = false
        }
        if let _ = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            self.view.frame.origin.y = 64
        }
    }
    
    func basicInfoUpdate() {
        if (self.checkRuleInputData() == false) {
            var prefix = kPMAPIUSER
            prefix.append(PMHelper.getCurrentID())
            
            let fullNameArr = nameContentTF.text!.characters.split{$0 == " "}.map(String.init)
            var firstname = ""
            if (fullNameArr.count > 0) {
                firstname = fullNameArr[0]
            }
            var lastname = " "
            if fullNameArr.count >= 2 {
                for i in 1 ..< fullNameArr.count {
                    lastname.append(fullNameArr[i])
                    lastname.append(" ")
                }
            } else {
                lastname = " "
            }
            
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Navigation Click", "Label":"Save Profile"]
            mixpanel.track("IOS.Profile.EditProfile", properties: properties)
            
            let param = [kUserId:PMHelper.getCurrentID(),
                         kFirstname:firstname,
                         kLastName: lastname,
                         kMobile: mobileContentTF.text!,
                         kDob: dobContentTF.text!,
                         kGender:(genderContentTF.text?.uppercased())!,
                         kBio: aboutContentTV.text,
                         kEmergencyName:emergencyNameTF.text!,
                         kEmergencyMobile:emergencyMobileTF.text!,
                         kFacebookUrl:facebookUrlTF.text!,
                         kTwitterUrl:twitterUrlTF.text!,
                         kInstagramUrl:instagramUrlTF.text!,]
            
            self.view.makeToastActivity(message: "Saving")
            Alamofire.request(.PUT, prefix, parameters: param)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        //TODO: Save access token here
                        self.trainerInfoUpdate()
                    }else {
                        self.view.hideToastActivity()
                        let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true) {
                            // ...
                        }
                    }
            }
            
        } else {
            let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true) {
                // ...
            }
        }
    }
    
    func trainerInfoUpdate() {
        var prefix = kPMAPICOACH
        prefix.append(PMHelper.getCurrentID())
        
        let qualStr = (self.qualificationContentTF.text == nil) ? "" : qualificationContentTF.text
        let achiveStr = (self.achivementContentTF.text == nil) ? "" : achivementContentTF.text
        
        let param = [kUserId:PMHelper.getCurrentID(),
                     kQualification:qualStr,
                     kAchievement: achiveStr,
                     kWebsiteUrl:websiteUrlTF.text!]
        
        Alamofire.request(.PUT, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.navigationController?.popViewController(animated: true)
                }else {
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
                        // ...
                    }
                }
        }
    }
    
    func done() {
        self.basicInfoUpdate()
        
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showPopupToSelectProfileAvatar() {
        let selectImageFromLibrary = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .PhotoLibrary
            self.imagePicker.mediaTypes = ["public.image"]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .Camera
            self.imagePicker.cameraDevice = .Front
            self.present(self.imagePicker, animated: true, completion: nil)
        }
//        let takeVideoFromLibrary = { (action:UIAlertAction!) -> Void in
//            self.imagePicker.allowsEditing = false
//            self.imagePicker.sourceType = .PhotoLibrary
//            self.imagePicker.mediaTypes = ["public.movie"]
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.destructive, handler: selectImageFromLibrary))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.destructive, handler: takePhotoWithFrontCamera))
//        alertController.addAction(UIAlertAction(title: kTakeVideo, style: UIAlertActionStyle.destructive, handler: takeVideoFromLibrary))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    func imageTapped() {
        showPopupToSelectProfileAvatar()
    }
    
    func setAvatar() {
        let currentID = PMHelper.getCurrentID()
        
        ImageRouter.getUserAvatar(userID: currentID, sizeString: widthHeight200, completed: { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.avatarIMW.image = imageRes
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }).fetchdata()
    }
    
    func checkRuleInputData() -> Bool {
        var returnValue  = false
        if !(self.isValidEmail(emailContentTF.text!)) {
            returnValue = true
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.black])
        }
        
        if self.facebookUrlTF.text != "" && !self.facebookUrlTF.text!.containsIgnoringCase("facebook.com") {
            self.showMsgLinkInValid()
            return true
        }
        
        if self.twitterUrlTF.text != "" && !self.twitterUrlTF.text!.containsIgnoringCase("twitter.com") {
            self.showMsgLinkInValid()
            return true
        }
        
        if self.instagramUrlTF.text != "" && !self.instagramUrlTF.text!.containsIgnoringCase("instagram.com") {
            self.showMsgLinkInValid()
            return true
        }
        
        return returnValue
    }
    
    func showMsgLinkInValid() {
        let alertController = UIAlertController(title: pmmNotice, message: linkInvalid, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {
        }
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", kEmailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func checkDateChanged(testStr:String) -> Bool {
        if (testStr == "") {
            return false
        } else {
            let dateFormatter = DateFormatter
            dateFormatter.dateFormat = kDateFormat
            let dateDOB = dateFormatter.date(from: testStr)
            
            let date = NSDate()
            let calendar = NSCalendar.current
            let components = calendar.components([.Day , .Month , .Year], fromDate: date)
            let componentsDOB = calendar.components([.Day , .Month , .Year], fromDate:dateDOB!)
            let year =  components.year
            let yearDOB = componentsDOB.year
            
            if (12 < (year - yearDOB)) && ((year - yearDOB) < 101)  {
                return true
            } else {
                return false
            }
        }
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.dobContentTF.text = dateFormatter.string(from: sender.date)
        let dateDOB = dateFormatter.date(from: self.dobContentTF.text!)
        
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        let componentsDOB = calendar.components([.Day , .Month , .Year], fromDate:dateDOB!)
        let year =  components.year
        let yearDOB = componentsDOB.year
        
        if (12 < (year - yearDOB)) && ((year - yearDOB) < 1001)  {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                                  attributes:[NSForegroundColorAttributeName: UIColor.black])
        } else {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                                  attributes:[NSForegroundColorAttributeName:  UIColor.pmmRougeColor()])
        }
    }
    
    func selectNewTag(tag: Tag) {
        var linkAddTagToUser = kPMAPIUSER
        linkAddTagToUser.append(currentId)
        linkAddTagToUser.append("/tags")
        Alamofire.request(.POST, linkAddTagToUser, parameters: [kUserId: currentId, "tagId": tag.tagId!])
                        .responseJSON { response in
                            if response.response?.statusCode == 200 {
                            }
        }
    }
    
    func deleteATagUser(tag: Tag) {
        var linkDeleteTagToUser = kPMAPIUSER
        linkDeleteTagToUser.append(currentId)
        linkDeleteTagToUser.append("/tags/")
        linkDeleteTagToUser.append(tag.tagId!)
        Alamofire.request(.DELETE, linkDeleteTagToUser, parameters: [kUserId: currentId, "tagId": tag.tagId!])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                }
        }
    }
    
    

    @IBAction func showPopupToSelectGender() {
        let selectMale = { (action:UIAlertAction!) -> Void in
            self.genderContentTF.text = kMale
        }
        let selectFemale = { (action:UIAlertAction!) -> Void in
            self.genderContentTF.text = kFemale
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kMALEU, style: .default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: kFemaleU, style: .default, handler: selectFemale))
        
        self.present(alertController, animated: true) { }
    }
    
    func getRandomColorString() -> String{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed*255), Int(randomGreen*255),Int(randomBlue*255),255)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediType = info[UIImagePickerControllerMediaType] as! String
        
        if (mediType == "public.image") {
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                activityView.center = self.view.center
                activityView.startAnimating()
                avatarIMW.addSubview(activityView)
                avatarIMW.contentMode = .ScaleAspectFill
                var imageData : NSData!
                let assetPath = info[UIImagePickerControllerReferenceURL] as! NSURL
                var type : String!
                var filename: String!
                if assetPath.absoluteString!.hasSuffix("JPG") {
                    type = imageJpeg
                    filename = jpgeFile
                    imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
                } else if assetPath.absoluteString!.hasSuffix("PNG") {
                    type = imagePng
                    filename = pngFile
                    imageData = UIImagePNGRepresentation(pickedImage)
                }
                
                if (imageData == nil) {
                    DispatchQueue.main.async(execute: {
                        activityView.stopAnimating()
                        activityView.removeFromSuperview()
                        //Your main thread code goes in here
                        let alertController = UIAlertController(title: pmmNotice, message: pleaseChoosePngOrJpeg, preferredStyle: .alert)
                        
                        
                        let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true) {
                            // ...
                        }
                    })
                    
                } else {
                    var prefix = kPMAPIUSER
                    
                    prefix.append(PMHelper.getCurrentID())
                    prefix.append(kPM_PATH_PHOTO_PROFILE)
                    
                    let parameters = [kUserId:PMHelper.getCurrentID(),
                                      kProfilePic: "1"]
                    
                    Alamofire.upload(
                        .POST,
                        prefix,
                        multipartFormData: { multipartFormData in
                            multipartFormData.appendBodyPart(data: imageData, name: "file",
                                fileName:filename, mimeType:type)
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
                                    if response.result.error != nil {
                                        // failure
                                        activityView.stopAnimating()
                                        activityView.removeFromSuperview()
                                    } else {
                                        activityView.stopAnimating()
                                        activityView.removeFromSuperview()
                                        self.avatarIMW.image = pickedImage
                                    }
                                }
                                
                            case .Failure( _):
                                activityView.stopAnimating()
                                activityView.removeFromSuperview()
                            }
                        }
                    )
                }
                
            }
        } else if (mediType == "public.movie") {
            let videoPath = info[UIImagePickerControllerMediaURL] as! NSURL
            let videoData = NSData(contentsOfURL: videoPath)
            let videoExtend = (videoPath.absoluteString!.components(separatedBy: ".").last?.lowercased())!
            let videoType = "video/" + videoExtend
            let videoName = "video." + videoExtend
            
            // Insert activity indicator
            self.view.makeToastActivity(message: "Uploading")
            
            // send video by method mutipart to server
            var prefix = kPMAPIUSER
            prefix.append(PMHelper.getCurrentID())
            prefix.append(kPM_PATH_VIDEO)
            
            let parameters = [kUserId:PMHelper.getCurrentID(),
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
                        }
                        upload.validate()
                        upload.responseJSON { response in
                            // Do nothing
                            self.view.hideToastActivity()
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    case .Failure( _): break
                        // Do nothing
                    }
                }
            )
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension EditCoachProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTagCell, for: indexPath) as! TagCell
        self.configureCell(cell, for: indexPath)
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, for: indexPath)
        var cellSize = self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        if (CURRENT_DEVICE == .phone && SCREEN_MAX_LENGTH == 568.0) {
            cellSize.width += 5;
        }
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        let tag = tags[indexPath.row]
        if (tag.selected) {
            self.selectNewTag(tag)
            tagIdsArray.addObject(tag.tagId!)
        } else {
            self.deleteATagUser(tag)
            tagIdsArray.removeObject(tag.tagId!)
        }
        let contentOffset = self.scrollView.contentOffset
        self.collectionView.reloadData()
        scrollView.setContentOffset(contentOffset, animated: false)
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagName.textColor =  tag.selected ? UIColor.white : UIColor.pmmWarmGreyColor()
        cell.tagImage.backgroundColor = UIColor.init(hexString: tag.tagColor!)
        cell.tagBackgroundV.backgroundColor = tag.selected ? UIColor.init(hexString: tag.tagColor!) : UIColor.clear
        cell.tagNameLeftMarginConstraint.constant = tag.selected ? 8 : 25
    }
}

// MARK: - UITextFieldDelegate, UITextViewDelegate
extension EditCoachProfileViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField.isEqual(self.nameContentTF)) {
            self.isFirstTVS = true
        }
        if textField.isEqual(self.genderContentTF) == true {
            self.dobContentTF.resignFirstResponder()
            self.emailContentTF.resignFirstResponder()
            self.nameContentTF.resignFirstResponder()
            self.mobileContentTF.resignFirstResponder()
            self.aboutContentTV.resignFirstResponder()
            self.achivementContentTF.resignFirstResponder()
            self.qualificationContentTF.resignFirstResponder()
            self.showPopupToSelectGender()
            return false
        } else {
            return true
        }
    }
    
    @IBAction func textFieldEditingWithSender(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.backgroundColor = UIColor.black
        datePickerView.setValue(UIColor.white, forKey: "textColor")
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action:#selector(EditProfileViewController.datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(self.emailContentTF) == true {
            if (self.isValidEmail(self.emailContentTF.text!) == false) {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                        attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
            } else {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                        attributes:[NSForegroundColorAttributeName: UIColor.black])
            }
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.isEqual(self.aboutContentTV)) {
            self.isFirstTVS = true
        }
    }
}
