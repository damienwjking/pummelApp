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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.backgroundV.backgroundColor = .pmmWhite07Color()
        self.yourPersonalTF.font = .pmmPlayFairReg42()
        self.matchedToYouTF.font = .pmmPlayFairReg15()
        
        self.imInBT.layer.cornerRadius = 2
        self.imInBT.layer.borderWidth = 0.5
        self.imInBT.layer.borderColor = UIColor.white.cgColor
        self.imInBT.titleLabel?.font = .pmmMonReg13()
    }
    
    @IBAction func backToFirstScreenTour(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
