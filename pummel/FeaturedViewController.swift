//
//  FeaturedViewController.swift
//  pummel
//
//  Created by ThongNguyen on 4/8/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Mixpanel
import MapKit

class FeaturedViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, FeedDiscountViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableFeed: UITableView!
    var sizingCell: TagCell?
    var tags = [Tag]()
    var arrayFeeds : [NSDictionary] = []
    var arrayDiscount : [NSDictionary] = []
    var isStopFetch: Bool!
    var offset: Int = 0
    var offsetDiscount: Int = 0
    
    @IBOutlet weak var noActivityYetLB: UILabel!
    @IBOutlet weak var connectWithCoachLB: UILabel!
    var refreshControl: UIRefreshControl!
    var isLoading : Bool = false
    var isLoadDiscount : Bool = false
    var isGoFeedDetail : Bool = false
    var isGoProfileDetail : Bool = false
    var headerDiscount:FeedDiscountView!
    var locationManager: CLLocationManager!
    var coordinate:CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.translucent = false
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeaturedViewController.refreshControlTable), forControlEvents: UIControlEvents.ValueChanged)
        self.tableFeed.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.title = kNavFeed
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let selectedImage = UIImage(named: "feedPressed")
        let image = UIImage(named: "newmessage")!.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action:#selector(FeaturedViewController.newPost))
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tableFeed.delegate = self
        self.tableFeed.dataSource = self
        self.tableFeed.estimatedRowHeight = 64.8
        self.tableFeed.rowHeight = UITableViewAutomaticDimension
       
        self.isStopFetch = false
        if (self.isLoading == false &&
            self.isGoFeedDetail == false &&
            self.isGoProfileDetail == false) {
            self.tableFeed.hidden = true
            self.refresh()
        }
        self.noActivityYetLB.font = .pmmPlayFairReg18()
        self.connectWithCoachLB.font = .pmmMonLight13()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let moveScreenType = defaults.objectForKey(k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_4 {
            defaults.setObject(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
            self.sharePummel()
        } else if moveScreenType == k_PM_MOVE_SCREEN_NOTI_FEED {
            self.refresh()
        }
    }
    
    func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            switch(CLLocationManager.authorizationStatus()) {
            case .Restricted, .Denied:
                self.getListDiscount()
                break
            case .AuthorizedAlways, .AuthorizedWhenInUse: break
            default: break
            }
        } else {
            self.getListDiscount()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation
        if self.coordinate == nil {
            self.coordinate = location.coordinate
            self.getListDiscount()
        }
        self.coordinate = location.coordinate
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch(status) {
        case .Restricted, .Denied:
            self.getListDiscount()
            break
        case .AuthorizedAlways, .AuthorizedWhenInUse: break
        default: break
        }

    }
    
    func refresh() {
        self.tableFeed.hidden = true
        self.arrayFeeds.removeAll()
        self.arrayDiscount.removeAll()
        self.tableFeed.reloadData { 
            self.refreshControl.endRefreshing()
            self.isStopFetch = false
            self.isLoadDiscount = false
            self.offset = 0
            self.offsetDiscount = 0
            if self.coordinate != nil {
                self.getListDiscount()
            } else {
                self.setupLocation()
            }
            
            self.getListFeeds()
        }
    }
    
    func refreshControlTable() {
        if (isLoading == false) {
            self.refresh()
        }
    }
    
    func getListDiscount() {
        var prefix = "\(kPMAPI)\(kPMAPI_DISCOUNTS)"
        prefix.appendContentsOf(String(offsetDiscount))
        
        if self.coordinate != nil {
            prefix.appendContentsOf("&")
            let coordinateParams = String(format: "%@=%f&%@=%f", kLong, self.coordinate!.longitude, kLat, self.coordinate!.latitude)
            prefix.appendContentsOf(coordinateParams)
            
            let geoCoder = CLGeocoder()
            if locationManager.location != nil {
                geoCoder.reverseGeocodeLocation(locationManager.location!, completionHandler: { (placemarks, error) -> Void in
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placemarks?[0]
                    if ((placeMark) != nil) {
                        var state = ""
                        var country = ""
                        if ((placeMark.administrativeArea) != nil) {
                            state = placeMark.administrativeArea!
                            country = placeMark.country!
                        }
                        
                        let trimCountry = country.stringByReplacingOccurrencesOfString(" ", withString: "")
                        let stateCity =  String(format: "&%@=%@&%@=%@", kState, state.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, kCountry, trimCountry.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                        
                        prefix.appendContentsOf(stateCity)
                        self.callAPIDiscount(prefix)
                    }
                })
            } else {
                self.callAPIDiscount(prefix)
            }
        } else {
            self.callAPIDiscount(prefix)
        }
    }
    
    func callAPIDiscount(prefix:String) {
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                self.isLoadDiscount = false
                if response.response?.statusCode == 200 {
                    if let arr = response.result.value as? [NSDictionary] {
                        self.offsetDiscount += 10
                        self.arrayDiscount += arr
                        if arr.count > 0 {
                            if self.arrayDiscount.count == arr.count {
                                self.tableFeed.reloadData()
                            } else if self.headerDiscount != nil {
                                self.headerDiscount.arrayResult = self.arrayDiscount
                            } else {
                                self.tableFeed.reloadData()
                            }
                        }
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
    
    func getListFeeds() {
        if (self.isStopFetch == false) {
            self.isLoading = true
            
            FeedRouter.getListFeed(offset: self.arrayFeeds.count, completed: { (result, error) in
                if (error == nil) {
                    let arr = result as! [NSDictionary]
                    
                    if (arr.count > 0) {
                        self.arrayFeeds += arr
                        self.tableFeed.reloadData({
                            // Hidden table view if no data
                            self.tableFeed.hidden = (self.arrayFeeds.count == 0)
                        })
                    } else {
                        self.isStopFetch = true
                    }
                    
                    self.isLoading = false
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
    }
    
    func newPost() {
         self.performSegueWithIdentifier("goNewPost", sender:nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"NewPost"]
        mixpanel.track("IOS.Feed", properties: properties)
    }
    
    func goToDetailDiscount(discountDetail: NSDictionary) {
        self.isGoFeedDetail = true
        self.performSegueWithIdentifier(kGoDiscount, sender:discountDetail)
    }
    
    func loadMoreDiscount() {
        if self.isLoadDiscount == false {
            self.isLoadDiscount = true
            self.getListDiscount()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return nil
        }
        
        if self.arrayDiscount.count == 0 {
            return nil
        }
        
        if headerDiscount == nil {
            headerDiscount = FeedDiscountView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            headerDiscount.delegate = self
        }
        headerDiscount.arrayResult = self.arrayDiscount
        
        return headerDiscount
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.arrayDiscount.count > 0 {
            return 200
        }
        return 0.001
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return self.arrayFeeds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(kFeaturedFeedTableViewCell) as! FeaturedFeedTableViewCell
        
            cell.separatorInset = UIEdgeInsetsZero;
            let feed = arrayFeeds[indexPath.row]
            let userFeed = feed[kUser] as! NSDictionary
            // Name
            let firstname = userFeed[kFirstname] as? String
            cell.nameLB.text = firstname?.uppercaseString
        
            // Avatar
            if (userFeed[kImageUrl] is NSNull == false) {
                cell.avatarBT.setBackgroundImage(nil, forState: .Normal)
                let imageLink = userFeed[kImageUrl] as? String
                
                if (imageLink?.isEmpty == false) {
                    ImageRouter.getImage(posString: imageLink!, sizeString: widthHeight120) { (result, error) in
                        if (error == nil) {
                            let imageRes = result as! UIImage
                            
                            let visibleCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                            if visibleCell == true {
                                dispatch_async(dispatch_get_main_queue(),{
                                    cell.avatarBT.setBackgroundImage(imageRes, forState: .Normal)
                                })
                            }
                        } else {
                            print("Request failed with error: \(error)")
                        }
                        }.fetchdata()
                }
            } else {
                cell.avatarBT.setBackgroundImage(UIImage(named: "display-empty.jpg"), forState: .Normal)
            }
            // Time
            let timeAgo = feed[kCreateAt] as! String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = kFullDateFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            let dateFromString : NSDate = dateFormatter.dateFromString(timeAgo)!
            cell.timeLB.text = self.timeAgoSinceDate(dateFromString)
            if (feed[kImageUrl] is NSNull == false) {
                let imageContentLink = feed[kImageUrl] as! String
                let postfixContent = widthEqual.stringByAppendingString(String(self.view.frame.size.width*2)).stringByAppendingString(heighEqual).stringByAppendingString(String(self.view.frame.size.width*2))
                
                ImageRouter.getImage(posString: imageContentLink, sizeString: postfixContent, completed: { (result, error) in
                    if (error == nil) {
                        let isUpdateCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                        
                        if (isUpdateCell) {
                            let imageRes = result as! UIImage
                            dispatch_async(dispatch_get_main_queue(),{
                                cell.imageContentIMV.image = imageRes
                            })
                        }
                    } else {
                        print("Request failed with error: \(error)")
                    }
                }).fetchdata()
            }
        
            // Check Coach
            cell.userInteractionEnabled = false
            var coachLink  = kPMAPICOACH
            let coachId = String(format:"%0.f", userFeed[kId]!.doubleValue)
            coachLink.appendContentsOf(coachId)
        
            cell.avatarBT.layer.borderWidth = 0
            cell.coachLB.text = ""
            cell.coachLBTraillingConstraint.constant = 0
        
            UserRouter.checkCoachOfUser(userID: coachId) { (result, error) in
                let isCoach = result as! Bool
                let isUpdateCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                
                if (isUpdateCell) {
                    cell.userInteractionEnabled = true
                    cell.isCoach = false
                    
                    if (error == nil) {
                        if (isCoach == true) {
                            cell.isCoach = true
                            cell.avatarBT.layer.borderWidth = 2
                            
                            cell.coachLBTraillingConstraint.constant = 5
                            UIView.animateWithDuration(0.3, animations: {
                                cell.coachLB.layoutIfNeeded()
                                cell.coachLB.text = kCoach.uppercaseString
                            })
                        }
                    } else {
                        print("Request failed with error: \(error)")
                    }
                }
        }.fetchdata()
        
            cell.likeBT.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
        
            //Get Likes
//            cell.likeBT.userInteractionEnabled = true
//            cell.imageContentIMV.userInteractionEnabled = true
        let feedID = String(format:"%0.f", feed[kId]!.doubleValue)
        
        FeedRouter.getAndCheckFeedLike(feedID: feedID) { (result, error) in
            if (error == nil) {
                let isUpdateCell = PMHeler.checkVisibleCell(tableView, indexPath: indexPath)
                
                if (isUpdateCell) {
                    dispatch_async(dispatch_get_main_queue(),{
                        let likeJson = result as! NSDictionary
                        
                        // Update like number
                        let likeNumber = String(format:"%0.f", likeJson["likeNumber"]!.doubleValue)
                        cell.likeLB.text = likeNumber + " likes"
                        
                        // Update current user liked
                        let userLikedFeed = likeJson["currentUserLiked"] as! Bool
                        if (userLikedFeed == true) {
                            cell.likeBT.setBackgroundImage(UIImage(named: "liked.png"), forState: .Normal)
                        }
                    })
                }
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
        
            cell.layoutIfNeeded()
            cell.firstContentCommentTV.layoutIfNeeded()
            cell.firstContentCommentTV.delegate = self
            cell.firstContentCommentTV.text = feed[kText] as? String
        
            let marginTopBottom = cell.firstContentCommentTV.layoutMargins.top + cell.firstContentCommentTV.layoutMargins.bottom
            let marginLeftRight = cell.firstContentCommentTV.layoutMargins.left + cell.firstContentCommentTV.layoutMargins.right
            cell.firstContentTextViewConstraint.constant = (cell.firstContentCommentTV.text?.heightWithConstrainedWidth(cell.firstContentCommentTV.frame.width - marginLeftRight, font: cell.firstContentCommentTV.font!))! + marginTopBottom + 1 // 1: magic number
        
            cell.firstUserCommentLB.text = firstname?.uppercaseString
            cell.viewAllBT.tag = indexPath.row
            cell.viewAllBT.addTarget(self, action: #selector(FeaturedViewController.goToFeedDetail(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
            cell.commentBT.tag = indexPath.row
            cell.commentBT.addTarget(self, action: #selector(FeaturedViewController.goToFeedDetail(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
            cell.shareBT.tag = indexPath.row
            cell.shareBT.addTarget(self, action: #selector(FeaturedViewController.showListContext(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
            cell.avatarBT.tag = indexPath.row
            cell.avatarBT.addTarget(self, action: #selector(FeaturedViewController.goProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeBT.tag = indexPath.row
            cell.postId = String(format:"%0.f", feed[kId]!.doubleValue)
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell , forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.arrayFeeds.count - 1 && isLoading == false) {
             self.getListFeeds()
        }
    }
    
    func sharePummel() {
        self.shareTextImageAndURL(pummelSlogan, sharingImage: UIImage(named: "shareLogo.png"), sharingURL: NSURL.init(string: kPM))
    }
    
    func shareTextImageAndURL(sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    
    func goToFeedDetail(sender: UIButton) {
        self.isGoFeedDetail = true
        self.performSegueWithIdentifier("goToFeedDetail", sender: sender)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Comment"]
        mixpanel.track("IOS.Feed", properties: properties)
    }
    
    func showListContext(sender: UIButton) {
        let selectReport = { (action:UIAlertAction!) -> Void in
            let feed = self.arrayFeeds[sender.tag]
            let postId = String(format:"%0.f", feed[kId]!.doubleValue)
//            Alamofire.request(.PUT, kPMAPI_REPORT, parameters: ["postId":postId])
//                .responseJSON { response in
//                    if response.response?.statusCode == 200 {
//                        self.arrayFeeds.removeAtIndex(sender.tag)
//                        self.tableFeed.reloadData()
//                    }
//            }
            
            FeedRouter.reportFeed(param: ["postId":postId], completed: { (result, error) in
                if (error == nil) {
                    self.arrayFeeds.removeAtIndex(sender.tag)
                    self.tableFeed.reloadData()
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()

        }
        let share = { (action:UIAlertAction!) -> Void in
            self.sharePummel()
        }
        let selectCancle = { (action:UIAlertAction!) -> Void in
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: KReport, style: UIAlertActionStyle.Destructive, handler: selectReport))
        alertController.addAction(UIAlertAction(title: kShare, style: UIAlertActionStyle.Destructive, handler: share))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: selectCancle))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func goProfile(sender: UIButton) {
        let feed = arrayFeeds[sender.tag]
        let userID = feed[kUserId] as! Double
        let userIDString = String(format: "%0.0f", userID)
        UserRouter.getUserInfo(userID: userIDString) { (result, error) in
            if (error == nil) {
                let cell = self.tableFeed.cellForRowAtIndexPath(NSIndexPath.init(forRow: sender.tag, inSection: 1)) as! FeaturedFeedTableViewCell
                self.isGoProfileDetail = true
                
                let userDetail = result as! NSDictionary
                if (cell.isCoach == true) {
                    self.performSegueWithIdentifier(kGoProfile, sender:userDetail)
                } else {
                    self.performSegueWithIdentifier(kGoUserProfile, sender:userDetail)
                }
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTagCell, forIndexPath: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        return self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        collectionView.reloadData()
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagName.textColor = UIColor.blackColor()
        cell.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    func goConnect(sender:UIButton!) {
        self.performSegueWithIdentifier(kGoConnect, sender: sender)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        self.performSegueWithIdentifier(kClickURLLink, sender: URL)
        
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == kGoConnect) {
            let destination = segue.destinationViewController as! ConnectViewController
            let tag = sender.tag
            let feed = arrayFeeds[tag] 
            let currentFeedDetail = feed[kUser] as! NSDictionary
            destination.coachDetail = currentFeedDetail
            destination.isFromFeed = true
        } else if (segue.identifier == kGoProfile) {
            let destination = segue.destinationViewController as! CoachProfileViewController
            destination.coachDetail = sender as! NSDictionary
            destination.isFromFeed = true
        } else if (segue.identifier == kGoUserProfile) {
            let destination = segue.destinationViewController as! UserProfileViewController
            let currentFeedDetail = sender as! NSDictionary
            destination.userDetail = currentFeedDetail
            destination.userId = String(format:"%0.f", currentFeedDetail[kId]!.doubleValue)
        } else if (segue.identifier == kSendMessageConnection) {
            let destination = segue.destinationViewController as! ChatMessageViewController
            
            let coachDetail = (sender as! NSArray)[0]
            let message = (sender as! NSArray)[1] as! String
            
            destination.coachName = ((coachDetail[kFirstname] as! String) .stringByAppendingString(" ")).uppercaseString
            destination.typeCoach = true
            destination.coachId = String(format:"%0.f", coachDetail[kId]!!.doubleValue)
            destination.userIdTarget =  String(format:"%0.f", coachDetail[kId]!!.doubleValue)
            destination.preMessage = message
        } else if (segue.identifier == "goToFeedDetail") {
            let destination = segue.destinationViewController as! FeedViewController
            let feed = arrayFeeds[sender.tag] 
            destination.feedDetail = feed
        } else if (segue.identifier == kClickURLLink) {
            let destination = segue.destinationViewController as! FeedWebViewController
            destination.URL = sender as? NSURL
        } else if segue.identifier == kGoDiscount {
            let destination = segue.destinationViewController as! DiscountDetailVC
            if let dic = sender as? NSDictionary {
                destination.discountDetail = dic
            }
        }
    }

    func timeAgoSinceDate(date:NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .Month, .Year]
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options:NSCalendarOptions.MatchPreviousTimePreservingSmallerUnits)
        
        if (components.year >= 2) {
            return "\(components.year)y"
        } else if (components.year >= 1){
            return "1y"
        } else if (components.month >= 2) {
            return "\(components.month)m"
        } else if (components.month >= 1){
            return "1m"
        } else if (components.day >= 2) {
            return "\(components.day)d"
        } else if (components.day >= 1){
            return "1d"
        } else if (components.hour >= 2) {
            return "\(components.hour)hr"
        } else if (components.hour >= 1){
            return "1hr"
        } else if (components.minute >= 2) {
            return "\(components.minute)m"
        } else if (components.minute >= 1){
            return "1m"
        } else if (components.second >= 3) {
            return "\(components.second)s"
        } else {
            return "Just now"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}

