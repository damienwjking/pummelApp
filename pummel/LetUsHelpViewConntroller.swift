//
//  LetUsHelpViewConntroller.swift
//  pummel
//
//  Created by Bear Daddy on 6/27/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import Mixpanel

class LetUsHelpViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    @IBOutlet var letUsHelpTF : UILabel!
    @IBOutlet var letUsHelpDetailTF : UILabel!
    @IBOutlet var genderTF : UILabel!
    @IBOutlet var genderResultTF: UILabel!
    @IBOutlet var locationTF : UILabel!
    @IBOutlet var locationResultTF: UILabel!
    @IBOutlet var helpMeReachTheCoachBT : UIButton!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet weak var tagHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    var sizingCell: TagCell?
    
    var tags = [Tag]()
    var arrayTags : [NSDictionary] = []
    var tagIdsArray : NSMutableArray = []
    var offset: Int = 0
    var isStopGetListTag : Bool = false
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.letUsHelpTF.font = .pmmPlayFairReg33()
        self.letUsHelpDetailTF.font = .pmmPlayFairReg15()
        self.genderTF.font = .pmmMonReg11()
        self.genderResultTF.font = .pmmMonReg11()
        self.locationTF.font = .pmmMonReg11()
        self.locationResultTF.font = .pmmMonReg11()
        self.helpMeReachTheCoachBT.layer.cornerRadius = 2
        self.helpMeReachTheCoachBT.layer.borderWidth = 0.5
        self.helpMeReachTheCoachBT.titleLabel?.font = .pmmMonReg11()
        self.helpMeReachTheCoachBT.setTitleColor(UIColor.white, for: .Normal)
        self.helpMeReachTheCoachBT.backgroundColor = .pmmBrightOrangeColor()
        let cellNib = UINib(nibName: kTagCell, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: kTagCell)
        self.collectionView.backgroundColor = UIColor.clear
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        self.sizingCell?.isSearch = true
        
        if (CURRENT_DEVICE == .phone && SCREEN_MAX_LENGTH == 568.0) {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 8)
        } else {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        
        self.flowLayout.isSearch = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        offset = 0
        isStopGetListTag = false
        self.getListTags()
    }
    
    func getListTags() {
        if (isStopGetListTag == false) {
            var listTagsLink = kPMAPI_TAG_OFFSET
            listTagsLink.append(String(offset))
            Alamofire.request(.GET, listTagsLink)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    self.arrayTags = JSON as! [NSDictionary]
                    if (self.arrayTags.count > 0) {
                        for i in 0 ..< self.arrayTags.count {
                            let tagContent = self.arrayTags[i]
                            let tag = Tag()
                            tag.name = tagContent[kTitle] as? String
                            tag.tagId = String(format:"%0.f", (tagContent[kId]! as AnyObject).doubleValue)
                            tag.tagColor = self.getRandomColorString()
                            self.tags.append(tag)
                        }
                        self.offset += 10
                        self.collectionView.reloadData({ 
                            self.tagHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                            self.scrollHeightConstraint.constant = self.collectionView.frame.origin.y + self.tagHeightConstraint.constant
                        })
                    } else {
                        self.isStopGetListTag = true
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(String(describing: error))")
                    }
            }
        } else
        {
            self.isStopGetListTag = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated: animated)
        
        let defaults = UserDefaults.standard
        let moveScreenType = defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_1 {
            defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        }
    }

    @IBAction func closeLetUsHelp(sender:UIButton!) {
        let tabbarVC = self.presentingViewController?.childViewControllers[0] as! BaseTabBarController
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func goSearching(sender:UIButton!) {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            if (CLLocationManager.authorizationStatus() == .Restricted || CLLocationManager.authorizationStatus() == .Denied) {
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
            } else if (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways) {
                performSegue(withIdentifier: "searching", sender: nil)
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
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Search", "Label":"Search a trainer"]
        mixpanel.track("IOS.FindATrainer", properties: properties)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedWhenInUse) {
             performSegue(withIdentifier: "searching", sender: nil)
        } 
    }
    
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "searching")
        {
            let destimation = segue.destination as! SearchingViewController
            destimation.tagIdsArray = tagIdsArray.objectEnumerator().allObjects as? [String]
            if (self.genderResultTF.text ==  kMALEU) {
                 destimation.gender = kMale
            } else if (self.genderResultTF.text ==  kFemaleU) {
                destimation.gender = kFemale
            } else {
                destimation.gender = kDontCare
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTagCell, for: indexPath) as! TagCell
        self.configureCell(cell, for: indexPath)
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, for: indexPath)
        return self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        let tag = tags[indexPath.row]
        if (tag.selected) {
            if tagIdsArray.count < 4 {
                tagIdsArray.addObject(tag.tagId!)
                
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Select Tags", "Label":"\(tag.name!)"]
                mixpanel.track("IOS.FindATrainer", properties: properties)
            } else {
                let alertController = UIAlertController(title: nil, message: "Select just a few tags to broaden your search", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: kOk, style: UIAlertActionStyle.cancel, handler: { (_) in
                    self.tags[indexPath.row].selected = !self.tags[indexPath.row].selected
                    self.collectionView.reloadData()
                }))
                self.present(alertController, animated: true) { }
            }
        } else {
            tagIdsArray.removeObject(tag.tagId!)
        }
        let contentOffset = self.scrollView.contentOffset 
        self.collectionView.reloadData()
        scrollView.setContentOffset(contentOffset, animated: false)
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagImage.backgroundColor = UIColor.init(hexString: tag.tagColor!)
        cell.tagBackgroundV.backgroundColor = tag.selected ? UIColor.init(hexString: tag.tagColor!) : UIColor.clear
        cell.tagNameLeftMarginConstraint.constant = tag.selected ? 8 : 25
        
    }
    
    
    @IBAction func clickOnGender(sender: UIButton) {
        let selectMale = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = kMALEU
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Select Gender", "Label":"Select Male"]
            mixpanel.track("IOS.FindATrainer", properties: properties)
        }
        let selectFemale = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = kFemaleU
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Select Gender", "Label":"Select Female"]
            mixpanel.track("IOS.FindATrainer", properties: properties)
        }
        let selectDontCare = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = kDontCareUp
        }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kMALEU, style: .default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: kFemaleU, style: .default, handler: selectFemale))
        alertController.addAction(UIAlertAction(title: kDontCareUp, style: .default, handler: selectDontCare))
        
        self.present(alertController, animated: true) { }
    }
    
    @IBAction func clickOnLocation(sender: UIButton) {
        let mixpanel = Mixpanel.sharedInstance()
        let selectGym = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select Gym"]
            mixpanel.track("IOS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kGYM
        }
        let selectSmall = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select SmallGroupTranning"]
            mixpanel.track("IOS.FindATrainer", properties: properties)

            self.locationResultTF.text = kSMALLGROUPTRAINING
        }
        let selectBootcamp = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select Bootcamp"]
            mixpanel.track("OS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kBOOTCAMP
        }
        let selectMobile = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select Mobile"]
            mixpanel.track("IOS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kMOBILE
        }
        let selectOutdoor = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select Outdoor"]
            mixpanel.track("IOS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kOUTDOOR
        }
        let selectAnywhere = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select Anywhere"]
            mixpanel.track("IOS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kANYWHERE
        }
        let selectPrivateStudio = { (action:UIAlertAction!) -> Void in
            
            let properties = ["Name": "Search - Select Location", "Label":"Select PrivateStudio"]
            mixpanel.track("IOS.FindATrainer.Location", properties: properties)
            self.locationResultTF.text = kPRIVATESTUDIO
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kGYM, style: .default, handler: selectGym))
        alertController.addAction(UIAlertAction(title: kSMALLGROUPTRAINING, style: .default, handler: selectSmall))
        alertController.addAction(UIAlertAction(title: kBOOTCAMP, style: .default, handler: selectBootcamp))
        alertController.addAction(UIAlertAction(title: kMOBILE, style: .default, handler: selectMobile))
        alertController.addAction(UIAlertAction(title: kOUTDOOR, style: .default, handler: selectOutdoor))
        alertController.addAction(UIAlertAction(title: kPRIVATESTUDIO, style: .default, handler: selectPrivateStudio))
        alertController.addAction(UIAlertAction(title: kANYWHERE, style: .default, handler: selectAnywhere))
        self.present(alertController, animated: true) { }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func getRandomColorString() -> String{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed*255), Int(randomGreen*255),Int(randomBlue*255),255)
    }
}

extension UICollectionView {
    func reloadData(completion: ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

extension UITableView {
    func reloadData(completion: ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

extension Array {
    func randomElement() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.startIndex.advancedBy(1)
            let hexColor = hexString.substringFromIndex(start)
            
            if hexColor.characters.count == 8 {
                let scanner = NSScanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexLongLong(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    func randomAString()-> String {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed*255), Int(randomGreen*255),Int(randomBlue*255),255)
    }
}

