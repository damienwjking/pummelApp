//
//  SearchingViewController.swift
//  pummel
//
//  Created by Bear Daddy on 6/27/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class SearchingViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var bigCircleFirstIMV : UIImageView!
    @IBOutlet var bigCircleSecondIMV : UIImageView!
    @IBOutlet var bigCircleThirdIMV : UIImageView!
    @IBOutlet var bigCircleFourthIMV : UIImageView!
    
    @IBOutlet var medCircleFirstIMV : UIImageView!
    @IBOutlet var medCircleSecondIMV : UIImageView!
    @IBOutlet var medCircleThirdIMV : UIImageView!
    @IBOutlet var medCircleFourthIMV : UIImageView!

    @IBOutlet var smallCircleFirstIMV : UIImageView!
    @IBOutlet var smallCircleSecondIMV : UIImageView!
    @IBOutlet var smallCircleThirdIMV : UIImageView!
    @IBOutlet var smallCircleFourthIMV : UIImageView!
    
    @IBOutlet var firstLocationView : UIView!
    @IBOutlet var secondLocationView : UIView!
    @IBOutlet var thirdLocationView : UIView!
    @IBOutlet var fourthLocationView : UIView!

    @IBOutlet var smallIndicatorView : UIView!
    @IBOutlet var medIndicatorView : UIView!
    @IBOutlet var bigIndicatorView : UIView!

    @IBOutlet var overlayView : UIView!
    @IBOutlet var findFinessTF : UILabel!
    
    @IBOutlet var map: MKMapView!
    
    var gender: String!
    var tagIdsArray: NSArray!
    var locationManager: CLLocationManager!
    var stopAnimation: Bool!
    let orangeColor = UIColor.pmmBrightOrangeColor()
    
    @IBOutlet var backgroundLogo : UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func animationIndicator() {
        self.smallIndicatorView.hidden = false
        let seconds = 0.5
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            self.medIndicatorView.hidden = false
            let seconds = 0.5
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                
                self.bigIndicatorView.hidden = false
                let seconds = 0.5
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    
                    self.smallIndicatorView.hidden = true
                    self.medIndicatorView.hidden = true
                    self.bigIndicatorView.hidden = true
                    let seconds = 0.5
                    let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        if (self.stopAnimation != true) {
                             self.animationIndicator()
                        }
                    })

                })
            })
            
        })
        
    }
    
    @IBAction func closeSearching(sender:UIButton!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.005))
        
        self.map.setRegion(region, animated: true)
        
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
           return MKTileOverlayRenderer.init(overlay: overlay)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        bigCircleFirstIMV.layer.cornerRadius = 11
        bigCircleSecondIMV.layer.cornerRadius = 11
        bigCircleThirdIMV.layer.cornerRadius = 11
        bigCircleFourthIMV.layer.cornerRadius = 11
        bigCircleFirstIMV.clipsToBounds = true
        bigCircleSecondIMV.clipsToBounds = true
        bigCircleThirdIMV.clipsToBounds = true
        bigCircleFourthIMV.clipsToBounds = true
        bigCircleFirstIMV.layer.borderWidth = 0.5
        bigCircleSecondIMV.layer.borderWidth = 0.5
        bigCircleThirdIMV.layer.borderWidth = 0.5
        bigCircleFourthIMV.layer.borderWidth = 0.5
        bigCircleFirstIMV.layer.borderColor =  orangeColor.CGColor
        bigCircleSecondIMV.layer.borderColor =  orangeColor.CGColor
        bigCircleThirdIMV.layer.borderColor =  orangeColor.CGColor
        bigCircleFourthIMV.layer.borderColor =  orangeColor.CGColor
        
        medCircleFirstIMV.layer.cornerRadius = 7
        medCircleSecondIMV.layer.cornerRadius = 7
        medCircleThirdIMV.layer.cornerRadius = 7
        medCircleFourthIMV.layer.cornerRadius = 7
        medCircleFirstIMV.clipsToBounds = true
        medCircleSecondIMV.clipsToBounds = true
        medCircleThirdIMV.clipsToBounds = true
        medCircleFourthIMV.clipsToBounds = true
        medCircleFirstIMV.layer.borderWidth = 0.5
        medCircleSecondIMV.layer.borderWidth = 0.5
        medCircleThirdIMV.layer.borderWidth = 0.5
        medCircleFourthIMV.layer.borderWidth = 0.5
        medCircleFirstIMV.layer.borderColor =  orangeColor.CGColor
        medCircleSecondIMV.layer.borderColor =  orangeColor.CGColor
        medCircleThirdIMV.layer.borderColor =  orangeColor.CGColor
        medCircleFourthIMV.layer.borderColor =  orangeColor.CGColor
        
        smallCircleFirstIMV.layer.cornerRadius = 4
        smallCircleSecondIMV.layer.cornerRadius = 4
        smallCircleThirdIMV.layer.cornerRadius = 4
        smallCircleFourthIMV.layer.cornerRadius = 4
        smallCircleFirstIMV.clipsToBounds = true
        smallCircleSecondIMV.clipsToBounds = true
        smallCircleThirdIMV.clipsToBounds = true
        smallCircleFourthIMV.clipsToBounds = true
        smallCircleFirstIMV.backgroundColor =  orangeColor
        smallCircleSecondIMV.backgroundColor =  orangeColor
        smallCircleThirdIMV.backgroundColor =  orangeColor
        smallCircleFourthIMV.backgroundColor =  orangeColor
        
        backgroundLogo.layer.cornerRadius = 45
        backgroundLogo.clipsToBounds = true
        backgroundLogo.backgroundColor = orangeColor
        
        firstLocationView.hidden = true
        secondLocationView.hidden = true
        thirdLocationView.hidden = true
        fourthLocationView.hidden = true
        
        self.bigIndicatorView.alpha = 0.05
        self.medIndicatorView.alpha = 0.1
        self.smallIndicatorView.alpha = 0.15
        
        self.bigIndicatorView.layer.cornerRadius = 344/2
        self.medIndicatorView.layer.cornerRadius = 130
        self.smallIndicatorView.layer.cornerRadius = 176/2
        
        self.bigIndicatorView.clipsToBounds = true
        self.medIndicatorView.clipsToBounds = true
        self.smallIndicatorView.clipsToBounds = true
        
        self.bigIndicatorView.hidden = true
        self.medIndicatorView.hidden = true
        self.smallIndicatorView.hidden = true
        
        self.map.delegate = self
        let link = "http://tile.stamen.com/toner/{z}/{x}/{y}.png"
        let ovlay = MKTileOverlay.init(URLTemplate: link)
        ovlay.canReplaceMapContent = true
        self.map.addOverlay(ovlay)
        overlayView.alpha = 0.7
        self.findFinessTF.font = .pmmMonReg11()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            switch(CLLocationManager.authorizationStatus()) {
                case .Restricted, .Denied:
                    let alertController = UIAlertController(title: pmmNotice, message: turnOneLocationServiceApp, preferredStyle: .Alert)
                            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                                if let url = settingsUrl {
                                    UIApplication.sharedApplication().openURL(url)
                                }
                        }
                        alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                    // ...
                    }
                case .AuthorizedAlways, .AuthorizedWhenInUse: break
            default: break
            }
        } else {
            let alertController = UIAlertController(title: pmmNotice, message: turnOneLocationServiceSystem, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                self.dismissViewControllerAnimated(false, completion: { 
                    
                })
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }
        
        self.stopAnimation = false
        
        self.animationIndicator()
        
        let seconds = 9.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.stopAnimation = true
        })
        let secondsLocation = 6.0
        let delayLocation = secondsLocation * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTimeLocation = dispatch_time(DISPATCH_TIME_NOW, Int64(delayLocation))
        dispatch_after(dispatchTimeLocation, dispatch_get_main_queue(), {
            if (Int(arc4random_uniform(3) + 1) == 1) {
                self.firstLocationView.hidden = false
                self.thirdLocationView.hidden = false
            } else if (Int(arc4random_uniform(3) + 1) == 2) {
                self.secondLocationView.hidden = false
                self.thirdLocationView.hidden = false
            } else {
                self.firstLocationView.hidden = false
                self.thirdLocationView.hidden = false
                self.fourthLocationView.hidden = false
                self.secondLocationView.hidden = false
            }
        })
        
        self.search()
    }
    
    func search() {
        var prefix = kPMAPICOACH_SEARCH
        if (gender != kDontCare) {
           prefix.appendContentsOf("?gender=".stringByAppendingString(gender).stringByAppendingString("&"))
        } else {
            prefix.appendContentsOf("?")
        }
    
        for id in tagIdsArray {
            prefix.appendContentsOf("tagIds=".stringByAppendingString(id as! String))
        }
        
        // TODO: Get current lat & long and add to appDelegate.searchDetail = [kGender:self.gender, "tagIds":self.tagIdsArray, "lat": currentlat, "long", currentlong]
        
        prefix.appendContentsOf("&limit=6&offset=0")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.searchDetail = [kGender:self.gender, "tagIds":self.tagIdsArray]
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    if (response.result.value == nil) {return}
                    if (self.stopAnimation == true) {
                        let presentingViewController = self.presentingViewController
                        self.dismissViewControllerAnimated(false, completion: {
                            let tabbarVC = presentingViewController!.presentingViewController?.childViewControllers[0] as! BaseTabBarController
                            let findVC = tabbarVC.viewControllers![2] as! FindViewController
                            findVC.arrayResult.removeAll()
                            findVC.refined = true
                            findVC.arrayResult = response.result.value  as! [NSDictionary]
                            findVC.viewDidLayoutSubviews()
                            findVC.showLetUsHelp = false
                            findVC.viewDidLayoutSubviews()
        
                            presentingViewController!.dismissViewControllerAnimated(true, completion: {})
                        })
                    } else {
                        let secondsWait = 6.0
                        let delay = secondsWait * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                            let presentingViewController = self.presentingViewController
                            self.dismissViewControllerAnimated(false, completion: {
                                let tabbarVC = presentingViewController!.presentingViewController?.childViewControllers[0] as! BaseTabBarController
                                let findVC = tabbarVC.viewControllers![2] as! FindViewController
                                findVC.arrayResult.removeAll()
                                findVC.refined = true
                                findVC.arrayResult = response.result.value as! [NSDictionary]
                                findVC.showLetUsHelp = false
                                findVC.viewDidLayoutSubviews()
                                presentingViewController!.dismissViewControllerAnimated(true, completion: {})
                            })
                        })
                        
                    }
                } else if response.response?.statusCode == 401 {
                    let alertController = UIAlertController(title: pmmNotice, message: cookieExpiredNotice, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // TODO: LOGOUT
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                    
                }
        }
    }
}
