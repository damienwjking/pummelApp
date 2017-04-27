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
    
    let SCREEN_MAX_LENGTH = max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
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
        self.helpMeReachTheCoachBT.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.helpMeReachTheCoachBT.backgroundColor = .pmmBrightOrangeColor()
        let cellNib = UINib(nibName: kTagCell, bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: kTagCell)
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        self.sizingCell?.isSearch = true
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 8)
        } else {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        
        self.flowLayout.isSearch = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        offset = 0
        isStopGetListTag = false
        self.getListTags()
    }
    
    func getListTags() {
        if (isStopGetListTag == false) {
            var listTagsLink = kPMAPI_TAG_OFFSET
            listTagsLink.appendContentsOf(String(offset))
            Alamofire.request(.GET, listTagsLink)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    self.arrayTags = JSON as! [NSDictionary]
                    if (self.arrayTags.count > 0) {
                        for i in 0 ..< self.arrayTags.count {
                            let tagContent = self.arrayTags[i]
                            let tag = Tag()
                            tag.name = tagContent[kTitle] as? String
                            tag.tagId = String(format:"%0.f", tagContent[kId]!.doubleValue)
                            tag.tagColor = self.getRandomColorString()
                            self.tags.append(tag)
                        }
                        self.offset += 10
                        self.collectionView.reloadData({ 
                            self.tagHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize().height
                            self.scrollHeightConstraint.constant = self.collectionView.frame.origin.y + self.tagHeightConstraint.constant
                        })
                    } else {
                        self.isStopGetListTag = true
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
        } else
        {
            self.isStopGetListTag = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let moveScreenType = defaults.objectForKey(k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_1 {
            defaults.setObject(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        }
    }

    @IBAction func closeLetUsHelp(sender:UIButton!) {
        let tabbarVC = self.presentingViewController?.childViewControllers[0] as! BaseTabBarController
        let findVC = tabbarVC.viewControllers![2] as! FindViewController
        findVC.showLetUsHelp = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func goSearching(sender:UIButton!) {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            if (CLLocationManager.authorizationStatus() == .Restricted || CLLocationManager.authorizationStatus() == .Denied) {
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
            } else if (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways) {
                performSegueWithIdentifier("searching", sender: nil)
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
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Search", "Label":"Search a trainer"]
        mixpanel.track("IOS.FindATrainer", properties: properties)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedWhenInUse) {
             performSegueWithIdentifier("searching", sender: nil)
        } 
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "searching")
        {
            let destimation = segue.destinationViewController as! SearchingViewController
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTagCell, forIndexPath: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        return self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        let tag = tags[indexPath.row]
        if (tag.selected) {
            if tagIdsArray.count < 4 {
                tagIdsArray.addObject(tag.tagId!)
                
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Select Tags", "Label":"\(tag.name!)"]
                mixpanel.track("IOS.FindATrainer", properties: properties)
            } else {
                let alertController = UIAlertController(title: nil, message: "Select just a few tags to broaden your search", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: kOk, style: UIAlertActionStyle.Cancel, handler: { (_) in
                    self.tags[indexPath.row].selected = !self.tags[indexPath.row].selected
                    self.collectionView.reloadData()
                }))
                self.presentViewController(alertController, animated: true) { }
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
        cell.tagBackgroundV.backgroundColor = tag.selected ? UIColor.init(hexString: tag.tagColor!) : UIColor.clearColor()
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

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kMALEU, style: UIAlertActionStyle.Default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: kFemaleU, style: UIAlertActionStyle.Default, handler: selectFemale))
        alertController.addAction(UIAlertAction(title: kDontCareUp, style: UIAlertActionStyle.Default, handler: selectDontCare))
        
        self.presentViewController(alertController, animated: true) { }
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
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kGYM, style: UIAlertActionStyle.Default, handler: selectGym))
        alertController.addAction(UIAlertAction(title: kSMALLGROUPTRAINING, style: UIAlertActionStyle.Default, handler: selectSmall))
        alertController.addAction(UIAlertAction(title: kBOOTCAMP, style: UIAlertActionStyle.Default, handler: selectBootcamp))
        alertController.addAction(UIAlertAction(title: kMOBILE, style: UIAlertActionStyle.Default, handler: selectMobile))
        alertController.addAction(UIAlertAction(title: kOUTDOOR, style: UIAlertActionStyle.Default, handler: selectOutdoor))
        alertController.addAction(UIAlertAction(title: kPRIVATESTUDIO, style: UIAlertActionStyle.Default, handler: selectPrivateStudio))
        alertController.addAction(UIAlertAction(title: kANYWHERE, style: UIAlertActionStyle.Default, handler: selectAnywhere))
        self.presentViewController(alertController, animated: true) { }
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
        UIView.animateWithDuration(0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

extension UITableView {
    func reloadData(completion: ()->()) {
        UIView.animateWithDuration(0, animations: { self.reloadData() })
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

