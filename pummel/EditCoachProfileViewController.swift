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
    
    var tags = [TagModel]()
    var arrayTags : [NSDictionary] = []
    var tagIdsArray : NSMutableArray = []
    var tagOffset: Int = 0
    var isStopGetListTag : Bool = false
    var userInfo: NSDictionary!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = kNavEditProfile
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationController!.navigationBar.isTranslucent = false;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"DONE", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditProfileViewController.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
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
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:(#selector(self.changeAvatarTapped)))
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

        self.tags.removeAll()
        self.tagOffset = 0
        self.isStopGetListTag = false
        self.getListTags()
    }
    
    
    func getListTags() {
        if (self.isStopGetListTag == false) {
            TagRouter.getTagList(offset: self.tagOffset, completed: { (result, error) in
                if (error == nil) {
                    let tagList = result as! [TagModel]
                    
                    if (tagList.count == 0) {
                        self.isStopGetListTag = true
                        
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
                    
                    self.isStopGetListTag = true
                    
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
                
                if (coachInformationTotal[kWebsiteUrl] is NSNull == false) {
                    self.websiteUrlTF.text = coachInformationTotal[kWebsiteUrl] as? String
                } else {
                    self.websiteUrlTF.text = ""
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
            mixpanel?.track("IOS.Profile.EditProfile", properties: properties)
            
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
                         kInstagramUrl:instagramUrlTF.text!,] as [String : Any]
            
            self.view.makeToastActivity(message: "Saving")
            UserRouter.changeCurrentUserInfo(posfix: "", param: param, completed: { (result, error) in
                if (error == nil) {
                    var prefix = kPMAPICOACH
                    prefix.append(PMHelper.getCurrentID())
                    
                    let qualStr: String = (self.qualificationContentTF.text == nil) ? "" : self.qualificationContentTF.text
                    let achiveStr: String = (self.achivementContentTF.text == nil) ? "" : self.achivementContentTF.text
                    
                    let param = [kUserId:PMHelper.getCurrentID(),
                                 kQualification:qualStr,
                                 kAchievement: achiveStr,
                                 kWebsiteUrl:self.websiteUrlTF.text!] as [String : Any]
                    
                    UserRouter.changeCurrentCoachInfo(posfix: "", param: param, completed: { (result, error) in
                        self.view.hideToastActivity()
                        
                        let isChangeDataSuccess = result as! Bool
                        
                        if (isChangeDataSuccess == true) {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                            
                            PMHelper.showNoticeAlert(message: pleaseCheckYourInformationAgain)
                        }
                    }).fetchdata()
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.view.hideToastActivity()
                    
                    PMHelper.showNoticeAlert(message: pleaseCheckYourInformationAgain)
                }
            }).fetchdata()
            
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
    
    func done() {
        self.basicInfoUpdate()
        
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func changeAvatarTapped() {
        let selectImageFromLibrary = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = ["public.image"]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraDevice = .front
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.destructive, handler: selectImageFromLibrary))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true)
    }
    
    func setAvatar() {
        let currentID = PMHelper.getCurrentID()
        
        ImageVideoRouter.getUserAvatar(userID: currentID, sizeString: widthHeight200, completed: { (result, error) in
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
        if !(self.isValidEmail(testStr: emailContentTF.text!)) {
            returnValue = true
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
        } else {
            emailContentTF.attributedText = NSAttributedString(string:emailContentTF.text!,
                                                               attributes:[NSForegroundColorAttributeName: UIColor.black])
        }
        
        if (self.facebookUrlTF.text != "" && !self.facebookUrlTF.text!.containsIgnoringCase(find: "facebook.com")) {
            self.showMsgLinkInValid()
            return true
        }
        
        if (self.twitterUrlTF.text != "" && !self.twitterUrlTF.text!.containsIgnoringCase(find: "twitter.com")) {
            self.showMsgLinkInValid()
            return true
        }
        
        if (self.instagramUrlTF.text != "" && !self.instagramUrlTF.text!.containsIgnoringCase(find: "instagram.com")) {
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = kDateFormat
            let dateDOB = dateFormatter.date(from: testStr)
            
            let date = NSDate()
            let calendar = NSCalendar.current
            let components = calendar.dateComponents([.day , .month , .year], from: date as Date)
            let componentsDOB = calendar.dateComponents([.day , .month , .year], from: dateDOB!)
            let year =  components.year
            let yearDOB = componentsDOB.year
            
            if (12 < (year! - yearDOB!)) && ((year! - yearDOB!) < 101)  {
                return true
            } else {
                return false
            }
        }
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.dobContentTF.text = dateFormatter.string(from: sender.date)
        let dateDOB = dateFormatter.date(from: self.dobContentTF.text!)
        
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day , .month , .year], from: date as Date)
        let componentsDOB = calendar.dateComponents([.day , .month , .year], from: dateDOB!)
        let year =  components.year
        let yearDOB = componentsDOB.year
        
        if (12 < (year! - yearDOB!)) && ((year! - yearDOB!) < 1001)  {
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
    
    // MARK: UIImagePickerControllerDelegate
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediType = info[UIImagePickerControllerMediaType] as! String
        
        if (mediType == "public.image") {
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.avatarIMW.contentMode = .scaleAspectFill
                
                var imageData : NSData!
                let assetPath = info[UIImagePickerControllerReferenceURL] as! NSURL
                
                // TODO need check
                if assetPath.absoluteString!.hasSuffix("JPG") {
//                    type = imageJpeg
//                    filename = jpgeFile
                    imageData = UIImageJPEGRepresentation(pickedImage, 0.2)! as NSData
                } else if assetPath.absoluteString!.hasSuffix("PNG") {
//                    type = imagePng
//                    filename = pngFile
                    imageData = UIImagePNGRepresentation(pickedImage)! as NSData
                }
                
                if (imageData == nil) {
                    DispatchQueue.main.async(execute: {
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
                    self.avatarIMW.makeToastActivity()
                    
                    ImageVideoRouter.currentUserUploadPhoto(posfix: kPM_PATH_PHOTO_PROFILE, imageData: imageData as Data, textPost: "", completed: { (result, error) in
                        self.avatarIMW.hideToastActivity()
                        
                        let isSuccess = result as! Bool
                        if (isSuccess == true) {
                            self.avatarIMW.image = pickedImage
                        }
                    }).fetchdata()
                }
                
            }
        } else if (mediType == "public.movie") {
            do {
                let videoPath = info[UIImagePickerControllerMediaURL] as! NSURL
                let videoData = try Data(contentsOf: videoPath as URL)
                
                // send video by method mutipart to server
                self.view.makeToastActivity(message: "Uploading")
                ImageVideoRouter.currentUserUploadVideo(videoData: videoData) { (result, error) in
                    if (error == nil) {
                        let percent = result as! Double
                        
                        if (percent >= 100.0) {
                            self.view.hideToastActivity()
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                    }.fetchdata()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension EditCoachProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
extension EditCoachProfileViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
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
        datePickerView.addTarget(self, action:#selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(self.emailContentTF) == true {
            if (self.isValidEmail(testStr: self.emailContentTF.text!) == false) {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                        attributes:[NSForegroundColorAttributeName: UIColor.pmmRougeColor()])
            } else {
                self.emailContentTF.attributedText = NSAttributedString(string:self.emailContentTF.text!,
                                                                        attributes:[NSForegroundColorAttributeName: UIColor.black])
            }
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.isEqual(self.aboutContentTV)) {
            self.isFirstTVS = true
        }
    }
}
