//
//  ConnectViewController.swift
//  pummel
//
//  Created by Bear Daddy on 7/1/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Mixpanel

class ConnectViewController: BaseViewController {

    @IBOutlet weak var meAvatarIMV : UIImageView!
    @IBOutlet weak var youAvatarIMV : UIImageView!
    @IBOutlet weak var meSmallIndicatorView: UIView!
    @IBOutlet weak var meMedIndicatorView: UIView!
    @IBOutlet weak var meBigIndicatorView: UIView!
    @IBOutlet weak var youSmallIndicatorView: UIView!
    @IBOutlet weak var youMedIndicatorView: UIView!
    @IBOutlet weak var youBigIndicatorView: UIView!
    
    @IBOutlet weak var titleConnectLB: UILabel!
    @IBOutlet weak var titleConnectDetailLB: UILabel!
   
    @IBOutlet weak var sendMessageBT: UIButton!
    @IBOutlet weak var requestCallBackBT: UIButton!
    @IBOutlet weak var keepLookingBT: UIButton!
    
    @IBOutlet weak var firstConnectingIconV: UIView!
    @IBOutlet weak var secondConnectingIconV: UIView!
    @IBOutlet weak var thirdConnectingIconV: UIView!
    @IBOutlet weak var fourthConnectingIconV: UIView!
    @IBOutlet var meAvatarDT: NSLayoutConstraint!
    @IBOutlet var youAvatarDT: NSLayoutConstraint!
    var coachDetail: NSDictionary!
    var isFromProfile: Bool = false
    var isFromFeed: Bool = false
    var isConnected = false
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLayout()
        
        self.setupUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.isHidden = true
        
        if self.isConnected {
            self.sendUsAMessage(sender: self.sendMessageBT)
        } else {
            self.view.isHidden = false
        }
        
        self.hiddenIndicatorView(isHidden: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.hiddenIndicatorView(isHidden: false)
        }
    }
    
    func hiddenIndicatorView(isHidden: Bool) {
        self.meBigIndicatorView.isHidden = isHidden
        self.meMedIndicatorView.isHidden = isHidden
        self.meSmallIndicatorView.isHidden = isHidden
        
        self.youBigIndicatorView.isHidden = isHidden
        self.youMedIndicatorView.isHidden = isHidden
        self.youSmallIndicatorView.isHidden = isHidden
        
        self.meAvatarIMV.isHidden = isHidden
        self.youAvatarIMV.isHidden = isHidden
    }

    func setupLayout() {
        self.titleConnectLB.font = UIFont.pmmPlayFairReg32()
        self.titleConnectDetailLB.font = UIFont.pmmPlayFairReg15()
        
        self.keepLookingBT.layer.cornerRadius = 2
        self.keepLookingBT.layer.borderWidth = 0.5
        self.keepLookingBT.layer.borderColor = UIColor.white.cgColor
        self.keepLookingBT.titleLabel?.font = UIFont.pmmMonReg13()
        
        self.requestCallBackBT.layer.cornerRadius = 2
        self.requestCallBackBT.layer.borderWidth = 0.5
        self.requestCallBackBT.backgroundColor = UIColor.pmmLightSkyBlueColor()
        self.requestCallBackBT.titleLabel?.font = UIFont.pmmMonReg13()
        
        self.sendMessageBT.layer.cornerRadius = 2
        self.sendMessageBT.layer.borderWidth = 0.5
        self.sendMessageBT.backgroundColor = UIColor.pmmBrightOrangeColor()
        self.sendMessageBT.titleLabel?.font = UIFont.pmmMonReg13()
        
        // Do any additional setup after loading the view.
        self.meBigIndicatorView.clipsToBounds = true
        self.meMedIndicatorView.clipsToBounds = true
        self.meSmallIndicatorView.clipsToBounds = true
        
        
        self.youBigIndicatorView.clipsToBounds = true
        self.youMedIndicatorView.clipsToBounds = true
        self.youSmallIndicatorView.clipsToBounds = true
        
        self.meAvatarIMV.clipsToBounds = true
        self.youAvatarIMV.clipsToBounds = true
        
        self.firstConnectingIconV.layer.cornerRadius = 5
        self.secondConnectingIconV.layer.cornerRadius = 5
        self.thirdConnectingIconV.layer.cornerRadius = 5
        self.fourthConnectingIconV.layer.cornerRadius = 5
        
        self.view.layoutIfNeeded()
        self.meBigIndicatorView.layer.cornerRadius = self.meBigIndicatorView.frame.width/2
        self.meMedIndicatorView.layer.cornerRadius = self.meMedIndicatorView.frame.width/2
        self.meSmallIndicatorView.layer.cornerRadius = self.meSmallIndicatorView.frame.width/2
        
        self.youBigIndicatorView.layer.cornerRadius = self.youBigIndicatorView.frame.width/2
        self.youMedIndicatorView.layer.cornerRadius = self.youMedIndicatorView.frame.width/2
        self.youSmallIndicatorView.layer.cornerRadius = self.youSmallIndicatorView.frame.width/2
        
        self.meAvatarIMV.layer.cornerRadius = self.meAvatarIMV.frame.width/2
        self.youAvatarIMV.layer.cornerRadius = self.youAvatarIMV.frame.width/2
    }
    
    func setupUserInfo() {
        // Current user info
        let userID = PMHelper.getCurrentID()
        ImageVideoRouter.getUserAvatar(userID: userID, sizeString: widthHeight236) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.meAvatarIMV.image = imageRes
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
        
        // Coach Info
        let coachDetailName = (self.coachDetail[kFirstname] as! String)
        
        let titleConnectLBText = "Say hi to " + coachDetailName
        self.titleConnectLB.text = titleConnectLBText
        
        let titleConnectDetailText = "Ask " + coachDetailName + " a question or arrange your first appointment"
        self.titleConnectDetailLB.text = titleConnectDetailText
        
        let titleSendMessageText = "CHAT WITH " + coachDetailName
        self.sendMessageBT.setTitle(titleSendMessageText.uppercased(), for: .normal)
        
        let imageLink = coachDetail[kImageUrl] as? String
        if (imageLink?.isEmpty == false) {
            ImageVideoRouter.getImage(imageURLString: imageLink!, sizeString: widthHeight236, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.youAvatarIMV.image = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
    
    @IBAction func sendUsAMessage(_ sender: Any) {
        if let firstName = coachDetail[kFirstname] as? String {
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Send Message", "Label":"\(firstName.uppercased())"]
            mixpanel?.track("IOS.SendMessageToCoach", properties: properties)
        }

        self.moveToMessageScreenWithMessage(message: "")
        if let val = coachDetail[kId] as? Int {
            TrackingPMAPI.sharedInstance.trackingMessageButtonCLick(coachId: "\(val)")
        }
    }
    
    @IBAction func requestCallBack(_ sender: Any) {
        let coachDetailName = (self.coachDetail[kFirstname] as! String)
        
        if let firstName = coachDetail[kFirstname] as? String {
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Request Call Back", "Label":"\(firstName.uppercased())"]
            mixpanel?.track("IOS.SendMessageToCoach", properties: properties)
        }
        
        if let val = coachDetail[kId] as? Int {
            TrackingPMAPI.sharedInstance.trackingCallBackButtonClick(coachId: "\(val)")
        }
        
        self.requestCallBackBT.isUserInteractionEnabled = false
        
        var prefix = kPMAPIUSER
        prefix.append(PMHelper.getCurrentID())
        
        UserRouter.getCurrentUserInfo { (result, error) in
            self.requestCallBackBT.isUserInteractionEnabled = true
            
            if (error == nil) {
                let userInfo = result as! NSDictionary
                
                var phoneNumber = ""
                if (userInfo[kMobile] is NSNull == false) {
                    phoneNumber = (userInfo[kMobile] as? String)!
                    phoneNumber = (phoneNumber.uppercased() == "NONE") ? "" : phoneNumber
                }
                
                let message = "Hey " + coachDetailName + ", can you please call me back on " + phoneNumber
                
                self.moveToMessageScreenWithMessage(message: message)
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            
        }.fetchdata()
    }
    
    @IBAction func keepLooking(_ sender: Any) {
        if coachDetail != nil {
            if let firstName = coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Keep Looking", "Label":"\(firstName.uppercased())"]
                mixpanel?.track("IOS.SendMessageToCoach", properties: properties)
            }
        }
        
        self.dismiss(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func moveToMessageScreenWithMessage(message: String) {
        if (self.isFromProfile == true) {
            if (self.isFromFeed == true) {
                let profileVC = presentingViewController!
                let tabbarVC = presentingViewController!.presentingViewController?.childViewControllers[0] as! BaseTabBarController
                let featureVC = tabbarVC.viewControllers![0] as! FeaturedViewController
                self.dismiss(animated: false, completion: {
                    profileVC.dismiss(animated: false, completion: {
                        featureVC.performSegue(withIdentifier: kSendMessageConnection, sender:([self.coachDetail, message]))
                    })
                })
            } else {
                let profileVC = presentingViewController!
                let tabbarVC = presentingViewController!.presentingViewController?.childViewControllers[0] as! BaseTabBarController
                let findVC = tabbarVC.viewControllers![2] as! FindViewController
                self.dismiss(animated: false, completion: {
                    profileVC.dismiss(animated: false, completion: {
                        findVC.performSegue(withIdentifier: kSendMessageConnection, sender:([self.coachDetail, message]))
                    })
                })
            }
        } else {
            if (isFromFeed == true) {
                let tabbarVC = presentingViewController!.childViewControllers[0] as! BaseTabBarController
                let featuredVC = tabbarVC.viewControllers![0] as! FeaturedViewController
                presentingViewController!.dismiss(animated: false, completion: {
                    featuredVC.performSegue(withIdentifier: kSendMessageConnection, sender:([self.coachDetail, message]))
                })
            } else {
                let tabbarVC = presentingViewController!.childViewControllers[0] as! BaseTabBarController
                let findVC = tabbarVC.viewControllers![2] as! FindViewController
                presentingViewController!.dismiss(animated: false, completion: {
                    findVC.performSegue(withIdentifier: kSendMessageConnection, sender:([self.coachDetail, message]))
                })
            }
        }
    }
}
