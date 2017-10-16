//
//  LogSessionClientDetailViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

class LogSessionClientDetailViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var tag: TagModel = TagModel()
    var editSession = SessionModel()
    var userInfoSelect:NSDictionary!
    
    @IBOutlet weak var tappedV: UIView!
    
    
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var publicBT: UIButton!
    @IBOutlet weak var contentTV: UITextView!
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var avatarUserIMV: UIImageView!
    @IBOutlet weak var avatarUserIMVWidth: NSLayoutConstraint!
    @IBOutlet weak var imageSelected : UIImageView!
    @IBOutlet weak var imageScrolView : UIScrollView!
    @IBOutlet weak var imageSelectBtn: UIButton!
    
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var hourLB: UILabel!
    @IBOutlet weak var minuteLB: UILabel!
    @IBOutlet weak var distanceTF: UITextField!
    @IBOutlet weak var distanceLB: UILabel!
    let distancePickerView = UIPickerView()
    
    @IBOutlet weak var intensityTF: UITextField!
    @IBOutlet weak var intensityLB: UILabel!
    let intensityPickerView = UIPickerView()
    
    @IBOutlet weak var caloriesLB: UILabel!
    @IBOutlet weak var caloriesTF: UITextField!
    let caloriesPickerView = UIPickerView()

    @IBOutlet weak var hoursTextLB: UILabel!
    @IBOutlet weak var minuteTextLB: UILabel!
    @IBOutlet weak var distanceTextLB: UILabel!
    @IBOutlet weak var intensityTextLB: UILabel!
    @IBOutlet weak var caloriesTextLB: UILabel!
    @IBOutlet weak var mileTextLB: UILabel!
    
    @IBOutlet weak var backgroundKeyboardV: UIView!
    @IBOutlet weak var backgroundKeyboardVHeightConstraint: NSLayoutConstraint!
    
    let defaults = UserDefaults.standard
    let titleButton = UIButton()
    var coachDetail: NSDictionary!
    let imagePicker = UIImagePickerController()
    var selectFromLibrary : Bool = false
    var intensityTitleArray = [String]()
    var intensitySelected: String = "Light"
    var distanceSelected: String = "0"
    var caloriesSelected: String = "0"
    var longtimeSelected: String = "0"
    var priv: String = "1"
    let timeFormatter: DateFormatter = DateFormatter()
    var isPublic = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeFormatter.dateFormat = "MMM dd, yyyy hh:mm aaa"
        
        self.initNavigationBar()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LogSessionClientDetailViewController.tappedViewClicked))
        self.tappedV.addGestureRecognizer(tapGesture)
        
        self.timeTF.delegate = self
        self.distanceTF.delegate = self
        self.intensityTF.delegate = self
        self.caloriesTF.delegate = self
        self.timeTF.font = UIFont.pmmMonReg13()
        self.distanceTF.font = UIFont.pmmMonReg13()
        self.intensityTF.font = UIFont.pmmMonReg13()
        self.caloriesTF.font = UIFont.pmmMonReg13()
        self.hourLB.font = UIFont.pmmMonReg13()
        self.minuteLB.font = UIFont.pmmMonReg13()
        self.distanceLB.font = UIFont.pmmMonReg13()
        self.intensityLB.font = UIFont.pmmMonReg13()
        self.caloriesLB.font = UIFont.pmmMonReg13()
        self.hoursTextLB.font =  UIFont.pmmMonReg13()
        self.minuteTextLB.font =  UIFont.pmmMonReg13()
        self.distanceTextLB.font =  UIFont.pmmMonReg13()
        self.intensityTextLB.font =  UIFont.pmmMonReg13()
        self.caloriesTextLB.font =  UIFont.pmmMonReg13()
        self.mileTextLB.font =  UIFont.pmmMonReg13()
        self.publicBT.titleLabel?.font = UIFont.pmmMonReg10()
        
        self.publicBT.layer.cornerRadius = 2;
        
        self.initInformation()
        self.initTime()
        self.initIntensity()
        self.initDistance()
        self.initCalories()
        
        self.tappedV.isUserInteractionEnabled = false
        
        self.imagePicker.delegate = self
        imageScrolView.delegate = self
        imageScrolView.minimumZoomScale = 1
        imageScrolView.maximumZoomScale = 4.0
        imageScrolView.zoomScale = 1.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hourLB.text = "0"
        self.minuteLB.text = "0"
        
        if self.editSession.id == 0 {
            let title = self.tag.name?.components(separatedBy: " ").joined(separator: "")
            self.titleButton.setTitle(String(format: "#%@", (title!.uppercased())), for: .normal)
        } else {
            self.titleButton.setTitle(self.editSession.type?.uppercased(), for: .normal)
        }
        
        
        self.titleButton.titleLabel?.font = UIFont.pmmMonReg13()
        self.titleButton.setTitleColor(UIColor(white: 32.0 / 255.0, alpha: 1.0), for: .normal)
        self.titleButton.sizeToFit()
        self.titleButton.addTarget(self, action: #selector(self.titleButtonClicked), for: .touchUpInside)
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar!.addSubview(self.titleButton)
        
        self.titleButton.frame = CGRect(x: ((navigationBar?.frame.width)! - self.titleButton.frame.width) / 2,
                                        y: 0,
                                        width: self.titleButton.frame.width,
                                        height: (navigationBar?.frame.height)!)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupSessionData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.titleButton.removeFromSuperview()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: Init
    func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        self.backgroundKeyboardVHeightConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.backgroundKeyboardVHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupSessionData() {
        if editSession.id != 0 {
            self.imageSelectBtn.isHidden = true
            
            let fullDateFormatter = DateFormatter()
            fullDateFormatter.dateFormat = kFullDateFormat
            let sessionDate = fullDateFormatter.date(from: self.editSession.datetime!)
            self.dateTF.text = self.timeFormatter.string(from: sessionDate!)
            
            self.contentTV.text = self.editSession.text
            
            let hour = self.editSession.longtime / 60
            let minute = self.editSession.longtime % 60
            
            self.hourLB.text = String(format: "%ld", hour)
            self.minuteLB.text = String(format: "%ld", minute)
            
            self.longtimeSelected = String(format: "%ld", self.editSession.longtime)
            
            if self.editSession.distance == nil {
                self.distanceLB.text = "0"
                self.distanceSelected = "0"
            } else {
                let distanceUnit = self.defaults.object(forKey: kUnit) as? String
                if (distanceUnit == metric) {
                    self.distanceLB.text = String(format: "%0.0f", self.editSession.distance!)
                    
                    self.distanceSelected = String(format: "%0.0f", self.editSession.distance!)
                } else {
                    let distanceValue = Double(self.editSession.distance!) / 1.61
                    
                    self.distanceLB.text = String(format: "%0.1f", distanceValue)
                    
                    self.distanceSelected = String(format: "%0.1f", distanceValue)
                }
            }
            
            self.caloriesLB.text = String(format: "%ld", self.editSession.calorie)
            
            if self.editSession.intensity == nil {
                self.intensityLB.text = "Light"
                self.intensitySelected = "Light"
            } else {
                self.intensityLB.text = self.editSession.intensity
                self.intensitySelected = self.editSession.intensity!
            }
            
            if self.editSession.imageUrl?.isEmpty == false {
                let imageLink = self.editSession.imageUrl
                
                ImageVideoRouter.getImage(imageURLString: imageLink!, sizeString: widthHeight320, completed: { (result, error) in
                    if (error == nil) {
                        let imageRes = result as! UIImage
                        self.imageSelected.image = imageRes
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
            }
        }
    }
    
    func initNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(LogSessionClientDetailViewController.backClicked))
        
        if self.editSession.id == 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kSave.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.saveClicked))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kSave.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.editClicked))
        }
        
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
    }
    
    func initInformation() {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        datePickerView.backgroundColor = UIColor.black
        datePickerView.setValue(UIColor.white, forKey: "textColor")
        dateTF.inputView = datePickerView
        dateTF.font = UIFont.pmmMonReg13()
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker(sender:)), for: .valueChanged)
        
        self.avatarIMV.layer.cornerRadius = 20
        self.avatarIMV.clipsToBounds = true
        self.avatarUserIMV.layer.cornerRadius = 20
        self.avatarUserIMV.clipsToBounds = true
        self.getDetail()
        
        self.contentTV.text = "ADD A COMMENT..."
        self.contentTV.font = UIFont.pmmMonReg13()
        self.contentTV.keyboardAppearance = .dark
        self.contentTV.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
        self.contentTV.delegate = self
        self.contentTV.selectedTextRange = self.contentTV.textRange(from:   self.contentTV.beginningOfDocument, to:self.contentTV.beginningOfDocument)
    }
    
    func initTime() {
        let timePickerView  : UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = .time
        timePickerView.backgroundColor = UIColor.black
        timePickerView.setValue(UIColor.white, forKey: "textColor")
        timePickerView.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        timeTF.inputView = timePickerView
        timePickerView.addTarget(self, action: #selector(self.handleTimePicker(sender:)), for: .valueChanged)
        
        let calendar = NSCalendar.current
        let components = NSDateComponents()
        components.hour = 0
        components.minute = 30
        let defaultDate = calendar.date(from: components as DateComponents)
        timePickerView.date = defaultDate!
        
//        self.setTimeLBWithDate(NSDate())
    }
    
    func initDistance() {
        self.distancePickerView.delegate = self
        self.distancePickerView.dataSource = self
        self.distancePickerView.backgroundColor = UIColor.black
        distanceTF.inputView = self.distancePickerView
        
        let distanceUnit = self.defaults.object(forKey: kUnit) as? String
        if (distanceUnit == metric) {
            self.mileTextLB.text = "KM"
        } else {
            self.mileTextLB.text = "mi"
        }
    }
    
    func initIntensity() {
        self.intensityPickerView.delegate = self
        self.intensityPickerView.dataSource = self
        self.intensityPickerView.backgroundColor = UIColor.black
        intensityTF.inputView = self.intensityPickerView
        
        self.intensityTitleArray.append("Light")
        self.intensityTitleArray.append("Moderate")
        self.intensityTitleArray.append("Vigorous")
    }
    
    func initCalories() {
        self.caloriesPickerView.delegate = self
        self.caloriesPickerView.dataSource = self
        self.caloriesPickerView.backgroundColor = UIColor.black
        caloriesTF.inputView = self.caloriesPickerView
    }
    
    // MARK: Private function
    func tappedViewClicked() {
        self.timeTF.resignFirstResponder()
        self.contentTV.resignFirstResponder()
        self.caloriesTF.resignFirstResponder()
        self.distanceTF.resignFirstResponder()
        self.intensityTF.resignFirstResponder()
        self.tappedV.isUserInteractionEnabled = false
    }
    
    func convertLocalTimeToUTCTime(dateTimeString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm aaa"
        
        dateFormatter.timeZone = NSTimeZone.local
        let date = dateFormatter.date(from: dateTimeString)
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMM dd, yyyy hh:mm aaa"
        newDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        let newDateString = newDateFormatter.string(from: date!)
        
        return newDateString
    }
    
    // MARK: Outlet function
    
    func backClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func titleButtonClicked() {
        
    }
    
    @IBAction func publicButtonClicked(_ sender: Any) {
        self.isPublic = !self.isPublic
        
        if self.isPublic == true {
            priv = "0"
            self.publicBT.setTitle("PUBLIC", for: .normal)
        } else {
            priv = "1"
            self.publicBT.setTitle("PRIVATE", for: .normal)
        }
    }
    
    func saveClicked() {
        if (self.dateTF.text == "" || self.dateTF.text == "ADD A DATE") {
            PMHelper.showNoticeAlert(message: pleaseInputADate)
        } else {
            var userIdSelected = ""
            if self.userInfoSelect != nil {
                if let val = self.userInfoSelect["userId"] as? Int {
                    userIdSelected = "\(val)"
                }
            }
            
            let calorieSelected : String = String((self.caloriesLB.text != "") ? Int(self.caloriesLB.text!)! : 0)
            let selectedDate = self.convertLocalTimeToUTCTime(dateTimeString: self.dateTF.text!)
            
            var distanceSelected = ""
            if (self.distanceSelected as NSString).floatValue > 0 {
                let distanceUnit = self.defaults.object(forKey: kUnit) as? String
                if (distanceUnit == metric) {
                    distanceSelected = String(format: "%0.1f", Double(self.distanceSelected)!)
                } else {
                    let distanceValue = Double(self.distanceSelected)! * 1.61
                    
                    distanceSelected = String(format: "%0.1f", distanceValue)
                }
            }
            
            var imageData = Data()
            if (self.imageSelected.image != nil) {
                imageData = ((self.imageSelected?.isHidden != true) ? UIImageJPEGRepresentation(imageSelected!.image!, 0.2) : UIImageJPEGRepresentation(self.cropAndSave(), 0.2))!
            }
            
            let currentUserID = PMHelper.getCurrentID()
            let message = (self.contentTV.text != "ADD A COMMENT...") ? self.contentTV.text : "..."
            let type = "#" + (self.tag.name?.uppercased())!
            
            self.view.makeToastActivity(message: "Saving")
            SessionRouter.postLogSession(userID: currentUserID,
                                         targetUserID: userIdSelected,
                                         message: message!,
                                         type: type,
                                         intensity: self.intensitySelected,
                                         distance: distanceSelected,
                                         longtime: self.longtimeSelected,
                                         calorie: calorieSelected,
                                         dateTime: selectedDate,
                                         imageData: imageData, completed: { (result, error) in
                                            self.view.hideToastActivity()
                                            
                                            let isPostSuccess = result as! Bool
                                            if (isPostSuccess == true) {
                                                self.navigationController?.popToRootViewController(animated: false)
                                            } else {
                                                PMHelper.showDoAgainAlert()
                                            }
            }).fetchdata()
        }
    }
    
    func editClicked() {
        self.view.makeToastActivity(message: "Saving")
        var prefix = kPMAPIACTIVITY
        prefix.append(String(format:"%ld", self.editSession.id))
        
        let dateSelected = self.convertLocalTimeToUTCTime(dateTimeString: self.dateTF.text!)
        let calorieSelected : String = String((self.caloriesLB.text != "") ? Int(self.caloriesLB.text!)! : 0)
        
        var distanceSelected = ""
        if (self.distanceSelected as NSString).floatValue > 0 {
            let distanceUnit = self.defaults.object(forKey: kUnit) as? String
            if (distanceUnit == metric) {
                distanceSelected = String(format: "%0.1f", Double(self.distanceSelected)!)
            } else {
                let distanceValue = Double(self.distanceSelected)! * 1.61
                
                distanceSelected = String(format: "%0.1f", distanceValue)
            }
        }
        
        SessionRouter.editLogSession(sessionID: "\(self.editSession.id)",
            message:   self.contentTV.text,
            intensity: self.intensitySelected,
            distance:  distanceSelected,
            longtime:  self.longtimeSelected,
            calorie:   calorieSelected,
            dateTime:  dateSelected) { (result, error) in
            self.view.hideToastActivity()
            
            let isEditSuccess = result as! Bool
            if (isEditSuccess == true) {
                self.navigationController?.popViewController(animated: true)
                
                self.editSession.text = self.contentTV.text
                self.editSession.calorie = Int(calorieSelected)!
                self.editSession.intensity = self.intensitySelected
                
                self.editSession.longtime = Int(self.longtimeSelected)!
                
                
                let distanceUnit = self.defaults.object(forKey: kUnit) as? String
                if (distanceUnit == metric) {
                    self.editSession.distance = Double(self.distanceSelected)
                } else {
                    self.editSession.distance = Double(self.distanceSelected)! * 1.61
                }
                
                let newDateFormatter = DateFormatter()
                newDateFormatter.dateFormat = "MMM dd, yyyy hh:mm aaa"
                newDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
                let date = newDateFormatter.date(from: dateSelected)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = kFullDateFormat
                timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
                
                self.editSession.datetime = timeFormatter.string(from: date!)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_UPDATE_SESSION_NOTIFICATION), object: self.editSession)
            }
            
        }.fetchdata()
    }

    func cropAndSave() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageScrolView.bounds.size, true, UIScreen.main.scale)
        let offset = imageScrolView.contentOffset
        
        UIGraphicsGetCurrentContext()!.translateBy(x: -offset.x, y: -offset.y)
        imageScrolView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image!
    }

    func setTimeLBWithDate(date: NSDate) {
        let clockTimeFormatter = DateFormatter()
        clockTimeFormatter.dateFormat = "HH"
        hourLB.text = clockTimeFormatter.string(from: date as Date)
        
        clockTimeFormatter.dateFormat = "mm"
        minuteLB.text = clockTimeFormatter.string(from: date as Date)
        let total = Int(hourLB.text!)!*60 + Int(minuteLB.text!)!
        self.longtimeSelected = String(total)
    }
    
    func getDetail() {
        UserRouter.getCurrentUserInfo { (result, error) in
            if (error == nil) {
                self.coachDetail = result as! NSDictionary
                self.setAvatar()
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    func setAvatar() {
        // avatar of User
        if self.editSession.userId == 0 {
            if (coachDetail[kImageUrl] is NSNull == false) {
                let imageLink = coachDetail[kImageUrl] as! String
                
                ImageVideoRouter.getImage(imageURLString: imageLink, sizeString: widthHeight200, completed: { (result, error) in
                    if (error == nil) {
                        let imageRes = result as! UIImage
                        self.avatarIMV.image = imageRes
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
            }
        } else {
            let targetUserId = "\(self.editSession.userId)"
            
            ImageVideoRouter.getUserAvatar(userID: targetUserId, sizeString: widthHeight200, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.avatarIMV.image = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
        // avatar of coach
        var targetUserId = ""
        self.avatarUserIMVWidth.constant = 40
        
        if self.editSession.coachId == 0 {
            if self.userInfoSelect == nil {
                self.avatarUserIMVWidth.constant = 0
                return
            } else {
                if let val = self.userInfoSelect["userId"] as? Int {
                    targetUserId = "\(val)"
                }
            }
        } else {
            targetUserId = "\(self.editSession.coachId)"
        }
        
        ImageVideoRouter.getUserAvatar(userID: targetUserId, sizeString: widthHeight160) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.avatarUserIMV.image = imageRes
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    @IBAction func showPopupToSelectImage(_ sender: Any) {
        let selectFromLibraryHandler = { (action:UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhotoWithFrontCamera = { (action:UIAlertAction!) -> Void in
            self.showCameraRoll()
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kSelectFromLibrary, style: UIAlertActionStyle.destructive, handler: selectFromLibraryHandler))
        alertController.addAction(UIAlertAction(title: kTakePhoto, style: UIAlertActionStyle.destructive, handler: takePhotoWithFrontCamera))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        dateTF.text = self.timeFormatter.string(from: sender.date)
    }
    
    func handleTimePicker(sender: UIDatePicker) {
        self.setTimeLBWithDate(date: sender.date as NSDate)
    }
    
    func showCameraRoll() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.defaultMode = .Camera
        fusuma.modeOrder = .CameraFirst
        self.present(fusuma, animated: true, completion: nil)
    }
}

// MARK: - FusumaDelegate
extension LogSessionClientDetailViewController: FusumaDelegate {
    func fusumaImageSelected(image: UIImage) {
        self.imageSelected.image = image
        if (self.selectFromLibrary == true) {
            self.imageScrolView.isHidden = true
            self.imageSelected?.isHidden = false
        } else {
            for(subview) in self.imageScrolView.subviews {
                subview.removeFromSuperview()
            }
            let height =  self.view.frame.size.width*image.size.height/image.size.width
            let frameT = (height > self.view.frame.width) ? CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height) : CGRect(x: 0, y: (self.view.frame.size.width - height)/2, width: self.view.frame.size.width, height: height)
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = image
            self.imageScrolView.addSubview(imageViewScrollView)
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSize(width: self.view.frame.size.width, height: frameT.size.height) : CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
            self.imageSelected?.isHidden = true
            self.imageScrolView?.isHidden = false
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
        let alert = UIAlertController(title: accessRequested, message: savingImageNeedsToAccessYourPhotoAlbum, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: kCancle, style: .cancel, handler: { (action) -> Void in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            for(subview) in self.imageScrolView.subviews {
                subview.removeFromSuperview()
            }
            self.imageSelected!.image = pickedImage
            let height =  self.view.frame.size.width*pickedImage.size.height/pickedImage.size.width
            let frameT = (height > self.view.frame.width) ? CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height) : CGRect(x: 0, y: (self.view.frame.size.width - height)/2, width: self.view.frame.size.width, height: height)
            let imageViewScrollView = UIImageView.init(frame: frameT)
            imageViewScrollView.image = pickedImage
            self.imageScrolView.addSubview(imageViewScrollView)
            self.imageScrolView.contentSize =  (height > self.view.frame.width) ? CGSize(width: self.view.frame.size.width, height: frameT.size.height) : CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
            self.imageSelected?.isHidden = true
            self.imageScrolView?.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0] as! UIImageView
    }
}

// MARK: UIPickerViewDelegate
extension LogSessionClientDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.distancePickerView {
            return 100;
        }
        
        if pickerView == self.intensityPickerView {
            return 3;
        }
        
        if pickerView == self.caloriesPickerView {
            return 101;
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        
        if pickerView == self.distancePickerView {
            title = String(format: "%ld", row)
            //            self.distanceSelected = String(format: "%ld", self.distancePickerView.selectedRowInComponent(0) + 1)
        }
        
        if pickerView == self.intensityPickerView {
            title = self.intensityTitleArray[row]
            self.intensitySelected = title
        }
        
        if pickerView == self.caloriesPickerView {
            title = String(format: "%ld", row * 5)
            self.caloriesSelected = title
        }
        
        let attString = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.white])
        return attString;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.distancePickerView {
            return String(format: "%ld", row)
        }
        
        if pickerView == self.intensityPickerView {
            return self.intensityTitleArray[row]
        }
        
        if pickerView == self.caloriesPickerView {
            return String(format: "%ld", row * 5)
        }
        
        return "";
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.distancePickerView {
            self.distanceLB.text = String(format: "%ld", row)
            self.distanceSelected = String(format: "%ld", row)
        }
        
        if pickerView == self.intensityPickerView {
            self.intensityLB.text = self.intensityTitleArray[row]
        }
        
        if pickerView == self.caloriesPickerView {
            self.caloriesLB.text = String(format: "%ld", row * 5)
        }
    }
}

// MARK: UITextFieldDelegate - UITextViewDelegate
extension LogSessionClientDetailViewController : UITextFieldDelegate, UITextViewDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.tappedV.isUserInteractionEnabled = true
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.caloriesTF {
            self.caloriesPickerView.selectRow(50, inComponent: 0, animated: true)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.tappedV.isUserInteractionEnabled = true
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = textView.text! as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        if updatedText.isEmpty {
            
            textView.text = addAComment
            textView.textColor = UIColor(white:204.0/255.0, alpha: 1.0)
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
        else if textView.textColor == UIColor(white:204.0/255.0, alpha: 1.0) && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.pmmWarmGreyTwoColor()
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor ==  UIColor(white:204.0/255.0, alpha: 1.0) {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}

