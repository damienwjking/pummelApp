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

class LetUsHelpViewController: BaseViewController, CLLocationManagerDelegate {
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
    
    var tags = [TagModel]()
    var arrayTags : [NSDictionary] = []
    var tagIdsArray : NSMutableArray = []
    var tagOffset: Int = 0
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
        self.helpMeReachTheCoachBT.setTitleColor(UIColor.white, for: .normal)
        self.helpMeReachTheCoachBT.backgroundColor = .pmmBrightOrangeColor()
        let cellNib = UINib(nibName: kTagCell, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: kTagCell)
        self.collectionView.backgroundColor = UIColor.clear
        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
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
        self.tagOffset = 0
        isStopGetListTag = false
        self.getListTags()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let moveScreenType = defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_1 {
            defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func getListTags() {
        if (isStopGetListTag == false) {
            TagRouter.getTagList(offset: self.tagOffset, completed: { (result, error) in
                if (error == nil) {
                    let tagList = result as! [TagModel]
                    
                    if (tagList.count == 0) {
                        self.isStopGetListTag = true
                    } else {
                        for tag in tagList {
                            if (tag.existInList(tagList: self.tags) == false) {
                                self.tags.append(tag)
                            }
                        }
                        
                        self.tagOffset += 10
                        self.collectionView.reloadData {
                            self.tagHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                            self.scrollHeightConstraint.constant = self.collectionView.frame.origin.y + self.tagHeightConstraint.constant
                        }
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.isStopGetListTag = true
                }
            }).fetchdata()
        }
    }

    @IBAction func closeLetUsHelp(_ sender: Any) {
        _ = self.presentingViewController?.childViewControllers[0] as! BaseTabBarController
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goSearching(_ sender: Any) {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            if (CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied) {
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
            } else if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
                performSegue(withIdentifier: "searching", sender: nil)
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
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Search", "Label":"Search a trainer"]
        mixpanel?.track("IOS.FindATrainer", properties: properties)
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
             performSegue(withIdentifier: "searching", sender: nil)
        } 
    }
    
    @IBAction func clickOnGender(sender: UIButton) {
        let selectMale = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = kMALEU
            // Tracker mixpanel
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Select Gender", "Label":"Select Male"]
            mixpanel?.track("IOS.FindATrainer", properties: properties)
        }
        let selectFemale = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = kFemaleU
            let mixpanel = Mixpanel.sharedInstance()
            let properties = ["Name": "Select Gender", "Label":"Select Female"]
            mixpanel?.track("IOS.FindATrainer", properties: properties)
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
            mixpanel?.track("IOS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kGYM
        }
        let selectSmall = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select SmallGroupTranning"]
            mixpanel?.track("IOS.FindATrainer", properties: properties)

            self.locationResultTF.text = kSMALLGROUPTRAINING
        }
        let selectBootcamp = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select Bootcamp"]
            mixpanel?.track("OS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kBOOTCAMP
        }
        let selectMobile = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select Mobile"]
            mixpanel?.track("IOS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kMOBILE
        }
        let selectOutdoor = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select Outdoor"]
            mixpanel?.track("IOS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kOUTDOOR
        }
        let selectAnywhere = { (action:UIAlertAction!) -> Void in
            let properties = ["Name": "Search - Select Location", "Label":"Select Anywhere"]
            mixpanel?.track("IOS.FindATrainer.Location", properties: properties)

            self.locationResultTF.text = kANYWHERE
        }
        let selectPrivateStudio = { (action:UIAlertAction!) -> Void in
            
            let properties = ["Name": "Search - Select Location", "Label":"Select PrivateStudio"]
            mixpanel?.track("IOS.FindATrainer.Location", properties: properties)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "searching")
        {
            let destimation = segue.destination as! SearchingViewController
            destimation.tagIdsArray = tagIdsArray.objectEnumerator().allObjects as NSArray
            if (self.genderResultTF.text ==  kMALEU) {
                destimation.gender = kMale
            } else if (self.genderResultTF.text ==  kFemaleU) {
                destimation.gender = kFemale
            } else {
                destimation.gender = kDontCare
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension LetUsHelpViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kTagCell, for: indexPath) as! TagCell
        self.configureCell(cell: cell, forIndexPath: indexPath as NSIndexPath)
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath as NSIndexPath)
        return self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        let tag = tags[indexPath.row]
        if (tag.selected) {
            if tagIdsArray.count < 4 {
                tagIdsArray.add(tag.tagId!)
                
                let mixpanel = Mixpanel.sharedInstance()
                let properties = ["Name": "Select Tags", "Label":"\(tag.tagTitle!)"]
                mixpanel?.track("IOS.FindATrainer", properties: properties)
            } else {
                let alertController = UIAlertController(title: nil, message: "Select just a few tags to broaden your search", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: kOk, style: UIAlertActionStyle.cancel, handler: { (_) in
                    self.tags[indexPath.row].selected = !self.tags[indexPath.row].selected
                    self.collectionView.reloadData()
                }))
                self.present(alertController, animated: true) { }
            }
        } else {
            tagIdsArray.remove(tag.tagId!)
        }
        let contentOffset = self.scrollView.contentOffset
        self.collectionView.reloadData()
        scrollView.setContentOffset(contentOffset, animated: false)
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.tagTitle
        cell.tagImage.backgroundColor = UIColor.init(hexString: tag.tagColor!)
        cell.tagBackgroundV.backgroundColor = tag.selected ? UIColor.init(hexString: tag.tagColor!) : UIColor.clear
        cell.tagNameLeftMarginConstraint.constant = tag.selected ? 8 : 25
        
    }
}

