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

class EditCoachProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
    let defaults = NSUserDefaults.standardUserDefaults()
    var currentId : String = ""
    
    let SCREEN_MAX_LENGTH = max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentId = defaults.objectForKey(k_PM_CURRENT_ID) as! String
        self.navigationItem.title = kNavEditProfile
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.translucent = false;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"DONE", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditProfileViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditProfileViewController.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
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
        self.changeAvatarIMW.userInteractionEnabled = true
        self.changeAvatarIMW.addGestureRecognizer(tapGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditCoachProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditCoachProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let cellNib = UINib(nibName: kTagCell, bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: kTagCell)
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        self.sizingCell?.isSearch = true
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 8)
        } else {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        
        self.flowLayout.isSearch = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.tapView.hidden = true
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
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
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
            listTagsLink.appendContentsOf(String(offset))
            Alamofire.request(.GET, listTagsLink)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    self.arrayTags = JSON as! [NSDictionary]
                    if (self.arrayTags.count > 0) {
                        for i in 0 ..< self.arrayTags.count {
                            let tagContent = self.arrayTags[i]
                            let tag = Tag()
                            tag.name = tagContent[kTitle] as? String
                            tag.tagId = String(format:"%0.f", tagContent[kId]!.doubleValue)
                            tag.tagColor = self.getRandomColorString()
                            self.tags.append(tag)
                        }
                        self.offset += 10
                        self.collectionView.reloadData({
                            self.tagHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize().height
                        })
                    } else {
                        self.isStopGetListTag = true
                        if !(self.isStopGetListCoachTag) {
                            var tagLink = kPMAPIUSER
                            tagLink.appendContentsOf(self.currentId)
                            tagLink.appendContentsOf("/tags")
                            Alamofire.request(.GET, tagLink)
                                .responseJSON { response in
                                    if (response.response?.statusCode == 200) {
                                        self.isStopGetListCoachTag = true
                                        let tagArr = response.result.value as! [NSDictionary]
                                        for i in 0 ..< tagArr.count {
                                            let tagContent = tagArr[i]
                                            let tagT = Tag()
                                            tagT.name = tagContent[kTitle] as? String
                                            tagT.tagId = String(format:"%0.f", tagContent[kId]!.doubleValue)
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
                    print("Request failed with error: \(error)")
                    }
            }
        } else
        {
            self.isStopGetListTag = true
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTagCell, forIndexPath: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        var cellSize = self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
            cellSize.width += 5;
        }
        
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
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
        cell.tagName.textColor =  tag.selected ? UIColor.whiteColor() : UIColor.pmmWarmGreyColor()
        cell.tagImage.backgroundColor = UIColor.init(hexString: tag.tagColor!)
        cell.tagBackgroundV.backgroundColor = tag.selected ? UIColor.init(hexString: tag.tagColor!) : UIColor.clearColor()
        cell.tagNameLeftMarginConstraint.constant = tag.selected ? 8 : 25
    }

    
    func updateUI() {
        if (self.userInfo == nil) {
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(currentId)
            Alamofire.request(.GET, prefix)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        if (response.result.value == nil) {return}
                        self.userInfo = response.result.value as! NSDictionary
                        if !(self.userInfo[kLastName] is NSNull) {
                            self.nameContentTF.text = ((self.userInfo[kFirstname] as! String).stringByAppendingString(" ")).stringByAppendingString((self.userInfo[kLastName] as! String))
                        } else {
                            self.nameContentTF.text = self.userInfo[kFirstname] as? String
                        }
                        if !(self.userInfo[kBio] is NSNull) {
                            self.aboutContentTV.text = self.userInfo[kBio] as! String
                        } else {
                            self.aboutContentTV.text = ""
                        }
                        
//                        let sizeAboutTV = self.aboutContentTV.sizeThatFits(self.aboutContentTV.frame.size)
//                        self.aboutContentDT.constant = sizeAboutTV.height + 20
                        
                        self.genderContentTF.text = self.userInfo[kGender] as? String
                        self.emailContentTF.text = self.userInfo[kEmail] as? String
                        
                        if !(self.userInfo[kDob] is NSNull) {
                            let stringDob = self.userInfo[kDob] as! String
                            self.dobContentTF.text = stringDob.substringToIndex(stringDob.startIndex.advancedBy(10))
                        }
                        
                        if !(self.userInfo[kMobile] is NSNull) {
                            self.mobileContentTF.text = self.userInfo[kMobile] as? String
                        }
                        
                        if !(self.userInfo[kFacebookUrl] is NSNull) {
                            self.facebookUrlTF.text = self.userInfo[kFacebookUrl] as? String
                        }
                        
                        if !(self.userInfo[kInstagramUrl] is NSNull) {
                            self.instagramUrlTF.text = self.userInfo[kInstagramUrl] as? String
                        }
                        
                        if !(self.userInfo[kTwitterUrl] is NSNull) {
                            self.twitterUrlTF.text = self.userInfo[kTwitterUrl] as? String
                        }
                        
                        if !(self.userInfo[kEmergencyName] is NSNull) {
                            self.emergencyNameTF.text = self.userInfo[kEmergencyName] as? String
                        }
                        
                        if !(self.userInfo[kEmergencyMobile] is NSNull) {
                            self.emergencyMobileTF.text = self.userInfo[kEmergencyMobile] as? String
                        }
                    }else if response.response?.statusCode == 401 {
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
        } else {
            if !(self.userInfo[kLastName] is NSNull) {
                self.nameContentTF.text = ((self.userInfo[kFirstname] as! String).stringByAppendingString(" ")).stringByAppendingString((self.userInfo[kLastName] as! String))
            } else {
                self.nameContentTF.text = self.userInfo[kFirstname] as? String
            }
            if !(self.userInfo[kBio] is NSNull) {
                self.aboutContentTV.text = self.userInfo[kBio] as! String
            } else {
                self.aboutContentTV.text = ""
            }
            let sizeAboutTV = self.aboutContentTV.sizeThatFits(self.aboutContentTV.frame.size)
//            self.aboutContentDT.constant = sizeAboutTV.height + 20
            self.genderContentTF.text = self.userInfo[kGender] as? String
            self.emailContentTF.text = self.userInfo[kEmail] as? String
            
            if !(self.userInfo[kDob] is NSNull) {
                let stringDob = self.userInfo[kDob] as! String
                self.dobContentTF.text = stringDob.substringToIndex(stringDob.startIndex.advancedBy(10))
            }
            
            if !(self.userInfo[kMobile] is NSNull) {
                self.mobileContentTF.text = self.userInfo[kMobile] as? String
            }
            
            if !(self.userInfo[kFacebookUrl] is NSNull) {
                self.facebookUrlTF.text = self.userInfo[kFacebookUrl] as? String
            }
            
            if !(self.userInfo[kInstagramUrl] is NSNull) {
                self.instagramUrlTF.text = self.userInfo[kInstagramUrl] as? String
            }
            
            if !(self.userInfo[kTwitterUrl] is NSNull) {
                self.twitterUrlTF.text = self.userInfo[kTwitterUrl] as? String
            }
            
            if !(self.userInfo[kEmergencyName] is NSNull) {
                self.emergencyNameTF.text = self.userInfo[kEmergencyName] as? String
            }
            
            if !(self.userInfo[kEmergencyMobile] is NSNull) {
                self.emergencyMobileTF.text = self.userInfo[kEmergencyMobile] as? String
            }
        }
        
        var prefixC = kPMAPICOACH
        prefixC.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefixC)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let coachInformationTotal = JSON as! NSDictionary
                
                if !(coachInformationTotal[kQualification] is NSNull) {
                    let qualificationText = coachInformationTotal[kQualification] as! String
                    self.qualificationContentTF.text = qualificationText
//                    let sizeQualificationTV = self.qualificationContentTF.sizeThatFits(self.qualificationContentTF.frame.size)
//                    self.qualificationContentDT.constant = sizeQualificationTV.height + 20
                } else {
                    self.qualificationContentTF.text = ""
                }
                
                if !(coachInformationTotal[kAchievement] is NSNull) {
                    let achivementText = coachInformationTotal[kAchievement] as! String
                    self.achivementContentTF.text = achivementText
//                    let sizeAchivementTV = self.achivementContentTF.sizeThatFits(self.achivementContentTF.frame.size)
//                    self.achivementContentTFDT.constant = sizeAchivementTV.height  + 20
                } else {
                    self.achivementContentTF.text = ""
                }
                
                if !(coachInformationTotal[kWebsiteUrl] is NSNull) {
                    self.websiteUrlTF.text = coachInformationTotal[kWebsiteUrl] as? String
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tapView.hidden = false
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            if (self.view.frame.origin.y >= 0 && self.isFirstTVS == false) {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tapView.hidden = true
        if (self.isFirstTVS == true) {
            self.isFirstTVS = false
        }
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 64
        }
    }
    
    func basicInfoUpdate() {
        if (self.checkRuleInputData() == false) {
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            let fullNameArr = nameContentTF.text!.characters.split{$0 == " "}.map(String.init)
            var firstname = ""
            if (fullNameArr.count > 0) {
                firstname = fullNameArr[0]
            }
            var lastname = " "
            if fullNameArr.count >= 2 {
                for i in 1 ..< fullNameArr.count {
                    lastname.appendContentsOf(fullNameArr[i])
                    lastname.appendContentsOf(" ")
                }
            } else {
                lastname = " "
            }
            
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Navigation Click", "Label":"Save Profile"]
            mixpanel.track("IOS.Profile.EditProfile", properties: properties)
            
            let param = [kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String,
                         kFirstname:firstname,
                         kLastName: lastname,
                         kMobile: mobileContentTF.text!,
                         kDob: dobContentTF.text!,
                         kGender:(genderContentTF.text?.uppercaseString)!,
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
                        let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                            // ...
                        }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                    }
            }
            
        } else {
            let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }
    }
    
    func trainerInfoUpdate() {
        var prefix = kPMAPICOACH
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        let qualStr = (self.qualificationContentTF.text == nil) ? "" : qualificationContentTF.text
        let achiveStr = (self.achivementContentTF.text == nil) ? "" : achivementContentTF.text
        
        let param = [kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String,
                     kQualification:qualStr,
                     kAchievement: achiveStr,
                     kWebsiteUrl:websiteUrlTF.text!]
        Alamofire.request(.PUT, prefix, parameters: param)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.navigationController?.popViewControllerAnimated(true)
                }else {
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseCheckYourInformationAgain, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                }
        }
    }
    
    func done() {
        self.basicInfoUpdate()
        
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showPopupToSelectProfileAvatar() {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .Camera
            self.imagePicker.cameraDevice = .Front
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.Destructive, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.Destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func imageTapped()
    {
        showPopupToSelectProfileAvatar()
    }
    
    func setAvatar() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.boolForKey(k_PM_IS_COACH) != true) {
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let userDetail = JSON as! NSDictionary
                    if !(userDetail[kImageUrl] is NSNull) {
                        var link = kPMAPI
                        link.appendContentsOf(userDetail[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight200)
                        
                        if (NSCache.sharedInstance.objectForKey(link) != nil) {
                            let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                            self.avatarIMW.image = imageRes
                        } else {
                            Alamofire.request(.GET, link)
                                .responseImage { response in
                                    let imageRes = response.result.value! as UIImage
                                    self.avatarIMW.image = imageRes
                                    NSCache.sharedInstance.setObject(imageRes, forKey: link)
                            }
                        }
                    } else {
                        self.avatarIMW.image = UIImage(named:"display-empty.jpg")
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
            
        } else {
            var prefix = kPMAPICOACH
            prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let userDetailFull = JSON as! NSDictionary
                    let userDetail = userDetailFull[kUser] as! NSDictionary
                    if !(userDetail[kImageUrl] is NSNull) {
                        var link = kPMAPI
                        link.appendContentsOf(userDetail[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight100)
                        
                        if (NSCache.sharedInstance.objectForKey(link) != nil) {
                            let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                            self.avatarIMW.image = imageRes
                        } else {
                            Alamofire.request(.GET, link)
                                .responseImage { response in
                                    let imageRes = response.result.value! as UIImage
                                    self.avatarIMW.image = imageRes
                                    NSCache.sharedInstance.setObject(imageRes, forKey: link)
                            }
                        }
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
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
                dispatch_async(dispatch_get_main_queue(),{
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    //Your main thread code goes in here
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseChoosePngOrJpeg, preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                })
                
            } else {
                var prefix = kPMAPIUSER
                let defaults = NSUserDefaults.standardUserDefaults()
                prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
                prefix.appendContentsOf(kPM_PATH_PHOTO_PROFILE)
                var parameters = [String:AnyObject]()
                parameters = [kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String, kProfilePic: "1"]
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
                            
                        case .Failure(let _):
                            activityView.stopAnimating()
                            activityView.removeFromSuperview()
                        }
                    }
                )
            }
            
        }
        
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkRuleInputData() -> Bool {
        var returnValue  = false
        if !(self.isValidEmail(emailContentTF.text!)) {
            returnValue = true
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
        } else {
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
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
        let alertController = UIAlertController(title: pmmNotice, message: linkInvalid, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true) {
        }
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", kEmailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func checkDateChanged(testStr:String) -> Bool {
        if (testStr == "") {
            return false
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = kDateFormat
            let dateDOB = dateFormatter.dateFromString(testStr)
            
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.isEqual(self.aboutContentTV)) {
            self.isFirstTVS = true
        }
    }
    
    @IBAction func textFieldEditingWithSender(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.backgroundColor = UIColor.blackColor()
        datePickerView.setValue(UIColor.whiteColor(), forKey: "textColor")
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action:#selector(EditProfileViewController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.dobContentTF.text = dateFormatter.stringFromDate(sender.date)
        let dateDOB = dateFormatter.dateFromString(self.dobContentTF.text!)
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        let componentsDOB = calendar.components([.Day , .Month , .Year], fromDate:dateDOB!)
        let year =  components.year
        let yearDOB = componentsDOB.year
        
        if (12 < (year - yearDOB)) && ((year - yearDOB) < 1001)  {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                                  attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
        } else {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                                  attributes:[NSForegroundColorAttributeName:  UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(self.emailContentTF) == true {
            if (self.isValidEmail(self.emailContentTF.text!) == false) {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                        attributes:[NSForegroundColorAttributeName: UIColor(red: 190.0/255.0, green: 23.0/255.0, blue: 46.0/255.0, alpha: 1.0)])
            } else {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                        attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
            }
        }
        return true
    }
    
    func selectNewTag(tag: Tag) {
        var linkAddTagToUser = kPMAPIUSER
        linkAddTagToUser.appendContentsOf(currentId)
        linkAddTagToUser.appendContentsOf("/tags")
        Alamofire.request(.POST, linkAddTagToUser, parameters: [kUserId: currentId, "tagId": tag.tagId!])
                        .responseJSON { response in
                            if response.response?.statusCode == 200 {
                            }
        }
    }
    
    func deleteATagUser(tag: Tag) {
        var linkDeleteTagToUser = kPMAPIUSER
        linkDeleteTagToUser.appendContentsOf(currentId)
        linkDeleteTagToUser.appendContentsOf("/tags/")
        linkDeleteTagToUser.appendContentsOf(tag.tagId!)
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
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kMALEU, style: UIAlertActionStyle.Default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: kFemaleU, style: UIAlertActionStyle.Default, handler: selectFemale))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func getRandomColorString() -> String{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed*255), Int(randomGreen*255),Int(randomBlue*255),255)
    }
}

