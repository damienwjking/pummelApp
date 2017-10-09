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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.afterSearch), name: NSNotification.Name(rawValue: "AFTER_SEARCH_PAGE"), object: nil)
    }
    
    func animationIndicator() {
        self.smallIndicatorView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.medIndicatorView.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.bigIndicatorView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.smallIndicatorView.isHidden = true
                    self.medIndicatorView.isHidden = true
                    self.bigIndicatorView.isHidden = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if (self.stopAnimation != true) {
                            self.animationIndicator()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func closeSearching(sender:UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.005))
        
        self.map.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
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
        let ovlay = MKTileOverlay.init(urlTemplate: link)
        ovlay.canReplaceMapContent = true
        self.map.add(ovlay)
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
                case .restricted, .denied:
                    let alertController = UIAlertController(title: pmmNotice, message: turnOneLocationServiceApp, preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                                if let url = settingsUrl {
                                    UIApplication.shared.openURL(url as URL)
                                }
                        }
                        alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
                    // ...
                    }
                case .authorizedAlways, .authorizedWhenInUse: break
            default: break
            }
        } else {
            let alertController = UIAlertController(title: pmmNotice, message: turnOneLocationServiceSystem, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                self.dismiss(animated: false, completion: { 
                    
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
        PMHelper.actionWithDelaytime(delayTime: 6) { (_) in
            if (self.getResultSearch == true) {
                self.stopAnimation = true
            } else {
                self.delayCheck()
            }
        }
    }
    
    func afterSearch() {
        let presentViewController = self.presentingViewController
        
        if (presentViewController != nil) {
            self.dismiss(animated: true, completion: {
                presentViewController!.dismiss(animated: true, completion: nil)
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
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.searchDetail = [kGender:self.gender, "tagIds":self.tagIdsArray,
                        kLat:(self.locationManager.location?.coordinate.latitude)!,
                        kLong:(self.locationManager.location?.coordinate.longitude)!,
                        kState: state,
                        kCity: city]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_PM_FIRST_SEARCH_COACH), object: nil)
                }
            })
        }
    }
}
