//
//  GetStarted3ViewController.swift
//  pummel
//
//  Created by Damien King on 13/03/2016.
//  Copyright © 2016 pummel. All rights reserved.
//


import UIKit

class GetStarted3ViewController: UIViewController {
   
    @IBOutlet var reachTF : UILabel!
    @IBOutlet var shareTF : UILabel!
    @IBOutlet var letSetItBT : UIButton!
    @IBOutlet var backgroundV : UIView!
    @IBOutlet var mainTextDistantCT: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.backgroundV.backgroundColor = .pmmWhite07Color()
        self.reachTF.font = .pmmPlayFairReg42()
        self.shareTF.font = .pmmPlayFairReg15()
        
        self.letSetItBT.layer.cornerRadius = 2
        self.letSetItBT.layer.borderWidth = 0.5
        self.letSetItBT.layer.borderColor = UIColor.white.cgColor
        self.letSetItBT.titleLabel?.font = .pmmMonReg13()
        self.updateUI()
    }

    // Button Action
    @IBAction func buttonAction(_ sender: Any) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toRegister")
        {
            let destinationVC = segue.destination as! LoginAndRegisterViewController
            destinationVC.isShowLogin = false
        }
    }

    @IBAction func backToFirstScreenTour(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        if (CURRENT_DEVICE == .phone && SCREEN_MAX_LENGTH == 568.0) {
            self.mainTextDistantCT.constant = 40
        }
    }
    
}
