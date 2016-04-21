//
//  GetStarted2ViewController.swift
//  pummel
//
//  Created by Damien King on 29/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//


import UIKit

class GetStarted2ViewController: UIViewController {
    
    @IBOutlet var yourPersonalTF : UILabel!
    @IBOutlet var matchedToYouTF : UILabel!
    @IBOutlet var imInBT : UIButton!
    @IBOutlet var backgroundV : UIView!
    @IBOutlet var mainTextDistantCT: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        self.backgroundV.backgroundColor = UIColor(white: 32.0/255.0, alpha: 0.7)
        self.yourPersonalTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 42)
        self.matchedToYouTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 15)
        
        self.imInBT.layer.cornerRadius = 2
        self.imInBT.layer.borderWidth = 0.5
        self.imInBT.layer.borderColor = UIColor.whiteColor().CGColor
        self.imInBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.updateUI()
    }

    
    @IBAction func backToFirstScreenTour(sender:UIButton!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
        let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
        let SCREEN_MAX_LENGTH    = max(SCREEN_WIDTH, SCREEN_HEIGHT)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
            self.mainTextDistantCT.constant = 40
        }
    }
}
