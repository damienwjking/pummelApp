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

class SearchingViewController: BaseViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var smallIndicatorView : UIView!
    @IBOutlet var medIndicatorView : UIView!
    @IBOutlet var bigIndicatorView : UIView!

    @IBOutlet var overlayView : UIView!
    @IBOutlet var findFinessTF : UILabel!
    
    @IBOutlet var map: MKMapView!
    
    var gender: String!
    var tagIdsArray: NSArray! = []
    var locationManager: CLLocationManager!
    var stopAnimation: Bool!
    let orangeColor = UIColor.pmmBrightOrangeColor()
    var getResultSearch : Bool = false
    
    @IBOutlet var backgroundLogo : UIImageView!

    var limit: Int = 0
    var offset: Int = 0
    
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
        
        backgroundLogo.layer.cornerRadius = 45
        backgroundLogo.clipsToBounds = true
        backgroundLogo.backgroundColor = orangeColor
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
        
        self.delayCheck()
        
        self.search()
    }
    
    func delayCheck() {
        let seconds = 6.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            if (self.getResultSearch == true) {
                self.stopAnimation = true
            } else {
                self.delayCheck()
            }
        })

    }
    
    func search() {
        var prefix = kPMAPICOACH_SEARCH
        let limitParams = String(format: "?%@=30&%@=0", kLimit, kOffset)
        prefix.appendContentsOf(limitParams)
        if (gender != kDontCare) {
            prefix.appendContentsOf("&gender=".stringByAppendingString(gender).stringByAppendingString("&"))
        } else {
            prefix.appendContentsOf("&")
            
        }
    
        for id in tagIdsArray {
            prefix.appendContentsOf("&")

            prefix.appendContentsOf("tagIds=".stringByAppendingString(id as! String))
             prefix.appendContentsOf("&")
        }
        let coordinateParams = String(format: "%@=%f&%@=%f", kLong, (locationManager.location?.coordinate.longitude)!, kLat, (locationManager.location?.coordinate.latitude)!)
        prefix.appendContentsOf(coordinateParams)
        
        // TODO: Get current state & current city
        // let state =
        // let city =
        // let stateCity =  String(format: "&%@=%@&%@=%@", "state", state, "city", city)
        
        let geoCoder = CLGeocoder()
        if locationManager.location != nil {
            geoCoder.reverseGeocodeLocation(locationManager.location!, completionHandler: { (placemarks, error) -> Void in
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                if ((placeMark) != nil) {
                    var state = ""
                    var city = ""
                    if ((placeMark.administrativeArea) != nil) {
                        if placeMark.locality != nil {
                            city = placeMark.locality!
                        } else if placeMark.subAdministrativeArea != nil {
                            city = placeMark.subAdministrativeArea!
                        }
                        state = placeMark.administrativeArea!
                    }
                }
            })
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.searchDetail = [kGender:self.gender, "tagIds":self.tagIdsArray, "lat":(locationManager.location?.coordinate.longitude)!, "long":(locationManager.location?.coordinate.latitude)!]
        
        
        
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    if (response.result.value == nil) {return}
                   // if (self.stopAnimation == true) {
                        self.getResultSearch = true
                        let presentingViewController = self.presentingViewController
                    let secondsWait = 2.0
                    let delay = secondsWait * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {

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
                    });
//                    } else {
//                        let secondsWait = 6.0
//                        let delay = secondsWait * Double(NSEC_PER_SEC)  // nanoseconds per seconds
//                        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//                        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
//                            let presentingViewController = self.presentingViewController
//                            self.dismissViewControllerAnimated(false, completion: {
//                                let tabbarVC = presentingViewController!.presentingViewController?.childViewControllers[0] as! BaseTabBarController
//                                let findVC = tabbarVC.viewControllers![2] as! FindViewController
//                                findVC.arrayResult.removeAll()
//                                findVC.refined = true
//                                findVC.arrayResult = response.result.value as! [NSDictionary]
//                                findVC.showLetUsHelp = false
//                                findVC.viewDidLayoutSubviews()
//                                presentingViewController!.dismissViewControllerAnimated(true, completion: {})
//                            })
//                        })
//                        
//                    }
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
