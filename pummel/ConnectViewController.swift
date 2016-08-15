//
//  ConnectViewController.swift
//  pummel
//
//  Created by Bear Daddy on 7/1/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class ConnectViewController: UIViewController {

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
    @IBOutlet weak var keepLookingBT: UIButton!
    
    @IBOutlet weak var firstConnectingIconV: UIView!
    @IBOutlet weak var secondConnectingIconV: UIView!
    @IBOutlet weak var thirdConnectingIconV: UIView!
    @IBOutlet weak var fourthConnectingIconV: UIView!
    @IBOutlet var meAvatarDT: NSLayoutConstraint!
    @IBOutlet var youAvatarDT: NSLayoutConstraint!
    var coachDetail: NSDictionary!
    var isFromProfile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleConnectLB.font = UIFont(name: "PlayfairDisplay-Regular", size: 32)
        self.titleConnectDetailLB.font = UIFont(name: "PlayfairDisplay-Regular", size: 15)

        self.keepLookingBT.layer.cornerRadius = 2
        self.keepLookingBT.layer.borderWidth = 0.5
        self.keepLookingBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.keepLookingBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 13)
        
        self.sendMessageBT.layer.cornerRadius = 2
        self.sendMessageBT.layer.borderWidth = 0.5
        self.sendMessageBT.backgroundColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)
        
        self.sendMessageBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 13)
        
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
        
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey("currentId") as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    let JSON = response.result.value as! NSDictionary
                    let coachDetailName = (self.coachDetail["firstname"] as! String)
                    let yourName = ((JSON["firstname"] as! String) .stringByAppendingString(" "))
                    
                    let titleConnectLBText = yourName.stringByAppendingString(", meet ").stringByAppendingString(coachDetailName)
                    self.titleConnectLB.text = titleConnectLBText
                }
        }
       
        
        prefix.appendContentsOf("/photos")
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                print(JSON)
                let listPhoto = JSON as! NSArray
                if (listPhoto.count >= 1) {
                    let photo = listPhoto[0] as! NSDictionary
                    var link = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
                    link.appendContentsOf(photo.objectForKey("imageUrl") as! String)
                    let postfix = "?width=".stringByAppendingString(self.meAvatarIMV.frame.size.width.description).stringByAppendingString("&height=").stringByAppendingString(self.meAvatarIMV.frame.size.width.description)
                    link.appendContentsOf(postfix)
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
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
        
        let imageLink = coachDetail["imageUrl"] as! String
        prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
        prefix.appendContentsOf(imageLink)
        let postfix = "?width=".stringByAppendingString(self.youAvatarIMV.frame.size.width.description).stringByAppendingString("&height=").stringByAppendingString(self.youAvatarIMV.frame.size.width.description)
        prefix.appendContentsOf(postfix)
        Alamofire.request(.GET, prefix)
            .responseImage { response in
                let imageRes = response.result.value! as UIImage
                self.youAvatarIMV.image = imageRes
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func keepLooking(sender:UIButton) {
        self.dismissViewControllerAnimated(true) { 
            print("return Profile")
        }
    }
    
    @IBAction func sendUsAMessage(sender: UIButton){
        if (self.isFromProfile == true) {
            let profileVC = presentingViewController!
            let tabbarVC = presentingViewController!.presentingViewController?.childViewControllers[0] as! BaseTabBarController
            let findVC = tabbarVC.viewControllers![2] as! FindViewController
            self.dismissViewControllerAnimated(false, completion: { 
                profileVC.dismissViewControllerAnimated(false, completion: {
                        findVC.performSegueWithIdentifier("sendMessageConnection", sender:nil)
                })
            })
        } else {
            let tabbarVC = presentingViewController!.childViewControllers[0] as! BaseTabBarController
            let findVC = tabbarVC.viewControllers![2] as! FindViewController
            presentingViewController!.dismissViewControllerAnimated(false, completion: {
                findVC.performSegueWithIdentifier("sendMessageConnection", sender:nil)
            })
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
