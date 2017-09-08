//
//  Find.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
// Find an expert view


import UIKit
import MapKit
import Mixpanel
import Alamofire
import ReactiveUI
import Cartography
import UIColor_FlatColors

class FindViewController: BaseViewController, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout{
    var loadCardsFromXib = true
    var resultIndex = 0
    var coachTotalDetail: NSDictionary!
    var arrayResult : [NSDictionary] = []
    var coachArray: [UserModel] = []
    var coachOffset = 0
    var arrayTags : NSArray!
    var stopSearch: Bool = false
    var stopGetCoach: Bool = false
    var widthCell : CGFloat = 0.0
    var currentOffset: CGPoint = CGPointZero
    var touchPoint: CGPoint = CGPointZero
    var loadmoreTime = 0
    let badgeLabel = UILabel()
    
    @IBOutlet weak var noResultViewVerticalConstraint: NSLayoutConstraint! // default -32
    @IBOutlet weak var noResultLB: UILabel!
    @IBOutlet weak var noResultContentLB: UILabel!
    @IBOutlet weak var refineSearchBT: UIButton!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var horizontalView: UIView!
    @IBOutlet weak var separeateline: UIView!
    @IBOutlet weak var horizontalButton: UIButton!
    @IBOutlet weak var horizontalTableView: UITableView!
    @IBOutlet weak var horizontalViewHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - View controller circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.translucent = false
        self.tabBarController?.navigationController?.navigationBar.addSubview(self.badgeLabel)
        
        self.setupCollectionView()
        self.setupHorizontalView()
        
        noResultLB.font = .pmmPlayFairReg18()
        noResultContentLB.font = .pmmMonLight13()
        refineSearchBT.titleLabel!.font = .pmmMonReg12()
        refineSearchBT.layer.cornerRadius = 5
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.startSearchCoachNotification), name: k_PM_FIRST_SEARCH_COACH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(self.updateSMLCBadge), name: k_PM_SHOW_MESSAGE_BADGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(self.updateLBadge(_:)), name: k_PM_UPDATE_LEAD_BADGE, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupLayout()
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("SHOW_SEARCH_AFTER_REGISTER") == true) {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "SHOW_SEARCH_AFTER_REGISTER")
            NSUserDefaults.standardUserDefaults().synchronize()
            performSegueWithIdentifier("letUsHelp", sender: nil)
        }
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FindViewController.refind), name: "SELECTED_MIDDLE_TAB", object: nil)
        
        self.stopSearch = false
        
        self.badgeLabel.alpha = 1
        
        self.endPagingCarousel(self.collectionView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let moveScreenType = defaults.objectForKey(k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_1 {
            self.refind()
        } else if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_SEARCH {
            self.defaults.setObject(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        }
        
        self.collectionView.reloadData { 
            self.checkPlayVideoOnPresentCell()
        }
        
        self.coachOffset = 0
        self.stopGetCoach = false
        self.getCoachArray()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SELECTED_MIDDLE_TAB", object: nil)

        self.badgeLabel.alpha = 0
    }
    
    func setupLayout() {
        self.tabBarController?.title = "RESULTS"
        
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let selectedImage = UIImage(named: "search")
        self.tabBarItem.image = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        // Left button
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            let leftBarButtonItem = UIBarButtonItem(title:"CLIENTS",
                                                    style: UIBarButtonItemStyle.Plain,
                                                    target: self,
                                                    action: #selector(FindViewController.btnClientClick))
            self.tabBarController?.navigationItem.leftBarButtonItem = leftBarButtonItem
        } else {
            let leftBarButtonItem = UIBarButtonItem(title:"COACHES",
                                                    style: UIBarButtonItemStyle.Plain,
                                                    target: self,
                                                    action: #selector(FindViewController.btnCoachsClick))
            self.tabBarController?.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
    }
    
    func setupHorizontalView() {
        self.horizontalTableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
        
        self.separeateline!.backgroundColor = UIColor.pmmWhiteColor()
        
        self.horizontalButton.titleLabel?.font = UIFont.pmmMonLight11()
        self.horizontalButton.setTitleColor(UIColor.pmmBrightOrangeColor(), forState: .Normal)
//        self.horizontalButton.setTitle("Show List Coach", forState: .Normal)
        
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.horizontalViewSwipeUp))
        swipeUp.direction = .Right // Up direction: horizontal table view tranform 90 degree
        self.horizontalTableView.addGestureRecognizer(swipeUp)
    }
    
    func setupCollectionView() {
        // register cell
        let nibName = UINib(nibName: "CardContentView", bundle: nil)
        self.collectionView.registerNib(nibName, forCellWithReuseIdentifier: "CardView")
        
        let noResultNibName = UINib(nibName: "CardContentNoResult", bundle: nil)
        self.collectionView.registerNib(noResultNibName, forCellWithReuseIdentifier: "SearchNoCoach")
        
        // setup cell
        self.widthCell = (SCREEN_WIDTH - 30)
        self.collectionViewLayout.itemSize = CGSize(width: (SCREEN_WIDTH - 40), height: (SCREEN_HEIGHT - 160))
        self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(-40, 20, 0, 0)
        self.collectionViewLayout.minimumLineSpacing = 10
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func startSearchCoachNotification() {
        self.stopSearch = false
        self.loadmoreTime = 0
        
        self.expandCollapseCoachView(false)
        
        self.searchCoachPage()
    }
    
    func searchCoachPage() {
        if (self.stopSearch == false) {
            var param : [String: AnyObject] = [:];
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let aVariable = appDelegate.searchDetail as NSDictionary
            var prefix = kPMAPICOACH_SEARCHV3
            
            if ((aVariable[kGender] as! String) != kDontCare) {
                param["gender"] = aVariable[kGender]
            }
            param["limit"] = 30
            param["offset"] = self.loadmoreTime * 30
            param[kLong] = aVariable[kLong]
            param[kLat] = aVariable[kLat]
            param[kState] = aVariable[kState]
            param[kCity] = aVariable[kCity]
            
            let tagArray = aVariable["tagIds"] as? NSArray
            if (tagArray != nil) {
                var index = 0
                for id in tagArray! {
                    if (index == 0) {
                        prefix.appendContentsOf("?")
                    } else {
                        prefix.appendContentsOf("&")
                    }
                    
                    index = index + 1
                    
                    prefix.appendContentsOf("tagIds=".stringByAppendingString(id as! String))
                    
                }
            }
            
            Alamofire.request(.GET, prefix, parameters: param)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        if (response.result.value == nil) {
                            self.stopSearch = true
                            NSNotificationCenter.defaultCenter().postNotificationName("AFTER_SEARCH_PAGE", object: nil)
                            return
                        }
                        
                        // First time search
                        var needReloadCollection = true
                        
                        if (self.loadmoreTime == 0) {
                            let secondsWait = 2.0
                            let delay = secondsWait * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                                self.arrayResult.removeAll()
                                self.arrayResult = response.result.value  as! [NSDictionary]
                                self.viewDidLayoutSubviews()
                                self.collectionView.contentOffset = CGPointZero
                                
                                // Post notification for dismiss search animation screen
                                NSNotificationCenter.defaultCenter().postNotificationName("AFTER_SEARCH_PAGE", object: nil)
                            });
                        } else {
                            if ((response.result.value as! NSArray).count == 0) {
                                self.stopSearch = true
                                
                                needReloadCollection = false
                            } else {
                                let rArray = response.result.value as! [NSDictionary]
                                self.arrayResult += rArray
                            }
                        }
                        
                        if (needReloadCollection == true) {
                            // Increase load more time and reload page
                            self.collectionView.reloadData({
                                self.loadmoreTime = self.loadmoreTime + 1
                            })
                        }
                    } else if response.response?.statusCode == 401 {
                        PMHeler.showLogoutAlert()
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName("AFTER_SEARCH_PAGE", object: nil)
                    }
            }
        } else {
            print("no more resul")
        }
    }
    
    func getCoachArray() {
        if (self.stopGetCoach == false) {
            UserRouter.getFollowCoach(offset: self.coachOffset) { (result, error) in
                if (error == nil) {
                    let coachDetails = result as! [UserModel]
                    
                    if (coachDetails.count == 0) {
                        self.stopGetCoach = true
                    } else {
                        for coachDetail in coachDetails {
                            if (coachDetail.existInList(self.coachArray) == false) {
                                self.coachArray.append(coachDetail)
                            }
                        }
                    }
                    
                    self.coachOffset = self.coachOffset + 20
                    self.horizontalTableView.reloadData()
                } else {
                    self.stopGetCoach = true
                    
                    print("Request failed with error: \(error)")
                }
                }.fetchdata()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "letUsHelp") {
            // Do nothing
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
            
            if (message.isEmpty == true) {
                destination.needOpenKeyboard = true
            } else {
                let messageSeparate = message.componentsSeparatedByString("can you please call me back on ")
                let phoneNumber = messageSeparate[1]
                
                if (phoneNumber.isEmpty == true) {
                    destination.needOpenKeyboard = true
                }
            }
        } else if (segue.identifier == kGoProfile) {
            let destination = segue.destinationViewController as! CoachProfileViewController
            let totalDetail = sender as! NSDictionary
            
            var coachDetail = totalDetail[kUser] as? NSDictionary
            if (coachDetail == nil) {
                coachDetail = totalDetail
            }

            if (coachDetail != nil) {
                destination.coachDetail = coachDetail
                
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
    
    func updateLBadge(notification: NSNotification) {
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            let badgeValue = notification.object as? Int
            
            if (badgeValue != nil && badgeValue > 0) {
                // Create badge label
                self.badgeLabel.textColor = UIColor.whiteColor()
                self.badgeLabel.font = UIFont.systemFontOfSize(12)
                self.badgeLabel.backgroundColor = UIColor.pmmBrightOrangeColor()
                self.badgeLabel.textAlignment = .Center
                
                // Add badge label value & layout
                self.badgeLabel.text = String(format: "%d", badgeValue!)
                self.badgeLabel.sizeToFit()
                
                let maxSize = max(badgeLabel.frame.width, badgeLabel.frame.height)
                self.badgeLabel.layer.cornerRadius = maxSize / 2
                self.badgeLabel.layer.masksToBounds = true
                self.badgeLabel.frame = CGRect(x: 70, y: 5, width: maxSize, height: maxSize)
                
                self.badgeLabel.hidden = false
            } else {
                self.badgeLabel.hidden = true
            }
        }
    }
    
    func btnClientClick() {
        self.performSegueWithIdentifier("gotoClient", sender: nil)
    }
    
    func btnCoachsClick() {
//        self.performSegueWithIdentifier("gotoCoachs", sender: nil)
        
        if (self.horizontalTableView.alpha == 0) {
            self.expandCollapseCoachView(true)
        } else {
            self.expandCollapseCoachView(false)
        }
    }
    
    @IBAction func horizontalViewClicked(sender: AnyObject) {
        // For expand coach view
        self.expandCollapseCoachView(true)
    }
    
    func horizontalViewSwipeUp() {
        self.expandCollapseCoachView(false)
    }
    
    func expandCollapseCoachView(isExpand: Bool) {
        self.tabBarController?.navigationItem.leftBarButtonItem?.enabled = false
        
        if (isExpand == true) {
            self.horizontalViewHeightConstraint.constant = 120
            self.noResultViewVerticalConstraint.constant = -32 + 60 // Default vertical value
            
            self.separeateline.hidden = true // For animation
            
            UIView.animateWithDuration(0.3, animations: {
                self.horizontalTableView.alpha = 1
                self.tabBarController?.navigationItem.leftBarButtonItem?.customView?.alpha = 1
                
                self.horizontalButton.hidden = true
                
                self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmLightBrightOrangeColor()], forState: .Normal)
                
                self.horizontalView.layoutIfNeeded()
            }) { (_) in
                self.separeateline.hidden = false
                
                self.tabBarController?.navigationItem.leftBarButtonItem?.enabled = true
            }
        } else {
            self.horizontalViewHeightConstraint.constant = 0
            self.noResultViewVerticalConstraint.constant = -32 // Default vertical value
            
            self.separeateline.hidden = true // For animation
            
            UIView.animateWithDuration(0.3, animations: {
                self.horizontalTableView.alpha = 0
                self.tabBarController?.navigationItem.leftBarButtonItem?.customView?.alpha = 0.5
                
                self.horizontalButton.hidden = false
                
                self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], forState: .Normal)
                
                self.horizontalView.layoutIfNeeded()
            }) { (_) in
                self.separeateline.hidden = false
                
                self.tabBarController?.navigationItem.leftBarButtonItem?.enabled = true
            }
        }
    }
}

// MARK: - CardViewCellDelegate
extension FindViewController: CardViewCellDelegate {
    func cardViewCellTagClicked(cell: CardViewCell) {
        let indexPath = self.collectionView.indexPathForCell(cell)
        
        self.performSegueWithIdentifier(kGoProfile, sender: self.arrayResult[(indexPath?.row)!])
    }
    
    func cardViewCellMoreInfoClicked(cell: CardViewCell) {
        let indexPath = self.collectionView.indexPathForCell(cell)
        
        self.performSegueWithIdentifier(kGoProfile, sender: self.arrayResult[(indexPath?.row)!])
    }
}

extension FindViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.coachArray.count == 0) {
            self.horizontalView.hidden = true
        } else {
            self.horizontalView.hidden = false
        }
        
        return self.coachArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (defaults.boolForKey(k_PM_IS_COACH) == true) {
            self.horizontalViewHeightConstraint.constant = 0
            
            return 0
        } else {
            if (self.horizontalTableView.alpha == 1) {
                self.expandCollapseCoachView(true)
            }
            
            return 96
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == self.coachArray.count - 2) {
            self.getCoachArray()
        }
        
        let cellId = "HorizontalCell"
        var cell:HorizontalCell? = tableView.dequeueReusableCellWithIdentifier(cellId) as? HorizontalCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed(cellId, owner: nil, options: nil)!.first as? HorizontalCell
            cell!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0))
        }
        cell!.addButton.hidden = true
        cell?.imageV.image = UIImage(named: "display-empty.jpg")
        cell?.imageV.layer.borderWidth = 2
        
        let coach = self.coachArray[indexPath.row]
        let targetUserId = String(format:"%ld", coach.id)
        
        if (coach.firstname?.isEmpty == false) {
            self.setupDataForCell(cell!, coach: coach)
        } else {
            UserRouter.getUserInfo(userID: targetUserId, completed: { (result, error) in
                if (error == nil) {
                    let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                    if visibleCell == true {
                        let userData = result as! NSDictionary
                        coach.parseData(userData)
                        
                        self.setupDataForCell(cell!, coach: coach)
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
        
        cell!.selectionStyle = .None
        return cell!
    }
    
    func setupDataForCell(cell: HorizontalCell, coach: UserModel) {
        cell.name.text = coach.firstname!.uppercaseString
        
        if (coach.imageUrl != nil) {
            let imageURLString = coach.imageUrl
            
            ImageRouter.getImage(imageURLString: imageURLString!, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                        let imageRes = result as! UIImage
                        cell.imageV.image = imageRes
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        } else {
            cell.imageV.image = UIImage(named: "display-empty.jpg")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.coachArray.count {
            let cellIndex = indexPath.row
            
            let userDetail = self.coachArray[cellIndex].convertToDictionary()
            self.performSegueWithIdentifier(kGoProfile, sender: userDetail)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FindViewController : UICollectionViewDataSource, UICollectionViewDelegate {
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
                    self.searchCoachPage()
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
            //            if (cellIndex < self.arrayResult.count) {
            //                let coachDetail = self.arrayResult[cellIndex]
            //                let coachID = String(format: "%.0f", coachDetail[kUserId] as! Double)
            //                TrackingPMAPI.sharedInstance.trackingProfileCard(coachID)
            //            }
            //
            //            // Remove video layer
            //            if (cellIndex > 0) {
            //                let preCellIndex = NSIndexPath(forRow: cellIndex - 1, inSection: 0)
            //                let preCell = self.collectionView.cellForItemAtIndexPath(preCellIndex) as? CardViewCell
            //                if (preCell != nil) {
            //                    preCell!.stopPlayVideo()
            //                }
            //            }
            //
            //            if (cellIndex < self.arrayResult.count - 1) {
            //                let posCellIndex = NSIndexPath(forRow: cellIndex + 1, inSection: 0)
            //                let posCell = self.collectionView.cellForItemAtIndexPath(posCellIndex) as? CardViewCell
            //                if (posCell != nil) {
            //                    posCell!.stopPlayVideo()
            //                }
            //            }
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
}
