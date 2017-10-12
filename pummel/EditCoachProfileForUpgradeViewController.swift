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

class EditCoachProfileForUpgradeViewController: BaseViewController, CLLocationManagerDelegate {
    
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
    
    var tags = [TagModel]()
    var arrayTags : [NSDictionary] = []
    var tagIdsArray : NSMutableArray = []
    var tagOffset: Int = 0
    var isStopLoadTag : Bool = false
    var haveAvatar = false
    var userInfo: NSDictionary!
    
    let imagePicker = UIImagePickerController()
    let defaults = UserDefaults.standard
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
        
        self.navigationItem.title = kNavEditProfile
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.isTranslucent = false;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"APPLY NOW", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.applyNowAction))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"CANCEL", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancel))
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
        self.changeAvatarIMW.isUserInteractionEnabled = true
        self.changeAvatarIMW.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
        

        self.title = "COACH PROFILE"
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    }
    
    func didTapView() {
        if (self.emailContentTF.isFirstResponder) {
            let _ = self.validateEmail()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
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
        self.performSegue(withIdentifier: "LocationPicker", sender: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.aboutDT.constant = self.view.frame.size.width - 30
        self.tagOffset = 0
        self.isStopLoadTag = false
        self.getListTags()
        
        //if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
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
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            var prefix = kPMAPICOACH
            prefix.append(PMHelper.getCurrentID())
            
            var locationName = ""
            if (self.location?.name?.isEmpty == false) {
                locationName = (self.location?.name)!
            }
            
            let param = [kUserId:PMHelper.getCurrentID(),
                         kServiceArea:locationName,
                         kLat:(self.location?.coordinate.latitude)!,
                         kLong:(self.location?.coordinate.longitude)!] as [String : Any]
            
            UserRouter.changeCurrentUserInfo(posfix: "", param: param, completed: { (result, error) in
                // Do nothing
            }).fetchdata()
        }
    }

    func getListTags() {
        if (self.isStopLoadTag == false) {
            TagRouter.getTagList(offset: self.tagOffset, completed: { (result, error) in
                if (error == nil) {
                    let tagList = result as! [TagModel]
                    
                    if (tagList.count == 0) {
                        self.isStopLoadTag = true
                        
                        self.setSelectedForTag()
                    } else {
                        for tag in tagList {
                            if (tag.existInList(tagList: self.tags) == false) {
                                self.tags.append(tag)
                            }
                        }
                        
                        self.tagOffset += 10
                        self.getListTags()
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.isStopLoadTag = true
                    
                    self.setSelectedForTag()
                }
            }).fetchdata()
        }
    }
    
    func setSelectedForTag() {
        let currentUserID = PMHelper.getCurrentID()
        UserRouter.getUserTagList(userID: currentUserID) { (result, error) in
            if (error == nil) {
                let tagList = result as! [TagModel]
                
                for tag in self.tags {
                    if (tag.existInList(tagList: tagList) == true) {
                        tag.selected = true
                    }
                }
                
                self.collectionView.reloadData {
                    self.tagHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                }
                
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func updateUI() {
        let currentUserID = PMHelper.getCurrentID()
        
        if (self.userInfo == nil) {
            UserRouter.getUserInfo(userID: currentUserID, completed: { (result, error) in
                if (error == nil) {
                    self.userInfo = result as! NSDictionary
                    
                    self.fillUserInfo()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        } else {
            self.fillUserInfo()
        }
        
        UserRouter.getCoachInfo(userID: currentUserID) { (result, error) in
            if (error == nil) {
                let coachInformationTotal = result as! NSDictionary
                
                if (coachInformationTotal[kQualification] is NSNull == false) {
                    let qualificationText = coachInformationTotal[kQualification] as! String
                    self.qualificationContentTF.text = qualificationText
                } else {
                    self.qualificationContentTF.text = ""
                }
                
                if (coachInformationTotal[kAchievement] is NSNull == false) {
                    let achivementText = coachInformationTotal[kAchievement] as! String
                    self.achivementContentTF.text = achivementText
                } else {
                    self.achivementContentTF.text = ""
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func fillUserInfo() {
        let firstName = self.userInfo[kFirstname] as! String
        let lastName = self.userInfo[kLastName] as? String
        if (lastName != nil && lastName?.isEmpty == false) {
            self.nameContentTF.text = firstName + " " + lastName!
        } else {
            self.nameContentTF.text = firstName
        }
        
        // TODO: check name aboutContentTV
        if (self.userInfo[kBio] is NSNull == false) {
            self.aboutContentTV.text = self.userInfo[kBio] as! String
        } else {
            self.aboutContentTV.text = ""
        }
        
        if (self.userInfo[kGender] is NSNull == false) {
            self.genderContentTF.text = self.userInfo[kGender] as? String
        }
        
        if (self.userInfo[kEmail] is NSNull == false) {
            self.emailContentTF.text = self.userInfo[kEmail] as? String
        }
        
        if (self.userInfo[kDob] is NSNull == false) {
            let stringDob = self.userInfo[kDob] as! String
            self.dobContentTF.text = stringDob.substring(to: stringDob.index(stringDob.startIndex, offsetBy: 10))
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
        
        self.locationName.text = "..."
        if (self.userInfo[kServiceArea] is NSNull == false) {
            if let val = self.userInfo[kServiceArea] as? String {
                if val != "" {
                    self.locationName.text = val
                }
            }
            
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tapView.isHidden = false
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if (self.view.frame.origin.y >= 0) {
//                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tapView.isHidden = true
        if let _ = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
//            self.view.frame.origin.y = 64
        }
    }
    
    func basicInfoUpdate() {
        
        let alertControllerSuccess = UIAlertController(title: kThanks, message: kMessageUpgradedCoach, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
            self.callBasicInfoUpdate()
        }
        alertControllerSuccess.addAction(OKAction)
        
        self.present(alertControllerSuccess, animated: true) {
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
            self.present(mail, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func callBasicInfoUpdate() {
        if (self.checkRuleInputData() == true) {
            let fullNameArr = nameContentTF.text!.characters.split{$0 == " "}.map(String.init)
            var firstname = ""
            var lastname = ""
            if (fullNameArr.count > 0) {
                firstname = fullNameArr[0]
            }
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
            mixpanel?.track("IOS.Profile.EditProfile", properties: properties)
            
            let userID = PMHelper.getCurrentID()
            
            let gender = (self.genderContentTF.text?.uppercased())!
            
            let weightString = self.weightTF.text?.replacingOccurrences(of: " kgs", with: "")
            
            let heightString = self.heightTF.text?.replacingOccurrences(of: " cms", with: "")
            
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
                         kEmergencyMobile:emergencyMobileTF.text!] as [String : Any]
            
            self.view.makeToastActivity(message: "Saving")
            
            UserRouter.changeCurrentUserInfo(posfix: "", param: param, completed: { (result, error) in
                let isUpdateSuccess = result as! Bool
                
                if (isUpdateSuccess == true) {
                    self.trainerInfoUpdate()
                    self.updateLocationCoach()
                } else {
                    self.view.hideToastActivity()
                    
                    PMHelper.showNoticeAlert(message: pleaseCheckYourInformationAgain)
                }
            }).fetchdata()
        } else {
            self.view.hideToastActivity()
            
            PMHelper.showNoticeAlert(message: pleaseCheckYourInformationAgain)
        }
    }
    
    func trainerInfoUpdate() {
        var prefix = kPMAPICOACH
        prefix.append(PMHelper.getCurrentID())
        
        var qualStr =  ""
        if (self.qualificationContentTF.text != nil) {
            qualStr = qualificationContentTF.text

        }
        
        var achiveStr = ""
        if (self.achivementContentTF.text != nil) {
            achiveStr = achivementContentTF.text
        }
        
        let param = [kUserId:PMHelper.getCurrentID(),
        kQualification:qualStr,
        kAchievement: achiveStr] as [String: Any]
        
        UserRouter.changeCurrentCoachInfo(posfix: "", param: param) { (result, error) in
            self.view.hideToastActivity()
            
            let isUpdateSuccess = result as! Bool
            if (isUpdateSuccess == true) {
                self.sendEmail()
            } else {
                PMHelper.showNoticeAlert(message: pleaseCheckYourInformationAgain)
            }
        }.fetchdata()
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
            
            PMHelper.showApplyAlert(message: message)
            
            return false
        }
        
        // Check ABOUT
        if (self.aboutContentTV.text.isEmpty == true) {
            let offsetPoint = CGPoint(x: 0, y: self.aboutLB.frame.origin.y)
            self.scrollView.setContentOffset(offsetPoint, animated: true)
            
            UIView.animate(withDuration: 1, animations: {
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
            
            UIView.animate(withDuration: 1, animations: {
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
            
            PMHelper.showApplyAlert(message: message)
            return false
        }
        
        // Check LOCATION
        if (self.locationName.text?.isEmpty == true || self.locationName.text == "...") {
            message = "Please set your location"
            
            PMHelper.showApplyAlert(message: message)
            return false
        }
        
        return true
    }
    
    func upgradeToCoach() {
        var prefix = kPMAPICOACH
        prefix.append(PMHelper.getCurrentID())
        
        let param = [kUserId:PMHelper.getCurrentID()]
        
        UserRouter.changeCurrentCoachInfo(posfix: "", param: param) { (result, error) in
            let isChangeSuccess = result as! Bool
            
            if (isChangeSuccess == true) {
                self.defaults.set(true, forKey: k_PM_IS_COACH)
                self.settingCV.settingTableView.reloadData()
                self.basicInfoUpdate()
            }
        }.fetchdata()
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showPopupToSelectProfileAvatar() {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraDevice = .front
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.destructive, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    func imageTapped() {
        showPopupToSelectProfileAvatar()
    }
    
    func setAvatar() {
        let defaults = UserDefaults.standard
        if (defaults.bool(forKey: k_PM_IS_COACH) == false) {
            ImageVideoRouter.getCurrentUserAvatar(sizeString: widthHeight200, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.avatarIMW.image = imageRes
                    
                    self.haveAvatar = true
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        } else {
            let coachID = PMHelper.getCurrentID()
            
            ImageVideoRouter.getCoachAvatar(coachID: coachID, sizeString: widthHeight100, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.avatarIMW.image = imageRes
                    
                    self.haveAvatar = true
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
    
    func validateEmail() -> Bool{
        if (self.isValidEmail(testStr: emailContentTF.text!) == false) {
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
            
            return false
        } else {
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.black])
            return true
        }
    }
    
    func checkRuleInputData() -> Bool {
        if (self.validateEmail() == false) {
            return false
            
        }
        
        if self.facebookUrlTF.text != "" && !self.facebookUrlTF.text!.containsIgnoringCase(find: "facebook.com") {
            self.showMsgLinkInValid()
            return false
        }
        
        if self.twitterUrlTF.text != "" && !self.twitterUrlTF.text!.containsIgnoringCase(find: "twitter.com") {
            self.showMsgLinkInValid()
            return false
        }
        
        if self.instagramUrlTF.text != "" && !self.instagramUrlTF.text!.containsIgnoringCase(find: "instagram.com") {
            self.showMsgLinkInValid()
            return false
        }
        
        return true
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = kDateFormat
            let dateDOB = dateFormatter.date(from: testStr)
            
            let date = NSDate()
            let calendar = NSCalendar.current
            let components = calendar.dateComponents([.day , .month , .year], from: date as Date)
            let componentsDOB = calendar.dateComponents([.day , .month , .year], from:dateDOB!)
            let year =  components.year
            let yearDOB = componentsDOB.year
            
            if (12 < (year! - yearDOB!)) && ((year! - yearDOB!) < 101)  {
                return true
            } else {
                return false
            }
        }
    }
    
    @IBAction func textFieldEditingWithSender(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.backgroundColor = UIColor.black
        datePickerView.setValue(UIColor.white, forKey: "textColor")
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action:#selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.dobContentTF.text = dateFormatter.string(from: sender.date)
        let dateDOB = dateFormatter.date(from: self.dobContentTF.text!)
        
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day , .month , .year], from: date as Date)
        let componentsDOB = calendar.dateComponents([.day , .month , .year], from:dateDOB!)
        let year =  components.year
        let yearDOB = componentsDOB.year
        
        if (12 < (year! - yearDOB!)) && ((year! - yearDOB!) < 101)  {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                                  attributes:[NSForegroundColorAttributeName: UIColor.black])
        } else {
            self.dobContentTF.attributedText = NSAttributedString(string:self.dobContentTF.text!,
                                                                  attributes:[NSForegroundColorAttributeName:  UIColor.pmmRougeColor()])
        }
    }
    
    func selectNewTag(tag: TagModel) {
        TagRouter.selectTag(tagID: tag.tagId!) { (result, error) in
            let isDeleteSuccess = result as! Bool
            
            if (isDeleteSuccess == true) {
                // Do nothing
            } else {
                PMHelper.showDoAgainAlert()
            }
            }.fetchdata()
    }
    
    func deleteATagUser(tag: TagModel) {
        TagRouter.deleteTag(tagID: tag.tagId!) { (result, error) in
            let isDeleteSuccess = result as! Bool
            
            if (isDeleteSuccess == true) {
                // Do nothing
            } else {
                PMHelper.showDoAgainAlert()
            }
            }.fetchdata()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LocationPicker" {
            let locationPicker = segue.destination as! LocationPickerViewController
            locationPicker.location = self.location
            locationPicker.showCurrentLocationButton = true
            locationPicker.useCurrentLocationAsHint = true
            locationPicker.showCurrentLocationInitially = true
            locationPicker.mapType = .standard
            
            let backItem = UIBarButtonItem()
            backItem.title = "BACK        "
            backItem.setTitleTextAttributes([NSFontAttributeName: UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], for: .normal)
            
            navigationItem.backBarButtonItem = backItem
            self.navigationController?.navigationBar.backIndicatorImage = UIImage()
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
            
            locationPicker.completion = { self.location = $0 }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension EditCoachProfileForUpgradeViewController:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kTagCell, for: indexPath) as! TagCell
        self.configureCell(cell: cell, forIndexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath as NSIndexPath)
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
            self.selectNewTag(tag: tag)
            tagIdsArray.add(tag.tagId!)
        } else {
            self.deleteATagUser(tag: tag)
            tagIdsArray.remove(tag.tagId!)
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
extension EditCoachProfileForUpgradeViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.genderContentTF) == true {
            self.didTapView()
            
            self.showPopupToSelectGender()
            
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField == self.nameContentTF) {
            self.aboutContentTV.becomeFirstResponder()
        } else if (textField == self.aboutContentTV) {
            self.emailContentTF.becomeFirstResponder()
        } else if (textField == self.emailContentTF) {
            let _ = self.validateEmail() // dissmiss warning
            
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
    
    func textViewDidChange(_ textView: UITextView) {
        textView.backgroundColor = UIColor.white
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditCoachProfileForUpgradeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.avatarIMW.makeToastActivity()
            self.avatarIMW.contentMode = .scaleAspectFill
            
            var imageData : Data!
            let assetPath = info[UIImagePickerControllerReferenceURL] as! NSURL
            if assetPath.absoluteString!.hasSuffix("JPG") {
                imageData = UIImageJPEGRepresentation(pickedImage, 0.2)
            } else if assetPath.absoluteString!.hasSuffix("PNG") {
                imageData = UIImagePNGRepresentation(pickedImage)
            }
            
            if (imageData == nil) {
                PMHelper.showNoticeAlert(message: pleaseChoosePngOrJpeg)
            } else {
                ImageVideoRouter.uploadPhoto(posfix: kPM_PATH_PHOTO_PROFILE, imageData: imageData as Data, textPost: "", completed: { (result, error) in
                    self.avatarIMW.hideToastActivity()
                    
                    let isUploadSuccess = result as! Bool
                    if (isUploadSuccess == true) {
                        self.avatarIMW.image = pickedImage
                        
                        self.haveAvatar = true
                    }
                }).fetchdata()
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension EditCoachProfileForUpgradeViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: {
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
}
