//
//  FeaturedViewController.swift
//  pummel
//
//  Created by ThongNguyen on 4/8/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import MapKit
import Mixpanel
import Alamofire
import Foundation

class FeaturedViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate, FeedDiscountViewDelegate, CLLocationManagerDelegate {
    
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
        self.navigationController!.navigationBar.isTranslucent = false
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FeaturedViewController.refreshControlTable), for: .valueChanged)
        self.tableFeed.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = kNavFeed
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let selectedImage = UIImage(named: "feedPressed")
        let image = UIImage(named: "newmessage")!.withRenderingMode(.alwaysOriginal)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action:#selector(FeaturedViewController.newPost))
        self.tabBarItem.selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tableFeed.delegate = self
        self.tableFeed.dataSource = self
        self.tableFeed.estimatedRowHeight = 64.8
        self.tableFeed.rowHeight = UITableViewAutomaticDimension
       
        self.isStopFetch = false
        if (self.isLoading == false &&
            self.isGoFeedDetail == false &&
            self.isGoProfileDetail == false) {
            self.refresh()
        }
        self.noActivityYetLB.font = .pmmPlayFairReg18()
        self.connectWithCoachLB.font = .pmmMonLight13()
        
        self.resetCBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated: animated)
        
        let defaults = UserDefaults.standard
        let moveScreenType = defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_4 {
            defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
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
            case .restricted, .denied:
                self.getListDiscount()
                break
            case .authorizedAlways, .authorizedWhenInUse: break
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
        self.tableFeed.isHidden = true
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
        prefix.append(String(offsetDiscount))
        
        if self.coordinate != nil {
            prefix.append("&")
            let coordinateParams = String(format: "%@=%f&%@=%f", kLong, self.coordinate!.longitude, kLat, self.coordinate!.latitude)
            prefix.append(coordinateParams)
            
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
                        
                        let trimCountry = country.replacingOccurrences(of: " ", with: "")
                        let stateCity =  String(format: "&%@=%@&%@=%@", kState, state.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, kCountry, trimCountry.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                        
                        prefix.append(stateCity)
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
                    let alertController = UIAlertController(title: pmmNotice, message: cookieExpiredNotice, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: kOk, style: .default) { (action) in
                        // TODO: LOGOUT
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {
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
                            self.tableFeed.isHidden = (self.arrayFeeds.count == 0)
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
         self.performSegue(withIdentifier: "goNewPost", sender:nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"NewPost"]
        mixpanel.track("IOS.Feed", properties: properties)
    }
    
    func goToDetailDiscount(discountDetail: NSDictionary) {
        self.isGoFeedDetail = true
        self.performSegue(withIdentifier: kGoDiscount, sender:discountDetail)
    }
    
    func loadMoreDiscount() {
        if self.isLoadDiscount == false {
            self.isLoadDiscount = true
            self.getListDiscount()
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
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func goToFeedDetail(sender: UIButton) {
        self.isGoFeedDetail = true
        self.performSegue(withIdentifier: "goToFeedDetail", sender: sender)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Comment"]
        mixpanel.track("IOS.Feed", properties: properties)
    }
    
    func showListContext(sender: UIButton) {
        let selectReport = { (action:UIAlertAction!) -> Void in
            let feed = self.arrayFeeds[sender.tag]
            let postId = String(format:"%0.f", (feed[kId]! as AnyObject).doubleValue)
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
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: KReport, style: UIAlertActionStyle.destructive, handler: selectReport))
        alertController.addAction(UIAlertAction(title: kShare, style: UIAlertActionStyle.destructive, handler: share))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: selectCancle))
        
        self.present(alertController, animated: true) { }
    }
    
    func goProfile(sender: UIButton) {
        let feed = arrayFeeds[sender.tag]
        let userID = feed[kUserId] as! Double
        let userIDString = String(format: "%0.0f", userID)
        
        self.isGoProfileDetail = true
        PMHelper.showCoachOrUserView(userID: userIDString)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kTagCell, for: indexPath) as! TagCell
        self.configureCell(cell: cell, forIndexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath as NSIndexPath)
        return self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        collectionView.reloadData()
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagName.textColor = UIColor.black
        cell.layer.borderColor = UIColor.clear.cgColor
    }
    
    func goConnect(sender:UIButton!) {
        self.performSegue(withIdentifier: kGoConnect, sender: sender)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.performSegue(withIdentifier: kClickURLLink, sender: URL)
        
        return false
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == kGoConnect) {
            let destination = segue.destination as! ConnectViewController
            let tag = sender.tag
            let feed = arrayFeeds[tag!] 
            let currentFeedDetail = feed[kUser] as! NSDictionary
            destination.coachDetail = currentFeedDetail
            destination.isFromFeed = true
        } else if (segue.identifier == kSendMessageConnection) {
            let destination = segue.destination as! ChatMessageViewController
            
            let coachDetail = (sender as! NSArray)[0] as! NSDictionary
            let message = (sender as! NSArray)[1] as! String
            
            destination.coachName = ((coachDetail[kFirstname] as! String) .stringByAppendingString(" ")).uppercased()
            destination.typeCoach = true
            destination.coachId = String(format:"%0.f", coachDetail[kId]!!.doubleValue)
            destination.userIdTarget =  String(format:"%0.f", coachDetail[kId]!!.doubleValue)
            destination.preMessage = message
            
            if (message.isEmpty == true) {
                destination.needOpenKeyboard = true
            } else {
                let messageSeparate = message.components(separatedBy: "can you please call me back on ")
                let phoneNumber = messageSeparate[1]
                
                if (phoneNumber.isEmpty == true) {
                    destination.needOpenKeyboard = true
                }
            }
        } else if (segue.identifier == "goToFeedDetail") {
            let destination = segue.destination as! FeedViewController
            let feed = arrayFeeds[sender.tag] 
            destination.feedDetail = feed
        } else if (segue.identifier == kClickURLLink) {
            let destination = segue.destination as! FeedWebViewController
            destination.URL = sender as? NSURL
        } else if segue.identifier == kGoDiscount {
            let destination = segue.destination as! DiscountDetailVC
            if let dic = sender as? NSDictionary {
                destination.discountDetail = dic
            }
        }
    }

    func timeAgoSinceDate(date:NSDate) -> String {
        let calendar = NSCalendar.current
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

extension FeaturedViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return self.arrayFeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kFeaturedFeedTableViewCell) as! FeaturedFeedTableViewCell
        
        cell.separatorInset = UIEdgeInsets()
        let feed = arrayFeeds[indexPath.row]
        let userFeed = feed[kUser] as! NSDictionary
        // Name
        let firstname = userFeed[kFirstname] as? String
        cell.nameLB.text = firstname?.uppercased()
        
        // Avatar
        if (userFeed[kImageUrl] is NSNull == false) {
            cell.avatarBT.setBackgroundImage(nil, for: .normal)
            let imageLink = userFeed[kImageUrl] as? String
            
            if (imageLink?.isEmpty == false) {
                ImageRouter.getImage(imageURLString: imageLink!, sizeString: widthHeight120) { (result, error) in
                    if (error == nil) {
                        let imageRes = result as! UIImage
                        
                        let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                        if visibleCell == true {
                            DispatchQueue.main.async(execute: {
                                cell.avatarBT.setBackgroundImage(imageRes, for: .normal)
                            })
                        }
                    } else {
                        print("Request failed with error: \(error)")
                    }
                    }.fetchdata()
            } else {
                cell.avatarBT.setBackgroundImage(UIImage(named: "display-empty.jpg"), for: .normal)
            }
        } else {
            cell.avatarBT.setBackgroundImage(UIImage(named: "display-empty.jpg"), for: .normal)
        }
        // Time
        let timeAgo = feed[kCreateAt] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kFullDateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let dateFromString : NSDate = dateFormatter.date(from: timeAgo)!
        cell.timeLB.text = self.timeAgoSinceDate(date: dateFromString)
        if (feed[kImageUrl] is NSNull == false) {
            let imageContentLink = feed[kImageUrl] as! String
            let postfixContent = widthHeightScreenx2
            
            ImageRouter.getImage(imageURLString: imageContentLink, sizeString: postfixContent, completed: { (result, error) in
                if (error == nil) {
                    let isUpdateCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                    
                    if (isUpdateCell) {
                        let imageRes = result as! UIImage
                        DispatchQueue.main.async(execute: {
                            cell.imageContentIMV.image = imageRes
                        })
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
        
        // Check Coach
        cell.isUserInteractionEnabled = false
        var coachLink  = kPMAPICOACH
        let coachId = String(format:"%0.f", (userFeed[kId]! as AnyObject).doubleValue)
        coachLink.append(coachId)
        
        cell.avatarBT.layer.borderWidth = 0
        cell.coachLB.text = ""
        cell.coachLBTraillingConstraint.constant = 0
        
        UserRouter.checkCoachOfUser(userID: coachId) { (result, error) in
            let isCoach = result as! Bool
            let isUpdateCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
            
            if (isUpdateCell) {
                cell.isUserInteractionEnabled = true
                cell.isCoach = false
                
                if (error == nil) {
                    if (isCoach == true) {
                        cell.isCoach = true
                        cell.avatarBT.layer.borderWidth = 2
                        
                        cell.coachLBTraillingConstraint.constant = 5
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.coachLB.layoutIfNeeded()
                            cell.coachLB.text = kCoach.uppercased()
                        })
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }
            }.fetchdata()
        
        cell.likeBT.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
        
        //Get Likes
        //            cell.likeBT.isUserInteractionEnabled = true
        //            cell.imageContentIMV.isUserInteractionEnabled = true
        let feedID = String(format:"%0.f", (feed[kId]! as AnyObject).doubleValue)
        
        FeedRouter.getAndCheckFeedLike(feedID: feedID) { (result, error) in
            if (error == nil) {
                let isUpdateCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                
                if (isUpdateCell) {
                    DispatchQueue.main.async(execute: {
                        let likeJson = result as! NSDictionary
                        
                        // Update like number
                        let likeNumber = String(format:"%0.f", likeJson["likeNumber"]!.doubleValue)
                        cell.likeLB.text = likeNumber + " likes"
                        
                        // Update current user liked
                        let userLikedFeed = likeJson["currentUserLiked"] as! Bool
                        if (userLikedFeed == true) {
                            cell.likeBT.setBackgroundImage(UIImage(named: "liked.png"), for: .normal)
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
        
        cell.firstUserCommentLB.text = firstname?.uppercased()
        cell.viewAllBT.tag = indexPath.row
        cell.viewAllBT.addTarget(self, action: #selector(FeaturedViewController.goToFeedDetail(_:)), for: .touchUpInside)
        
        cell.commentBT.tag = indexPath.row
        cell.commentBT.addTarget(self, action: #selector(FeaturedViewController.goToFeedDetail(_:)), for: .touchUpInside)
        
        cell.shareBT.tag = indexPath.row
        cell.shareBT.addTarget(self, action: #selector(FeaturedViewController.showListContext(_:)), for: .touchUpInside)
        
        cell.avatarBT.tag = indexPath.row
        cell.avatarBT.addTarget(self, action: #selector(FeaturedViewController.goProfile(_:)), for: .touchUpInside)
        cell.likeBT.tag = indexPath.row
        cell.postId = String(format:"%0.f", (feed[kId]! as AnyObject).doubleValue)
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell , forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.arrayFeeds.count - 1 && isLoading == false) {
            self.getListFeeds()
        }
    }
}

