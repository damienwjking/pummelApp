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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.afterSearch), name: "AFTER_SEARCH_PAGE", object: nil)
    }
    
    func animationIndicator() {
        self.smallIndicatorView.isHidden = false
        let seconds = 0.5
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            self.medIndicatorView.isHidden = false
            let seconds = 0.5
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                
                self.bigIndicatorView.isHidden = false
                let seconds = 0.5
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    
                    self.smallIndicatorView.isHidden = true
                    self.medIndicatorView.isHidden = true
                    self.bigIndicatorView.isHidden = true
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
        self.dismissViewControllerAnimated(animated: true, completion: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        self.bigIndicatorView.isHidden = true
        self.medIndicatorView.isHidden = true
        self.smallIndicatorView.isHidden = true
        
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
                    let alertController = UIAlertController(title: pmmNotice, message: turnOneLocationServiceApp, preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                                if let url = settingsUrl {
                                    UIApplication.sharedApplication().openURL(url)
                                }
                        }
                        alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
                    // ...
                    }
                case .AuthorizedAlways, .AuthorizedWhenInUse: break
            default: break
            }
        } else {
            let alertController = UIAlertController(title: pmmNotice, message: turnOneLocationServiceSystem, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                self.dismissViewControllerAnimated(animated: false, completion: { 
                    
                })
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true) {
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
    
    func afterSearch() {
        let presentViewController = self.presentingViewController
        
        if (presentViewController != nil) {
            self.dismissViewControllerAnimated(animated: true, completion: {
                presentViewController!.dismissViewControllerAnimated(animated: true, completion: nil)
            })
        }
    }
    
    func search() {
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
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.searchDetail = [kGender:self.gender, "tagIds":self.tagIdsArray,
                        kLat:(self.locationManager.location?.coordinate.latitude)!,
                        kLong:(self.locationManager.location?.coordinate.longitude)!,
                        kState: state,
                        kCity: city]
                    
                    NotificationCenter.default.postNotificationName(k_PM_FIRST_SEARCH_COACH, object: nil)
                }
            })
        }
    }
}
