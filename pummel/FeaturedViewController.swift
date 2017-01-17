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

class FeaturedViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableFeed: UITableView!
    var sizingCell: TagCell?
    var tags = [Tag]()
    var arrayFeeds : [NSDictionary] = []
    var currentFeedDetail: NSDictionary!
    var isStopFetch: Bool!
    var offset: Int = 0
    @IBOutlet weak var noActivityYetLB: UILabel!
    @IBOutlet weak var connectWithCoachLB: UILabel!
    var refreshControl: UIRefreshControl!
    var isLoading : Bool = false
    var isGoFeedDetail : Bool = false
    var isGoProfileDetail : Bool = false
    
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
        if (isLoading == false && isGoFeedDetail == false && isGoProfileDetail == false) {
            self.tableFeed.hidden = true
            self.refresh()
        }
        self.noActivityYetLB.font = .pmmPlayFairReg18()
        self.connectWithCoachLB.font = .pmmMonLight13()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let touch3DType = defaults.objectForKey(k_PM_3D_TOUCH) as! String
        if touch3DType == "3dTouch_4" {
            defaults.setObject("1", forKey: k_PM_3D_TOUCH)
            self.sharePummel()
        }
    }
    
    func refresh() {
        self.tableFeed.hidden = true
        self.arrayFeeds.removeAll()
        self.tableFeed.reloadData { 
            self.refreshControl.endRefreshing()
            self.isStopFetch = false
            self.offset = 0
            self.getListFeeds()
        }
    }
    
    func refreshControlTable() {
        if (isLoading == false) {
            self.refresh()
        }
    }
    
    func getListFeeds() {
        if (self.isStopFetch == false) {
            self.isLoading = true
            var prefix = kPMAPI_POST_OFFSET
            prefix.appendContentsOf(String(offset))
            Alamofire.request(.GET, prefix)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        
                        if (response.result.value == nil) {return}
                        let arr = response.result.value as! [NSDictionary]
                        if (arr.count > 0) {
                            self.arrayFeeds += arr
                            self.tableFeed.hidden = (self.arrayFeeds.count > 0) ?  false : true
                            self.offset += 10
                            self.isLoading = false
                            self.tableFeed.reloadData({ 
                                self.tableFeed.hidden = false
                            })
                        } else {
                            self.isLoading = false
                            self.isStopFetch = true
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
                    } else {
                        self.isLoading = false
                        self.isStopFetch = true
                    }
            }
        }
    }
    
    func newPost() {
         self.performSegueWithIdentifier("goNewPost", sender:nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Category": "IOS.Feed", "Name": "Navigation Click", "Label":"NewPost"]
        mixpanel.track("Event", properties: properties)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            if !(userFeed[kImageUrl] is NSNull) {
                let imageLink = userFeed[kImageUrl] as! String
                var photoLink = kPMAPI
                photoLink.appendContentsOf(imageLink)
                let postfix = widthHeight80
                photoLink.appendContentsOf(postfix)
                if (NSCache.sharedInstance.objectForKey(photoLink) != nil) {
                    let imageRes = NSCache.sharedInstance.objectForKey(photoLink) as! UIImage
                    cell.avatarBT.setBackgroundImage(imageRes, forState: .Normal)
                } else {
                    cell.avatarBT.setBackgroundImage(nil, forState: .Normal)
                    Alamofire.request(.GET, photoLink)
                        .responseImage { response in
                            if (response.response?.statusCode == 200) {
                                let imageRes = response.result.value! as UIImage
                                let updateCell = tableView .cellForRowAtIndexPath(indexPath)
                                NSCache.sharedInstance.setObject(imageRes, forKey: photoLink)
                                dispatch_async(dispatch_get_main_queue(),{
                                    if updateCell != nil {
                                         cell.avatarBT.setBackgroundImage(imageRes, forState: .Normal)
                                    }
                                })
                            }
                    }
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
            if !(feed[kImageUrl] is NSNull) {
                let imageContentLink = feed[kImageUrl] as! String
                var photoContentLink = kPMAPI
                photoContentLink.appendContentsOf(imageContentLink)
                let postfixContent = widthEqual.stringByAppendingString(String(self.view.frame.size.width*2)).stringByAppendingString(heighEqual).stringByAppendingString(String(self.view.frame.size.width*2))
                photoContentLink.appendContentsOf(postfixContent)
                if (NSCache.sharedInstance.objectForKey(photoContentLink) != nil) {
                    let imageRes = NSCache.sharedInstance.objectForKey(photoContentLink) as! UIImage
                    cell.imageContentIMV.image = imageRes
                } else {
                    Alamofire.request(.GET, photoContentLink)
                        .responseImage { response in
                            if (response.response?.statusCode == 200) {
                                let imageRes = response.result.value! as UIImage
                                NSCache.sharedInstance.setObject(imageRes, forKey: photoContentLink)
                                let updateCell = tableView .cellForRowAtIndexPath(indexPath)
                                dispatch_async(dispatch_get_main_queue(),{
                                    if updateCell != nil {
                                        cell.imageContentIMV.image = imageRes
                                    }
                                })
                            }
                    }
                }
            }
        
            // Check Coach
            var coachLink  = kPMAPICOACH
            let coachId = String(format:"%0.f", userFeed[kId]!.doubleValue)
            coachLink.appendContentsOf(coachId)
            Alamofire.request(.GET, coachLink)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        cell.isCoach = true
                    } else {
                        cell.isCoach = false
                    }
            }
        
            cell.likeBT.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
        
            //Get Likes
//            cell.likeBT.userInteractionEnabled = true
//            cell.imageContentIMV.userInteractionEnabled = true
            var likeLink  = kPMAPI_LIKE
            likeLink.appendContentsOf(String(format:"%0.f", feed[kId]!.doubleValue))
            likeLink.appendContentsOf(kPM_PATH_LIKE)
            Alamofire.request(.GET, likeLink)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        let likeJson = response.result.value as! NSDictionary
                        var likeNumber = String(format:"%0.f", likeJson[kCount]!.doubleValue)
                        likeNumber.appendContentsOf(" likes")
                        cell.likeLB.text = likeNumber
                        let rows = likeJson[kRows] as! [NSDictionary]
                        let defaults = NSUserDefaults.standardUserDefaults()
                        let currentId = defaults.objectForKey(k_PM_CURRENT_ID) as! String
                        for row in rows {
                            if (String(format:"%0.f", row[kUserId]!.doubleValue) == currentId){
                               let updateCell = tableView .cellForRowAtIndexPath(indexPath)
                                dispatch_async(dispatch_get_main_queue(),{
                                    if updateCell != nil {
                                        cell.likeBT.setBackgroundImage(UIImage(named: "liked.png"), forState: .Normal)
//                                        cell.likeBT.userInteractionEnabled = false
//                                        cell.imageContentIMV.userInteractionEnabled = false
                                    }
                                })
                                break
                            }
                        }
                    } else {
                    }
            }
        
            cell.firstContentCommentLB.text = feed[kText] as? String
            cell.firstContentCommentConstrant.constant = (cell.firstContentCommentLB.text?.heightWithConstrainedWidth(cell.firstContentCommentLB.frame.width, font: cell.firstContentCommentLB.font))! + 10
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
        self.shareTextImageAndURL(pummelSlogan, sharingImage: UIImage(named: "pummelLogo.png"), sharingURL: NSURL.init(string: kPM))
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
        let properties = ["Category": "IOS.Feed", "Name": "Navigation Click", "Label":"Comment"]
        mixpanel.track("Event", properties: properties)
    }
    
    func showListContext(sender: UIButton) {
        let selectReport = { (action:UIAlertAction!) -> Void in
            
            let feed = self.arrayFeeds[sender.tag]
            let postId = String(format:"%0.f", feed[kId]!.doubleValue)
            Alamofire.request(.PUT, kPMAPI_REPORT, parameters: ["postId":postId])
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        self.arrayFeeds.removeAtIndex(sender.tag)
                        self.tableFeed.reloadData()
                    }
            }

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
        let cell = tableFeed.cellForRowAtIndexPath(NSIndexPath.init(forRow: sender.tag, inSection: 0)) as! FeaturedFeedTableViewCell
        self.isGoProfileDetail = true
        if (cell.isCoach == true) {
            self.performSegueWithIdentifier(kGoProfile, sender:sender)
        } else {
            self.performSegueWithIdentifier(kGoUserProfile, sender:sender)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(kGoProfile, sender: indexPath.row - 1)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == kGoConnect) {
            let destination = segue.destinationViewController as! ConnectViewController
            let tag = sender.tag
            let feed = arrayFeeds[tag] 
            currentFeedDetail = feed[kUser] as! NSDictionary
            destination.coachDetail = currentFeedDetail
            destination.isFromFeed = true
        } else if (segue.identifier == kGoProfile) {
            let destination = segue.destinationViewController as! CoachProfileViewController
            let feed = arrayFeeds[sender.tag] 
            currentFeedDetail = feed[kUser] as! NSDictionary
            destination.coachDetail = currentFeedDetail
            destination.coachTotalDetail = feed
            destination.isFromFeed = true
        } else if (segue.identifier == kGoUserProfile) {
            let destination = segue.destinationViewController as! UserProfileViewController
            let feed = arrayFeeds[sender.tag] 
            currentFeedDetail = feed[kUser] as! NSDictionary
            destination.userDetail = currentFeedDetail
            destination.userId = String(format:"%0.f", currentFeedDetail[kId]!.doubleValue)
        } else if (segue.identifier == kSendMessageConnection) {
            let destination = segue.destinationViewController as! ChatMessageViewController
            
            destination.coachName = ((currentFeedDetail[kFirstname] as! String) .stringByAppendingString(" ")).uppercaseString
            destination.typeCoach = true
            destination.coachId = String(format:"%0.f", currentFeedDetail[kId]!.doubleValue)
            destination.userIdTarget =  String(format:"%0.f", currentFeedDetail[kId]!.doubleValue)
            destination.preMessage = sender as! String
        } else if (segue.identifier == "goToFeedDetail") {
            let destination = segue.destinationViewController as! FeedViewController
            let feed = arrayFeeds[sender.tag] 
            destination.feedDetail = feed
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

