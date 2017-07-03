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

class FindViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, CardViewCellDelegate{
    var showLetUsHelp: Bool!
    var loadCardsFromXib = true
    var resultIndex = 0
    var coachTotalDetail: NSDictionary!
    var arrayResult : [NSDictionary] = []
    var arrayTags : NSArray!
    var stopSearch: Bool = false
    var widthCell : CGFloat = 0.0
    var currentOffset: CGPoint = CGPointZero
    var touchPoint: CGPoint = CGPointZero
    var loadmoreTime = 1
    
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
        refineSearchBT.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let moveScreenType = defaults.objectForKey(k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_1 {
            self.refind()
        }
        
        self.collectionView.reloadData { 
            self.checkPlayVideoOnPresentCell()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        for indexPath in self.collectionView.indexPathsForVisibleItems() {
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! CardViewCell
            
            cell.stopPlayVideo()
        }
    }
    
    func setupCollectionView() {
        // register cell
        let nibName = UINib(nibName: "CardContentView", bundle: nil)
        self.collectionView.registerNib(nibName, forCellWithReuseIdentifier: "CardView")
        
        let noResultNibName = UINib(nibName: "CardContentNoResult", bundle: nil)
        self.collectionView.registerNib(noResultNibName, forCellWithReuseIdentifier: "SearchNoCoach")
        
        // setup cell
        self.widthCell = (UIScreen.mainScreen().bounds.size.width - 30)
        self.collectionViewLayout.itemSize = CGSize(width: (UIScreen.mainScreen().bounds.size.width - 40), height: (UIScreen.mainScreen().bounds.size.height - 160))
        self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(-40, 20, 0, 0)
        self.collectionViewLayout.minimumLineSpacing = 10
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func checkPlayVideoOnPresentCell() {
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(Int64(NSEC_PER_SEC)) * 0.1))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            // Play video on present cell
            let cellIndex = Int(round(self.collectionView.contentOffset.x / self.widthCell))
            let indexPath = NSIndexPath(forRow: cellIndex, inSection: 0)
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? CardViewCell
            if (cell != nil) {
                // Show video layout
                let coachDetail = self.arrayResult[cellIndex]
                let userDetail = coachDetail[kUser] as! NSDictionary
                let videoURL = userDetail[kVideoURL] as? String
                if (videoURL != nil && videoURL!.isEmpty == false) {
                    cell?.playVideoButton.hidden = false
                    cell?.playVideoButton.userInteractionEnabled = false
                }
                
                // Show video layout < 23/06
//                let coachDetail = self.arrayResult[cellIndex]
//                let videoURL = coachDetail[kVideoURL] as? String
//                if (videoURL != nil && videoURL!.isEmpty == false) {
//                    cell!.showVideo(videoURL!)
//                }
                
                // Test
//                let videoURL = "https://pummel-prod.s3.amazonaws.com/videos/1497421626868-0.mov"
//                if (videoURL.isEmpty == false) {
//                    cell!.showVideo(videoURL)
//                }
            }
            
            // Tracking show video
            if (cellIndex < self.arrayResult.count) {
                let coachDetail = self.arrayResult[cellIndex]
                let coachID = String(format: "%.0f", coachDetail[kUserId] as! Double)
                TrackingPMAPI.sharedInstance.trackingProfileCard(coachID)
            }
            
            // Remove video layer
            if (cellIndex > 0) {
                let preCellIndex = NSIndexPath(forRow: cellIndex - 1, inSection: 0)
                let preCell = self.collectionView.cellForItemAtIndexPath(preCellIndex) as? CardViewCell
                if (preCell != nil) {
                    preCell!.stopPlayVideo()
                }
            }
            
            if (cellIndex < self.arrayResult.count - 1) {
                let posCellIndex = NSIndexPath(forRow: cellIndex + 1, inSection: 0)
                let posCell = self.collectionView.cellForItemAtIndexPath(posCellIndex) as? CardViewCell
                if (posCell != nil) {
                    posCell!.stopPlayVideo()
                }
            }
        })
    }
    
    func carouselSwipeLeft() {
        var offsetX = self.collectionView.contentOffset.x + self.widthCell
        let remainSpace = self.collectionView.contentSize.width - self.widthCell
        if (offsetX > remainSpace) {
            offsetX = remainSpace
        }
        
        let newContentOffset = CGPointMake(offsetX, 0)
        
        UIView.animateWithDuration(0.25, animations: {
            self.collectionView.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(self.collectionView)
            self.checkPlayVideoOnPresentCell()
        }
    }
    
    func carouselSwipeRight() {
        var offsetX = self.collectionView.contentOffset.x - self.widthCell
        offsetX = offsetX < 0 ? 0 : offsetX
        
        let newContentOffset = CGPointMake(offsetX, 0)
        
        UIView.animateWithDuration(0.25, animations: {
            self.collectionView.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(self.collectionView)
            self.checkPlayVideoOnPresentCell()
        }
    }
    
    func carouselLongPress(longPress:UILongPressGestureRecognizer) {
        switch longPress.state {
        case .Began:
            self.currentOffset = self.collectionView.contentOffset
            self.touchPoint = longPress.locationOfTouch(0, inView: self.collectionView)
            break
        case .Changed:
            let movePoint = longPress.locationOfTouch(0, inView: self.collectionView)
            let deltaX = (self.touchPoint.x - movePoint.x)
            
            if deltaX > 3 {
                let newOffsetX = self.currentOffset.x + deltaX
                self.collectionView.setContentOffset(CGPointMake(newOffsetX, 0), animated: false)
            }
            break
        case .Ended:
            print("end")
            self.endPagingCarousel(self.collectionView)
            
            break
        default:
            // Do nothing
            break
        }
    }
    
    func endPagingCarousel(scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            // custom pageing
            var point = scrollView.contentOffset
            point.x = self.widthCell * CGFloat(Int(round((point.x / self.widthCell))))
            
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
    func searchNextPage() {
        if (self.stopSearch == false) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let aVariable = appDelegate.searchDetail as NSDictionary
            var prefix = kPMAPICOACH_SEARCHV3
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
            prefix.appendContentsOf("&offset=".stringByAppendingString(String(self.loadmoreTime * 30)))
            let coordinateParams = String(format: "&%@=%f&%@=%f", kLong, aVariable[kLong] as! Float, kLat, aVariable[kLat] as! Float)
            prefix.appendContentsOf(coordinateParams)
            
            let stateCity =  String(format: "&%@=%@&%@=%@", "state",  (aVariable[kState] as! String).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, "city", (aVariable[kCity] as! String).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            prefix.appendContentsOf(stateCity)
            
            Alamofire.request(.GET, prefix)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        if ((response.result.value as! NSArray).count == 0) {
                            self.stopSearch = true
                        } else {
                            let rArray = response.result.value as! [NSDictionary]
                            self.arrayResult += rArray
                            
                            self.collectionView.reloadData({ 
                                self.loadmoreTime = self.loadmoreTime + 1
                            })
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
        
        self.endPagingCarousel(self.collectionView)
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
            if (self.arrayResult.count == 0) {
                self.collectionView.hidden = true
                
                return 0
            } else {
                self.collectionView.hidden = false
                
                return self.arrayResult.count + 1
            }
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            if indexPath.row == self.arrayResult.count {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SearchNoCoach", forIndexPath: indexPath) as! NoResultCell
                
                // add refind action
                cell.refineSearchBT.addTarget(self, action: #selector(refind), forControlEvents: .TouchUpInside)
                
                // add Swipe gesture
                if cell.gestureRecognizers?.count < 1 {
                    let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeRight))
                    swipeRightGesture.direction = .Right
                    cell.addGestureRecognizer(swipeRightGesture)
                }
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardView", forIndexPath: indexPath) as! CardViewCell
                cell.delegate = self
                cell.clipsToBounds = false
                
                let cellIndex = indexPath.row
                if (cellIndex == self.arrayResult.count - 1) {
                    self.searchNextPage()
                }
                
                coachTotalDetail = arrayResult[cellIndex]
                let coachDetail = coachTotalDetail[kUser] as! NSDictionary
                let coachListTags = coachDetail[kTags] as! NSArray
                
                // Show tag
                cell.cardView.tags.removeAll()
                for i in 0 ..< coachListTags.count {
                    let tagContent = coachListTags[i] as! NSDictionary
                    let tag = Tag()
                    tag.name = tagContent[kTitle] as? String
                    cell.cardView.tags.append(tag)
                }
                cell.cardView.collectionView.reloadData()
                
                // Show coach detail
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
                
                // Show Coach avatar
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
                if (coachDetail[kBusinessId] is NSNull == false) {
                    let businessId = String(format:"%0.f", coachDetail[kBusinessId]!.doubleValue)
                    
                    ImageRouter.getBusinessLogo(businessID: businessId, sizeString: widthHeight120, completed: { (result, error) in
                        if (error == nil) {
                            cell.cardView.connectV.hidden = false
                            
                            let imageRes = result as! UIImage
                            cell.cardView.businessIMV.image = imageRes
                        } else {
                            print("Request failed with error: \(error)")
                        }
                    }).fetchdata()
                }
                
                // add Swipe gesture
                if cell.gestureRecognizers?.count < 2 {
                    
                    let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeLeft))
                    swipeLeftGesture.direction = .Left
                    cell.addGestureRecognizer(swipeLeftGesture)
                    
                    let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeRight))
                    swipeRightGesture.direction = .Right
                    cell.addGestureRecognizer(swipeRightGesture)
                }
                
                return cell
            }
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
            if indexPath.row < self.arrayResult.count {
                let cellIndex = indexPath.row
                
                self.performSegueWithIdentifier(kGoProfile, sender: self.arrayResult[cellIndex])
            }
        }
    }
    
    func cardViewCellTagClicked(cell: CardViewCell) {
        let indexPath = self.collectionView.indexPathForCell(cell)
        
        self.performSegueWithIdentifier(kGoProfile, sender: self.arrayResult[(indexPath?.row)!])
    }
    
    func cardViewCellMoreInfoClicked(cell: CardViewCell) {
        let indexPath = self.collectionView.indexPathForCell(cell)
        
        self.performSegueWithIdentifier(kGoProfile, sender: self.arrayResult[(indexPath?.row)!])
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
