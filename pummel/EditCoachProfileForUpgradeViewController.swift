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
import MessageUI
import LocationPicker
import CoreLocation
import MapKit

class EditCoachProfileForUpgradeViewController: BaseViewController, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarIMW: UIImageView!
    @IBOutlet weak var changeAvatarIMW: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var nameContentTF: UITextField!
    @IBOutlet weak var aboutLB: UILabel!
    @IBOutlet weak var aboutContentTV: TextViewAutoHeight!
    @IBOutlet weak var aboutContentDT: NSLayoutConstraint!
    @IBOutlet weak var privateInformationLB: UILabel!
    @IBOutlet weak var trainerInfomationLB: UILabel!
    @IBOutlet weak var emailLB: UILabel!
    @IBOutlet weak var emailContentTF: UITextField!
    @IBOutlet weak var genderLB: UILabel!
    @IBOutlet weak var genderContentTF: UITextField!
    @IBOutlet weak var dobLB: UILabel!
    @IBOutlet weak var dobContentTF: UITextField!
    @IBOutlet weak var mobileLB: UILabel!
    @IBOutlet weak var mobileContentTF: UITextField!
    @IBOutlet weak var aboutDT: NSLayoutConstraint!
    @IBOutlet weak var achivementLB: UILabel!
    @IBOutlet weak var achivementContentTF: TextViewAutoHeight!
    @IBOutlet weak var achivementContentTFDT: NSLayoutConstraint!
    @IBOutlet weak var qualificationLB: UILabel!
    @IBOutlet weak var qualificationContentTF: TextViewAutoHeight!
    @IBOutlet weak var qualificationContentDT: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    @IBOutlet weak var tagHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var choseAsManyLB: UILabel!
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var facebookLB: UILabel!
    @IBOutlet weak var facebookUrlTF: UITextField!
    @IBOutlet weak var instagramLB: UILabel!
    @IBOutlet weak var instagramUrlTF: UITextField!
    @IBOutlet weak var twitterLB: UILabel!
    @IBOutlet weak var twitterUrlTF: UITextField!
    @IBOutlet weak var emergencyInformationLB: UILabel!
    @IBOutlet weak var emergencyNameLB: UILabel!
    @IBOutlet weak var emergencyNameTF: UITextField!
    @IBOutlet weak var emergencyMobileLB: UILabel!
    @IBOutlet weak var emergencyMobileTF: UITextField!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationLB: UILabel!
    @IBOutlet weak var healthDataLB: UILabel!
    @IBOutlet weak var socialLB: UILabel!
    @IBOutlet weak var weightLB: UILabel!
    @IBOutlet weak var heightLB: UILabel!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var arrow: UIImageView!
    var sizingCell: TagCell?
    
    var tags = [Tag]()
    var arrayTags : [NSDictionary] = []
    var tagIdsArray : NSMutableArray = []
    var offset: Int = 0
    var isStopGetListTag : Bool = false
    var isStopGetListCoachTag: Bool = false
    var haveAvatar = false
    var userInfo: NSDictionary!
    
    let imagePicker = UIImagePickerController()
    let defaults = NSUserDefaults.standardUserDefaults()
    var currentId : String = ""
    var settingCV:SettingsViewController!
    
    var location: Location? {
        didSet {
        }
    }
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setAvatar()
        self.updateUI()
        self.getListTags()
        
        currentId = PMHelper.getCurrentID()
        self.navigationItem.title = kNavEditProfile
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.translucent = false;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"APPLY NOW", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.applyNowAction))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancel))
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
        self.weightLB.font = .pmmMonLight11()
        self.heightLB.font = .pmmMonLight11()
        
        self.privateInformationLB.font = .pmmMonReg11()
        self.trainerInfomationLB.font = .pmmMonReg11()
        self.emergencyInformationLB.font = .pmmMonReg11()
        self.healthDataLB.font = .pmmMonReg11()
        self.socialLB.font = .pmmMonReg11()
        self.locationLB.font = .pmmMonReg11()
        
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
        self.emergencyNameTF.font = .pmmMonLight13()
        self.emergencyMobileTF.font = .pmmMonLight13()
        self.weightTF.font = .pmmMonLight13()
        self.heightTF.font = .pmmMonLight13()
        
        self.nameContentTF.delegate = self
        self.emailContentTF.delegate = self
        self.genderContentTF.delegate = self
        self.dobContentTF.delegate = self
        self.mobileContentTF.delegate = self
        self.aboutContentTV.delegate = self
        self.facebookUrlTF.delegate = self
        self.instagramUrlTF.delegate = self
        self.twitterUrlTF.delegate = self
        self.emergencyNameTF.delegate = self
        self.emergencyMobileTF.delegate = self
        self.weightTF.delegate = self
        self.heightTF.delegate = self
        self.qualificationContentTF.delegate = self
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
        

        self.title = "COACH PROFILE"
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.arrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
    }
    
    func didTapView() {
        if (self.emailContentTF.isFirstResponder()) {
            self.validateEmail()
        }
        
        self.aboutContentTV.resignFirstResponder()
        self.achivementContentTF.resignFirstResponder()
        self.qualificationContentTF.resignFirstResponder()
        self.emailContentTF.resignFirstResponder()
        self.mobileContentTF.resignFirstResponder()
        self.nameContentTF.resignFirstResponder()
        self.dobContentTF.resignFirstResponder()
        self.facebookUrlTF.resignFirstResponder()
        self.twitterUrlTF.resignFirstResponder()
        self.instagramUrlTF.resignFirstResponder()
        self.emergencyNameTF.resignFirstResponder()
        self.emergencyMobileTF.resignFirstResponder()
        self.weightTF.resignFirstResponder()
        self.heightTF.resignFirstResponder()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            if ((placeMark) != nil) {
                // City
                var city = "..."
                if ((placeMark.administrativeArea) != nil) {
                    if placeMark.locality != nil {
                        city = "\(placeMark.locality!), \(placeMark.administrativeArea!)"
                    } else if placeMark.subAdministrativeArea != nil {
                        city = "\(placeMark.subAdministrativeArea!), \(placeMark.administrativeArea!)"
                    } else {
                        city = placeMark.administrativeArea!
                    }
                }
                self.locationName.text = city
                let locationTemp = Location(name: city, location: location, placemark: MKPlacemark(coordinate: location.coordinate, addressDictionary: [:]))
                self.location = locationTemp
                self.locationManager.stopUpdatingLocation()
            }
        })
        
    }
    
    @IBAction func gotoGetLocation() {
        self.performSegueWithIdentifier("LocationPicker", sender: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.aboutDT.constant = self.view.frame.size.width - 30
        offset = 0
        isStopGetListTag = false
        
        //if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            if self.location != nil {
                if self.location?.name != locationName.text {
                    var locationName = ""
                    if (self.location?.name?.isEmpty == false) {
                        locationName = (self.location?.name)!
                    }
                    
                    self.locationName.text = locationName
                    //self.updateLocationCoach()
                }
            }
            
        //}
    }
    
    func updateLocationCoach() {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            var prefix = kPMAPICOACH
            prefix.appendContentsOf(PMHelper.getCurrentID())
            
            var locationName = ""
            if (self.location?.name?.isEmpty == false) {
                locationName = (self.location?.name)!
            }
            
            let param = [kUserId:PMHelper.getCurrentID(),
                         kServiceArea:locationName,
                         kLat:(self.location?.coordinate.latitude)!,
                         kLong:(self.location?.coordinate.longitude)!]
            
            Alamofire.request(.PUT, prefix, parameters: param as? [String : AnyObject])
                .responseJSON { response in switch response.result {
                case .Success(_): break
                    
                case .Failure(let error):
                    print(error)
                    }
            }
        }
    }

    func getListTags() {
        if (isStopGetListTag == false) {
            var listTagsLink = kPMAPI_TAGALL_OFFSET
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
                            tag.tagType = (tagContent[kType] as? NSNumber)?.integerValue
                            if tag.tagType == 0 || tag.tagType == 1 || tag.tagType == 2 || tag.tagType == 3 {
                                self.tags.append(tag)
                            }
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
                        
                        let sizeAboutTV = self.aboutContentTV.sizeThatFits(self.aboutContentTV.frame.size)
                        self.aboutContentDT.constant = sizeAboutTV.height + 20
                        
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
                        
                        self.locationName.text = "..."
                        if !(self.userInfo[kServiceArea] is NSNull) {
                            if let val = self.userInfo[kServiceArea] as? String {
                                if val != "" {
                                    self.locationName.text = val
                                }
                            }
                            
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
            self.aboutContentDT.constant = sizeAboutTV.height + 20
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
            
            self.locationName.text = "..."
            if !(self.userInfo[kServiceArea] is NSNull) {
                if let val = self.userInfo[kServiceArea] as? String {
                    if val != "" {
                        self.locationName.text = val
                    }
                }
            }
        }
        
        var prefixC = kPMAPICOACH
        prefixC.appendContentsOf(PMHelper.getCurrentID())
        
        Alamofire.request(.GET, prefixC)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                if let coachInformationTotal = JSON as? NSDictionary {
                    if !(coachInformationTotal[kQualification] is NSNull) {
                        let qualificationText = coachInformationTotal[kQualification] as! String
                        self.qualificationContentTF.text = qualificationText
                        let sizeQualificationTV = self.qualificationContentTF.sizeThatFits(self.qualificationContentTF.frame.size)
                        self.qualificationContentDT.constant = sizeQualificationTV.height + 20
                    } else {
                        self.qualificationContentTF.text = ""
                    }
                    
                    if !(coachInformationTotal[kAchievement] is NSNull) {
                        let achivementText = coachInformationTotal[kAchievement] as! String
                        self.achivementContentTF.text = achivementText
                        let sizeAchivementTV = self.achivementContentTF.sizeThatFits(self.achivementContentTF.frame.size)
                        self.achivementContentTFDT.constant = sizeAchivementTV.height  + 20
                    } else {
                        self.achivementContentTF.text = ""
                    }
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tapView.hidden = false
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()) != nil {
            if (self.view.frame.origin.y >= 0) {
//                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tapView.hidden = true
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
//            self.view.frame.origin.y = 64
        }
    }
    
    func basicInfoUpdate() {
        
        let alertControllerSuccess = UIAlertController(title: kThanks, message: kMessageUpgradedCoach, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
            self.callBasicInfoUpdate()
        }
        alertControllerSuccess.addAction(OKAction)
        
        self.presentViewController(alertControllerSuccess, animated: true) {
            // ...
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["hello@pummel.fit"])
            mail.setMessageBody("Hi Pummel, I have just applied to become a coach.  Can you please review my application shortly. Thanks", isHTML: true)
            mail.setSubject("Upgrade to coach")
            self.presentViewController(mail, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: {
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
    func callBasicInfoUpdate() {
        if (self.checkRuleInputData() == true) {
            var prefix = kPMAPIUSER
            prefix.appendContentsOf(PMHelper.getCurrentID())
            
            let fullNameArr = nameContentTF.text!.characters.split{$0 == " "}.map(String.init)
            var firstname = ""
            var lastname = ""
            if (fullNameArr.count > 0) {
                firstname = fullNameArr[0]
            }
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
            
            let userID = PMHelper.getCurrentID()
            
            let gender = (self.genderContentTF.text?.uppercaseString)!
            
            let weightString = self.weightTF.text?.stringByReplacingOccurrencesOfString(" kgs", withString: "")
            
            let heightString = self.heightTF.text?.stringByReplacingOccurrencesOfString(" cms", withString: "")
            
            let param = [kUserId: userID,
                         kFirstname: firstname,
                         kLastName: lastname,
                         kMobile: mobileContentTF.text!,
                         kDob: dobContentTF.text!,
                         kGender: gender,
                         kBio: aboutContentTV.text,
                         kFacebookUrl:facebookUrlTF.text!,
                         kTwitterUrl:twitterUrlTF.text!,
                         kInstagramUrl:instagramUrlTF.text!,
                         kEmergencyName:emergencyNameTF.text!,
                         kWeight: weightString!,
                         kHeight: heightString!,
                         kEmergencyMobile:emergencyMobileTF.text!]
            
            self.view.makeToastActivity(message: "Saving")
            Alamofire.request(.PUT, prefix, parameters: param)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        //TODO: Save access token here
                        self.trainerInfoUpdate()
                        self.updateLocationCoach()
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
        prefix.appendContentsOf(PMHelper.getCurrentID())
        
        let qualStr = (self.qualificationContentTF.text == nil) ? "" : qualificationContentTF.text
        let achiveStr = (self.achivementContentTF.text == nil) ? "" : achivementContentTF.text
        
        let param = [kUserId:PMHelper.getCurrentID(),
                     "qualifications":qualStr, "achievements": achiveStr]
        
        Alamofire.request(.PUT, prefix, parameters: param)
            .responseJSON { response in
                self.view.hideToastActivity()
                if response.response?.statusCode == 200 {
                    self.sendEmail()
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
    }
    
    func applyNowAction() {
        if (self.validatePreCondition() == true) {
            // Upgrade coach
            self.upgradeToCoach()
        }
    }
    
    func validatePreCondition() -> Bool {
        var message = ""
        
        // Check AVATAR
        if (self.haveAvatar == false) {
            message = "Please add a profile image"
            
            PMHelper.showApplyAlert(message)
            
            return false
        }
        
        // Check ABOUT
        if (self.aboutContentTV.text.isEmpty == true) {
            let offsetPoint = CGPoint(x: 0, y: self.aboutLB.frame.origin.y)
            self.scrollView.setContentOffset(offsetPoint, animated: true)
            
            UIView.animateWithDuration(1, animations: {
                self.aboutContentTV.backgroundColor = UIColor.pmmHighLightBrightOrangeColor()
                }, completion: { (_) in
                    self.aboutContentTV.becomeFirstResponder()
            })
            
            return false
        }
        
        // Check QUALIFICATIONS
        if (self.qualificationContentTF.text.isEmpty == true) {
            let offsetPoint = CGPoint(x: 0, y: self.qualificationLB.superview!.frame.origin.y)
            self.scrollView.setContentOffset(offsetPoint, animated: true)
            
            UIView.animateWithDuration(1, animations: {
                self.qualificationContentTF.backgroundColor = UIColor.pmmHighLightBrightOrangeColor()
                }, completion: { (_) in
                    self.qualificationContentTF.becomeFirstResponder()
            })
            
            return false
        }
        
        // Check SPECIALITIES
        var selectedSpecialities = false
        for tag in self.tags {
            if (tag.selected == true) {
                selectedSpecialities = true
                
                break
            }
        }
        if (selectedSpecialities == false) {
            message = "Please choose your specialities"
            
            PMHelper.showApplyAlert(message)
            return false
        }
        
        // Check LOCATION
        if (self.locationName.text?.isEmpty == true || self.locationName.text == "...") {
            message = "Please set your location"
            
            PMHelper.showApplyAlert(message)
            return false
        }
        
        return true
    }
    
    func upgradeToCoach() {
        var prefix = kPMAPICOACH
        prefix.appendContentsOf(PMHelper.getCurrentID())
        
        let param = [kUserId:PMHelper.getCurrentID()]
        
        Alamofire.request(.PUT, prefix, parameters: param)
            .responseJSON { response in switch response.result {
            case .Success(_):
                self.defaults.setBool(true, forKey: k_PM_IS_COACH)
                self.settingCV.settingTableView.reloadData()
                self.basicInfoUpdate()
            case .Failure(_): break
                }
        }
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
    
    func imageTapped() {
        showPopupToSelectProfileAvatar()
    }
    
    func setAvatar() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.boolForKey(k_PM_IS_COACH) == false) {
            ImageRouter.getCurrentUserAvatar(sizeString: widthHeight200, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.avatarIMW.image = imageRes
                    
                    self.haveAvatar = true
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        } else {
            let coachID = PMHelper.getCurrentID()
            
            ImageRouter.getCoachAvatar(coachID: coachID, sizeString: widthHeight100, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.avatarIMW.image = imageRes
                    
                    self.haveAvatar = true
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
    }
    
    func validateEmail() -> Bool{
        if (self.isValidEmail(emailContentTF.text!) == false) {
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
            
            return false
        } else {
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
            return true
        }
    }
    
    func checkRuleInputData() -> Bool {
        if (self.validateEmail() == false) {
            return false
            
        }
        
        if self.facebookUrlTF.text != "" && !self.facebookUrlTF.text!.containsIgnoringCase("facebook.com") {
            self.showMsgLinkInValid()
            return false
        }
        
        if self.twitterUrlTF.text != "" && !self.twitterUrlTF.text!.containsIgnoringCase("twitter.com") {
            self.showMsgLinkInValid()
            return false
        }
        
        if self.instagramUrlTF.text != "" && !self.instagramUrlTF.text!.containsIgnoringCase("instagram.com") {
            self.showMsgLinkInValid()
            return false
        }
        
        return true
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
        
        if (12 < (year - yearDOB)) && ((year - yearDOB) < 101)  {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                                  attributes:[NSForegroundColorAttributeName: UIColor.blackColor()])
        } else {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                                  attributes:[NSForegroundColorAttributeName:  UIColor.pmmRougeColor()])
        }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LocationPicker" {
            let locationPicker = segue.destinationViewController as! LocationPickerViewController
            locationPicker.location = self.location
            locationPicker.showCurrentLocationButton = true
            locationPicker.useCurrentLocationAsHint = true
            locationPicker.showCurrentLocationInitially = true
            locationPicker.mapType = .Standard
            
            let backItem = UIBarButtonItem()
            backItem.title = "BACK        "
            backItem.setTitleTextAttributes([NSFontAttributeName: UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], forState: .Normal)
            
            navigationItem.backBarButtonItem = backItem
            self.navigationController?.navigationBar.backIndicatorImage = UIImage()
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
            
            locationPicker.completion = { self.location = $0 }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension EditCoachProfileForUpgradeViewController:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
}

// MARK: - UITextFieldDelegate, UITextViewDelegate
extension EditCoachProfileForUpgradeViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.isEqual(self.genderContentTF) == true {
            self.didTapView()
            
            self.showPopupToSelectGender()
            
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField == self.nameContentTF) {
            self.aboutContentTV.becomeFirstResponder()
        } else if (textField == self.aboutContentTV) {
            self.emailContentTF.becomeFirstResponder()
        } else if (textField == self.emailContentTF) {
            self.validateEmail()
            
            self.mobileContentTF.becomeFirstResponder()
        } else if (textField == self.mobileContentTF) {
            self.gotoGetLocation()
        } else if (textField == self.emergencyNameTF) {
            self.emergencyMobileTF.becomeFirstResponder()
        } else if (textField == self.emergencyMobileTF) {
            self.genderContentTF.becomeFirstResponder()
        } else if (textField == self.facebookUrlTF) {
            self.instagramUrlTF.becomeFirstResponder()
        } else if (textField == self.instagramUrlTF) {
            self.twitterUrlTF.becomeFirstResponder()
        } else if (textField == self.twitterUrlTF) {
            self.qualificationContentTF.becomeFirstResponder()
        } else if (textField == self.qualificationContentTF) {
            self.achivementContentTF.becomeFirstResponder()
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        textView.backgroundColor = UIColor.whiteColor()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditCoachProfileForUpgradeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                prefix.appendContentsOf(PMHelper.getCurrentID())
                prefix.appendContentsOf(kPM_PATH_PHOTO_PROFILE)
                
                let parameters = [kUserId:PMHelper.getCurrentID(), kProfilePic: "1"]
                
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
                                    
                                    self.haveAvatar = true
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
        
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


