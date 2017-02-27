//
//  ConnectViewController.swift
//  pummel
//
//  Created by Bear Daddy on 7/1/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
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
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleConnectLB.font = .pmmPlayFairReg32()
        self.titleConnectDetailLB.font = .pmmPlayFairReg15()

        self.keepLookingBT.layer.cornerRadius = 2
        self.keepLookingBT.layer.borderWidth = 0.5
        self.keepLookingBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.keepLookingBT.titleLabel?.font = .pmmMonReg13()
        
        self.requestCallBackBT.layer.cornerRadius = 2
        self.requestCallBackBT.layer.borderWidth = 0.5
        self.requestCallBackBT.backgroundColor = UIColor(red: 80.0 / 255.0, green: 227.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
        self.requestCallBackBT.titleLabel?.font = .pmmMonReg13()
        
        self.sendMessageBT.layer.cornerRadius = 2
        self.sendMessageBT.layer.borderWidth = 0.5
        self.sendMessageBT.backgroundColor = .pmmBrightOrangeColor()
        self.sendMessageBT.titleLabel?.font = .pmmMonReg13()
        
        // Do any additional setup after loading the view.
        self.meBigIndicatorView.alpha = 0.0125
        self.meMedIndicatorView.alpha = 0.025
        self.meSmallIndicatorView.alpha = 0.05
        
        self.meBigIndicatorView.layer.cornerRadius = 344/2
        self.meMedIndicatorView.layer.cornerRadius = 130
        self.meSmallIndicatorView.layer.cornerRadius = 195/2
        
        self.meBigIndicatorView.clipsToBounds = true
        self.meMedIndicatorView.clipsToBounds = true
        self.meSmallIndicatorView.clipsToBounds = true
        
        self.youBigIndicatorView.alpha = 0.0125
        self.youMedIndicatorView.alpha = 0.025
        self.youSmallIndicatorView.alpha = 0.05
        
        self.youBigIndicatorView.layer.cornerRadius = 344/2
        self.youMedIndicatorView.layer.cornerRadius = 130
        self.youSmallIndicatorView.layer.cornerRadius = 195/2
        
        self.youBigIndicatorView.clipsToBounds = true
        self.youMedIndicatorView.clipsToBounds = true
        self.youSmallIndicatorView.clipsToBounds = true
        
        self.meAvatarIMV.layer.cornerRadius = 118/2
        self.meAvatarIMV.clipsToBounds = true
        
        self.youAvatarIMV.layer.cornerRadius = 118/2
        self.youAvatarIMV.clipsToBounds = true
        
        self.firstConnectingIconV.layer.cornerRadius = 5
        self.secondConnectingIconV.layer.cornerRadius = 5
        self.thirdConnectingIconV.layer.cornerRadius = 5
        self.fourthConnectingIconV.layer.cornerRadius = 5
        
        var prefix = kPMAPIUSER
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    let JSON = response.result.value as! NSDictionary
                    let coachDetailName = (self.coachDetail[kFirstname] as! String)
                    
                    var titleConnectLBText = "Say hi to "
                    titleConnectLBText = titleConnectLBText.stringByAppendingString(coachDetailName)
                    self.titleConnectLB.text = titleConnectLBText
                    
                    var titleConnectDetailText = "Ask "
                    titleConnectDetailText = titleConnectDetailText.stringByAppendingString(coachDetailName)
                    titleConnectDetailText = titleConnectDetailText.stringByAppendingString(" a question or arrange your first appointment")
                    self.titleConnectDetailLB.text = titleConnectDetailText
                    
                    let titleSendMessageText = "CHAT WITH ".stringByAppendingString(coachDetailName)
                    self.sendMessageBT.setTitle(titleSendMessageText.uppercaseString, forState: .Normal)
                    
                    var link = kPMAPI
                    if !(JSON[kImageUrl] is NSNull) {
                        link.appendContentsOf(JSON[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight236)
                        if (NSCache.sharedInstance.objectForKey(link) != nil) {
                            let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                            self.meAvatarIMV.image = imageRes
                        } else {
                            Alamofire.request(.GET, link)
                                .responseImage { response in
                                    let imageRes = response.result.value! as UIImage
                                    self.meAvatarIMV.image = imageRes
                                    NSCache.sharedInstance.setObject(imageRes, forKey: link)
                            }
                        }
                    }
                }
        }
        
        let imageLink = coachDetail[kImageUrl] as? String
        if (imageLink?.isEmpty == false) {
            prefix = kPMAPI
            prefix.appendContentsOf(imageLink!)
            prefix.appendContentsOf(widthHeight236)
            Alamofire.request(.GET, prefix)
                .responseImage { response in
                    let imageRes = response.result.value! as UIImage
                    self.youAvatarIMV.image = imageRes
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.hidden = true
        
        if self.isConnected {
            self.sendUsAMessage(self.sendMessageBT)
        } else {
            self.view.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendUsAMessage(sender: UIButton) {
        if let firstName = coachDetail[kFirstname] as? String {
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Send Message", "Label":"\(firstName.uppercaseString)"]
            mixpanel.track("IOS.SendMessageToCoach", properties: properties)
        }

        self.moveToMessageScreenWithMessage("")
    }
    
    @IBAction func requestCallBack(sender: AnyObject) {
        let coachDetailName = (self.coachDetail[kFirstname] as! String)
        
        if let firstName = coachDetail[kFirstname] as? String {
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Request Call Back", "Label":"\(firstName.uppercaseString)"]
            mixpanel.track("IOS.SendMessageToCoach", properties: properties)
        }
        
        self.requestCallBackBT.userInteractionEnabled = false
        
        var prefix = kPMAPIUSER
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                self.requestCallBackBT.userInteractionEnabled = true
                
                if response.response?.statusCode == 200 {
                    if (response.result.value == nil) {return}
                    let userInfo = response.result.value as! NSDictionary
                    
                    var phoneNumber = ""
                    if !(userInfo[kMobile] is NSNull) {
                        phoneNumber = (userInfo[kMobile] as? String)!
                        phoneNumber = (phoneNumber.uppercaseString == "NONE") ? "" : phoneNumber
                    }
                    
                    var message = "Hey "
                    message = message.stringByAppendingString(coachDetailName)
                    message = message.stringByAppendingString(", can you please call me back on ")
                    message = message.stringByAppendingString(phoneNumber)
                    
                    self.moveToMessageScreenWithMessage(message)
                }
        }
    }
    
    @IBAction func keepLooking(sender:UIButton) {
        if coachDetail != nil {
            if let firstName = coachDetail[kFirstname] as? String {
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Keep Looking", "Label":"\(firstName.uppercaseString)"]
                mixpanel.track("IOS.SendMessageToCoach", properties: properties)
            }
        }
        
        self.dismissViewControllerAnimated(true) {
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func moveToMessageScreenWithMessage(message: String) {
        if (self.isFromProfile == true) {
            if (self.isFromFeed == true) {
                let profileVC = presentingViewController!
                let tabbarVC = presentingViewController!.presentingViewController?.childViewControllers[0] as! BaseTabBarController
                let featureVC = tabbarVC.viewControllers![0] as! FeaturedViewController
                self.dismissViewControllerAnimated(false, completion: {
                    profileVC.dismissViewControllerAnimated(false, completion: {
                        featureVC.performSegueWithIdentifier(kSendMessageConnection, sender:([self.coachDetail, message]))
                    })
                })
            } else {
                let profileVC = presentingViewController!
                let tabbarVC = presentingViewController!.presentingViewController?.childViewControllers[0] as! BaseTabBarController
                let findVC = tabbarVC.viewControllers![2] as! FindViewController
                self.dismissViewControllerAnimated(false, completion: {
                    profileVC.dismissViewControllerAnimated(false, completion: {
                        findVC.performSegueWithIdentifier(kSendMessageConnection, sender:([self.coachDetail, message]))
                    })
                })
            }
        } else {
            if (isFromFeed == true) {
                let tabbarVC = presentingViewController!.childViewControllers[0] as! BaseTabBarController
                let featuredVC = tabbarVC.viewControllers![0] as! FeaturedViewController
                presentingViewController!.dismissViewControllerAnimated(false, completion: {
                    featuredVC.performSegueWithIdentifier(kSendMessageConnection, sender:([self.coachDetail, message]))
                })
            } else {
                let tabbarVC = presentingViewController!.childViewControllers[0] as! BaseTabBarController
                let findVC = tabbarVC.viewControllers![2] as! FindViewController
                presentingViewController!.dismissViewControllerAnimated(false, completion: {
                    findVC.performSegueWithIdentifier(kSendMessageConnection, sender:([self.coachDetail, message]))
                })
            }
        }
    }
}
