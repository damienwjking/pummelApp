//
//  ConnectViewController.swift
//  pummel
//
//  Created by Bear Daddy on 7/1/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

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
        
        self.updateUI()
    }
    
    func updateUI() {
        let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
        let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
        let SCREEN_MAX_LENGTH    = max(SCREEN_WIDTH, SCREEN_HEIGHT)
        //Ip6s
//        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 736.0) {
//            self.meAvatarDT.constant = 11
//            self.youAvatarDT.constant = 11
//        }
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
