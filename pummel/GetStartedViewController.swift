//
//  GetStartedViewController.swift
//  pummel
//
//  Created by Damien King on 29/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class GetStartedViewController: UIViewController {
    
   
    /*
// add this right above your viewDidLoad function...
let transitionManager = TransitionManager()

override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

// this gets a reference to the screen that we're about to transition to
let toViewController = segue.destinationViewController as UIViewController

// instead of using the default transition animation, we'll ask
// the segue to use our custom TransitionManager object to manage the transition animation
toViewController.transitioningDelegate = self.transitionManager

}
*/
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // test almo
        
        let userEmail = "damien@pummel.me"
        let userPassword = "vo33fvfi"
        
        
        Alamofire.request(.POST, "http://52.8.5.161/api/users/login", parameters: ["email":userEmail, "password":userPassword])
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }

        
        
    }
    
    @IBOutlet weak var ButtonGetStarted: UIButton!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}