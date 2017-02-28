//
//  Find.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
// Find an expert view


import UIKit
import UIColor_FlatColors
import Cartography
import ReactiveUI
import Alamofire
import Mixpanel

class FindViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout{
    var showLetUsHelp: Bool!
    var loadCardsFromXib = true
    var resultIndex = 0
    var resultPage : Int = 30
    var coachTotalDetail: NSDictionary!
    var arrayResult : [NSDictionary] = []
    var arrayTags : NSArray!
    var stopSearch: Bool = false
    var widthCell : CGFloat = 0.0
    @IBOutlet weak var noResultLB: UILabel!
    @IBOutlet weak var noResultContentLB: UILabel!
    @IBOutlet weak var refineSearchBT: UIButton!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLetUsHelp = false
        self.navigationController!.navigationBar.translucent = false
        
        self.setupCollectionView()
        
        noResultLB.font = .pmmPlayFairReg18()
        noResultContentLB.font = .pmmMonLight13()
        refineSearchBT.titleLabel!.font = .pmmMonReg12()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let touch3DType = defaults.objectForKey(k_PM_3D_TOUCH) as! String
        if touch3DType == "3dTouch_1" {
            self.refind()
        }
        
        self.collectionView.reloadData()
    }
    
    func setupCollectionView() {
        let nibName = UINib(nibName: "CardContentView", bundle: nil)
        self.collectionView.registerNib(nibName, forCellWithReuseIdentifier: "CardView")
        
        self.widthCell = (UIScreen.mainScreen().bounds.size.width - 30)
        self.collectionViewLayout.itemSize = CGSize(width: (UIScreen.mainScreen().bounds.size.width - 40), height: (UIScreen.mainScreen().bounds.size.height - 160))
        self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(-40, 20, 0, 0)
        self.collectionViewLayout.minimumLineSpacing = 10
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
//        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        // add Swipe gesture
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeLeft))
        swipeLeftGesture.direction = .Left
        self.collectionView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeRight))
        swipeLeftGesture.direction = .Right
        self.collectionView.addGestureRecognizer(swipeRightGesture)
        
    }
    
    func carouselSwipeLeft() {
        print("swipe left")
    }
    
    func carouselSwipeRight() {
        print("swipe right")
        
    }
    
    func searchNextPage() {
        if (self.stopSearch == false) {
            self.resultPage += 30
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let aVariable = appDelegate.searchDetail as NSDictionary
            var prefix = kPMAPICOACH_SEARCH
            if ((aVariable[kGender] as! String) != kDontCare){
                prefix.appendContentsOf("?gender=".stringByAppendingString((aVariable[kGender] as! String)).stringByAppendingString("&"))
            } else {
                prefix.appendContentsOf("?")
            }
            let tagIdsArray = aVariable["tagIds"] as! NSArray
            for id in tagIdsArray {
                prefix.appendContentsOf("tagIds=".stringByAppendingString(id as! String))
                prefix.appendContentsOf("&")
            }
            
            prefix.appendContentsOf("limit=30")
            prefix.appendContentsOf("&offset=".stringByAppendingString(String(resultPage)))
            let coordinateParams = String(format: "&%@=%f&%@=%f", kLong, aVariable[kLong] as! Float, kLat, aVariable[kLat] as! Float)
            prefix.appendContentsOf(coordinateParams)
            
            let stateCity =  String(format: "&%@=%@&%@=%@", "state",  aVariable[kState] as! String, "city", (aVariable[kCity] as! String).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            prefix.appendContentsOf(stateCity)
            
            Alamofire.request(.GET, prefix)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        if ((response.result.value as! NSArray).count == 0) {
                            self.stopSearch = true
                        } else {
                            let rArray = response.result.value as! [NSDictionary]
                            self.arrayResult += rArray
                            
                            self.collectionView.reloadData()
                        }
                    }
            }
        } else {
            print("no more resul")
        }
    }
    
    func colorForName(name: String) -> UIColor {
        let sanitizedName = name.stringByReplacingOccurrencesOfString(" ", withString: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.performSelector(Selector(selector)).takeUnretainedValue() as! UIColor
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.title = "RESULTS"
        
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let selectedImage = UIImage(named: "search")
        self.tabBarItem.image = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("SHOW_SEARCH_AFTER_REGISTER")) {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "SHOW_SEARCH_AFTER_REGISTER")
             performSegueWithIdentifier("letUsHelp", sender: nil)
        } else {
            if (showLetUsHelp == true) {
                performSegueWithIdentifier("letUsHelp", sender: nil)
            }
        }

        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"CLIENTS", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FindViewController.btnClientClick))
        } else {
            self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"COACHES", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FindViewController.btnCoachsClick))
        }
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FindViewController.refind), name: "SELECTED_MIDDLE_TAB", object: nil)
        
        self.stopSearch = false
        self.resultPage = 30
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "letUsHelp") {
        } else if (segue.identifier == kGoConnect) {
            let destination = segue.destinationViewController as! ConnectViewController
            let totalDetail = arrayResult[sender.tag]
            destination.coachDetail = totalDetail[kUser] as! NSDictionary
        } else if (segue.identifier == kSendMessageConnection) {
            let destination = segue.destinationViewController as! ChatMessageViewController
            
            let coachDetail = (sender as! NSArray)[0]
            let message = (sender as! NSArray)[1] as! String
            
            destination.coachName = ((coachDetail[kFirstname] as! String).stringByAppendingString(" ")).uppercaseString
            destination.typeCoach = true
            destination.coachId = String(format:"%0.f", coachDetail[kId]!!.doubleValue)
            destination.userIdTarget =  String(format:"%0.f", coachDetail[kId]!!.doubleValue)
            destination.preMessage = message
        } else if (segue.identifier == kGoProfile) {
            let destination = segue.destinationViewController as! CoachProfileViewController
            let totalDetail = sender as! NSDictionary
            destination.coachDetail = totalDetail[kUser] as! NSDictionary
            destination.coachTotalDetail = totalDetail
            
            if destination.coachDetail != nil {
                if let firstName = destination.coachDetail[kFirstname] as? String {
                    // Tracker mixpanel
                    let mixpanel = Mixpanel.sharedInstance()
                    let properties = ["Name": "Profile Is Clicked", "Label":"\(firstName.uppercaseString)"]
                    mixpanel.track("IOS.ClickOnProfile", properties: properties)
                }
            }
        }
    }

    @IBAction func refind() {
        self.resultIndex = 0
        performSegueWithIdentifier("letUsHelp", sender: nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Refine"]
        mixpanel.track("IOS.Search", properties: properties)
    }
    
    func btnClientClick() {
        self.performSegueWithIdentifier("gotoClient", sender: nil)
    }
    
    func btnCoachsClick() {
        self.performSegueWithIdentifier("gotoCoachs", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            self.collectionView.hidden = ((self.arrayResult.count > 0) == false)
            
            return self.arrayResult.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardView", forIndexPath: indexPath) as! CardViewCell
            cell.clipsToBounds = false
            
            let cellIndex = indexPath.row
            if (cellIndex == self.arrayResult.count - 1) {
                self.searchNextPage()
            }
            
            coachTotalDetail = arrayResult[cellIndex]
            let coachDetail = coachTotalDetail[kUser] as! NSDictionary
            let coachListTags = coachDetail[kTags] as! NSArray
            
            cell.cardView.tags.removeAll()
            for i in 0 ..< coachListTags.count {
                let tagContent = coachListTags[i] as! NSDictionary
                let tag = Tag()
                tag.name = tagContent[kTitle] as? String
                cell.cardView.tags.append(tag)
            }
            cell.cardView.collectionView.reloadData()
            
            cell.cardView.avatarIMV.image = nil
            cell.cardView.translatesAutoresizingMaskIntoConstraints = false
            cell.cardView.backgroundColor = cell.cardView.backgroundColor
            cell.cardView.connectV.layer.cornerRadius = 50
            cell.cardView.connectV.clipsToBounds = true
            cell.cardView.nameLB.font = .pmmPlayFairReg24()
            if !(coachDetail[kLastName] is NSNull) {
                cell.cardView.nameLB.text = ((coachDetail[kFirstname] as! String) .stringByAppendingString(" ")) .stringByAppendingString(coachDetail[kLastName] as! String)
            } else {
                cell.cardView.nameLB.text = (coachDetail[kFirstname] as! String)
            }
            
            cell.cardView.addressLB.font = .pmmPlayFairReg11()
            if !(coachTotalDetail[kServiceArea] is NSNull) {
                cell.cardView.addressLB.text = coachTotalDetail[kServiceArea] as? String
            }
            let postfix = widthEqual.stringByAppendingString(String(self.view.frame.size.width)).stringByAppendingString(heighEqual).stringByAppendingString(String(self.view.frame.size.width))
            if !(coachDetail[kImageUrl] is NSNull) {
                let imageLink = coachDetail[kImageUrl] as! String
                var prefix = kPMAPI
                prefix.appendContentsOf(imageLink)
                prefix.appendContentsOf(postfix)
                if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                    let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                    cell.cardView.avatarIMV.image = imageRes
                } else {
                    Alamofire.request(.GET, prefix)
                        .responseImage { response in
                            if (response.response?.statusCode == 200) {
                                let imageRes = response.result.value! as UIImage
                                cell.cardView.avatarIMV.image = imageRes
                                NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                            }
                    }
                }
            }
            
            // Business ImageView
            cell.cardView.connectV.hidden = true
            if !(coachDetail[kBusinessId] is NSNull) {
                let businessId = String(format:"%0.f", coachDetail[kBusinessId]!.doubleValue)
                var linkBusinessId = kPMAPI_BUSINESS
                linkBusinessId.appendContentsOf(businessId)
                Alamofire.request(.GET, linkBusinessId)
                    .responseJSON { response in
                        if response.response?.statusCode == 200 {
                            
                            let jsonBusiness = response.result.value as! NSDictionary
                            if !(jsonBusiness[kImageUrl] is NSNull) {
                                let businessLogoUrl = jsonBusiness[kImageUrl] as! String
                                var prefixLogo = kPMAPI
                                prefixLogo.appendContentsOf(businessLogoUrl)
                                prefixLogo.appendContentsOf(widthHeight120)
                                if (NSCache.sharedInstance.objectForKey(prefixLogo) != nil) {
                                    cell.cardView.connectV.hidden = false
                                    let imageRes = NSCache.sharedInstance.objectForKey(prefixLogo) as! UIImage
                                    cell.cardView.businessIMV.image = imageRes
                                } else {
                                    Alamofire.request(.GET, prefixLogo)
                                        .responseImage { response in
                                            if (response.response?.statusCode == 200) {
                                                cell.cardView.connectV.hidden = false
                                                let imageRes = response.result.value! as UIImage
                                                cell.cardView.businessIMV.image = imageRes
                                                NSCache.sharedInstance.setObject(imageRes, forKey: prefixLogo)
                                            }
                                    }
                                }
                            }
                        }
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return self.collectionViewLayout.itemSize
        }
        
        return CGSizeZero
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            let cellIndex = indexPath.row
            
            self.performSegueWithIdentifier(kGoProfile, sender: self.arrayResult[cellIndex])
        }
    }
}

extension UIImageView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}
