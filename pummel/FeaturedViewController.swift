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
import Foundation

class FeaturedViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate, FeedDiscountViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableFeed: UITableView!
    var sizingCell: TagCell?
    var tags = [TagModel]()
    var feedList : [FeedModel] = []
    var discountList : [DiscountModel] = []
    var isStopFetch: Bool!
    var offset: Int = 0
    var offsetDiscount: Int = 0
    
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
        
        let cellNib = UINib(nibName: "FeaturedFeedTableViewCell", bundle: nil)
        self.tableFeed.register(cellNib, forCellReuseIdentifier: "FeaturedFeedTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "addNewPostNotification"), object: nil)
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
        if (self.isGoFeedDetail == false &&
            self.isGoProfileDetail == false) {
            self.refresh()
        }
        
        self.resetCBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
                self.getDiscountList()
                break
            case .authorizedAlways, .authorizedWhenInUse: break
            default: break
            }
        } else {
            self.getDiscountList()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation
        if self.coordinate == nil {
            self.coordinate = location.coordinate
            self.getDiscountList()
        }
        self.coordinate = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch(status) {
        case .restricted, .denied:
            self.getDiscountList()
            break
        case .authorizedAlways, .authorizedWhenInUse: break
        default: break
        }

    }
    
    func refresh() {
        self.tableFeed.isHidden = true
        self.feedList.removeAll()
        self.discountList.removeAll()
        
        self.tableFeed.reloadData { 
            self.refreshControl.endRefreshing()
            self.isStopFetch = false
            self.isLoadDiscount = false
            self.offset = 0
            self.offsetDiscount = 0
            if self.coordinate != nil {
                self.getDiscountList()
            } else {
                self.setupLocation()
            }
            
            self.getFeedList()
        }
    }
    
    func refreshControlTable() {
        self.refresh()
    }
    
    func getDiscountList() {
        var prefix = "\(kPMAPI)\(kPMAPI_DISCOUNTS)"
        prefix.append(String(offsetDiscount))
        
        if self.coordinate != nil {
            let longitude = self.coordinate!.longitude
            let latitude = self.coordinate!.latitude
            
            let geoCoder = CLGeocoder()
            if locationManager.location != nil {
                geoCoder.reverseGeocodeLocation(locationManager.location!, completionHandler: { (placemarks, error) -> Void in
                    let placeMark = placemarks?[0]
                    
                    if ((placeMark) != nil) {
                        var state = ""
                        var country = ""
                        if ((placeMark?.administrativeArea) != nil) {
                            state = (placeMark?.administrativeArea!)!
                            country = (placeMark?.country!)!
                        }
                        
                        // TODO: need Check
//                        let trimCountry = country.replacingOccurrences(of: " ", with: "")
                        
//                        let stateCity = "&" + kState + "=" + state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + "&" + kCountry + "=" + trimCountry.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        
                        self.callAPIDiscount(lontitude: longitude, latitude: latitude, state: state, country: country)
                    } else {
                        self.callAPIDiscount(lontitude: longitude, latitude: latitude, state: nil, country: nil)
                    }
                })
            } else {
                self.callAPIDiscount(lontitude: longitude, latitude: latitude, state: nil, country: nil)
            }
        } else {
            self.callAPIDiscount(lontitude: nil, latitude: nil, state: nil, country: nil)
        }
    }
    
    func callAPIDiscount(lontitude: CLLocationDegrees?, latitude: CLLocationDegrees?, state: String?, country: String?) {
        FeedRouter.getDiscount(longitude: lontitude, latitude: latitude, state: state, country: country, offset: self.offsetDiscount) { (result, error) in
            if (error == nil) {
                let discountArray = result as! [DiscountModel]
                
                for discount in discountArray {
                    if (discount.existInList(discountList: self.discountList) == false) {
                        discount.synsImage()
                        discount.delegate = self // TODO: move to subable place
                        
                        self.discountList.append(discount)
                    }
                }
                
                self.offsetDiscount += 10
                if (discountArray.count > 0) {
                    if self.discountList.count == discountArray.count {
                        self.tableFeed.reloadData()
                    } else if self.headerDiscount != nil {
                        self.headerDiscount.arrayResult = self.discountList
                    } else {
                        self.tableFeed.reloadData()
                    }
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
    }
    
    func getFeedList() {
        if (self.isStopFetch == false && self.isLoading == false) {
            self.isLoading = true
            
            FeedRouter.getListFeed(offset: self.feedList.count, completed: { (result, error) in
                self.isLoading = false
                
                if (error == nil) {
                    let arr = result as! [FeedModel]
                    
                    if (arr.count > 0) {
                        for feed in arr {
                            if (feed.existInList(feedList: self.feedList) == false) {
                                feed.synsNumberLike()
                                feed.synsImage()
                                
                                feed.delegate = self
                                
                                self.feedList.append(feed)
                            }
                        }
                        
                        self.tableFeed.reloadData()
                    } else {
                        self.isStopFetch = true
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
    
    func newPost() {
         self.performSegue(withIdentifier: "goNewPost", sender:nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"NewPost"]
        mixpanel?.track("IOS.Feed", properties: properties)
    }
    
    func goToDetailDiscount(discount: DiscountModel) {
        self.isGoFeedDetail = true
        self.performSegue(withIdentifier: kGoDiscount, sender:discount)
    }
    
    func loadMoreDiscount() {
        if self.isLoadDiscount == false {
            self.isLoadDiscount = true
            self.getDiscountList()
        }
    }
    
    func sharePummel() {
        self.shareTextImageAndURL(sharingText: pummelSlogan, sharingImage: UIImage(named: "shareLogo.png"), sharingURL: NSURL.init(string: kPM))
    }
    
    func shareTextImageAndURL(sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text as AnyObject)
        }
        
        if let image = sharingImage {
            sharingItems.append(image as AnyObject)
        }
        
        if let url = sharingURL {
            sharingItems.append(url as AnyObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func goToFeedDetail(feed: FeedModel) {
        self.isGoFeedDetail = true
        self.performSegue(withIdentifier: "goToFeedDetail", sender: feed)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Comment"]
        mixpanel?.track("IOS.Feed", properties: properties)
    }
    
    func showListContext(feed: FeedModel) {
        let selectReport = { (action:UIAlertAction!) -> Void in
            let postId = String(format:"%ld", feed.id)
            
            FeedRouter.reportFeed(postID: postId, completed: { (result, error) in
                if (error == nil) {
//                    self.feedList.remove(at: self.arrayFeeds.)
                    self.tableFeed.reloadData()
                } else {
                    print("Request failed with error: \(String(describing: error))")
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
    
    func goProfile(feed: FeedModel) {
        let userIDString = String(format: "%ld", feed.userId)
        
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
        cell.tagName.text = tag.tagTitle
        cell.tagName.textColor = UIColor.black
        cell.layer.borderColor = UIColor.clear.cgColor
    }
    
    func goConnect(_ sender: Any) {
        self.performSegue(withIdentifier: kGoConnect, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == kGoConnect) {
            let destination = segue.destination as! ConnectViewController
            let view = sender as! UIView
            let tag = view.tag
            let feed = feedList[tag]
            let currentFeedDetail = feed.userDetail
            destination.coachDetail = currentFeedDetail
            destination.isFromFeed = true
        } else if (segue.identifier == kSendMessageConnection) {
            let destination = segue.destination as! ChatMessageViewController
            
            let coachDetail = (sender as! NSArray)[0] as! NSDictionary
            let message = (sender as! NSArray)[1] as! String
            
            destination.coachName = ((coachDetail[kFirstname] as! String) + " ").uppercased()
            destination.typeCoach = true
            destination.coachId = String(format:"%0.f", (coachDetail[kId]! as AnyObject).doubleValue)
            destination.userIdTarget =  String(format:"%0.f", (coachDetail[kId]! as AnyObject).doubleValue)
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
            let feed = sender as! FeedModel
            destination.feedDetail = feed
        } else if (segue.identifier == kClickURLLink) {
            let destination = segue.destination as! PummelWebViewController
            destination.URL = sender as! URL
        } else if segue.identifier == kGoDiscount {
            let destination = segue.destination as! DiscountDetailVC
            if let dic = sender as? DiscountModel {
                destination.discount = dic
            }
        }
    }
}

// MARK: - DiscountModelDelegate
extension FeaturedViewController: DiscountDelegate {
    func discountSynsDataCompleted(discount: DiscountModel) {
        self.headerDiscount.cv.reloadData()
    }
}

// MARK: - FeedModelDelegate
extension FeaturedViewController: FeedDelegate {
    func feedSynsDataCompleted(feed: FeedModel) {
        let index = self.feedList.index(of: feed)
        
        if (index != nil) {
            let indexPath = IndexPath(row: index!, section: 1)
        
            self.tableFeed.reloadRows(at: [indexPath], with: .fade)
            
            let invisibleIndexPath = self.tableFeed.indexPathsForVisibleRows!
            
            for inviIndex in invisibleIndexPath {
                if (indexPath.row == inviIndex.row) {
                    
                    
                    break
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension FeaturedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return nil
        }
        
        if self.discountList.count == 0 {
            return nil
        }
        
        if self.headerDiscount == nil {
            self.headerDiscount = FeedDiscountView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            self.headerDiscount.delegate = self
        }
        self.headerDiscount.arrayResult = self.discountList
        
        return self.headerDiscount
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && self.discountList.count > 0) {
            return 200
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        
        // Hidden table view if no data
        self.tableFeed.isHidden = (self.feedList.count == 0)
        
        return self.feedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kFeaturedFeedTableViewCell) as! FeaturedFeedTableViewCell
        
        cell.separatorInset = UIEdgeInsets()
        let feed = feedList[indexPath.row]
        
        cell.setupData(feed: feed)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell , forRowAt indexPath: IndexPath) {
        if (indexPath.row == self.feedList.count - 1) {
            self.getFeedList()
        }
    }
}

extension FeaturedViewController : FeaturedFeedTableViewCellDelegate {
    func FeaturedFeedCellGoToDetail(cell : FeaturedFeedTableViewCell) {
        let indexPath = self.tableFeed.indexPath(for: cell)
        
        if (indexPath != nil) {
            let feed = self.feedList[(indexPath?.row)!]
            
            self.goToFeedDetail(feed: feed)
        }
    }
    
    func FeaturedFeedCellShowContext(cell : FeaturedFeedTableViewCell) {
        let indexPath = self.tableFeed.indexPath(for: cell)
        
        if (indexPath != nil) {
            let feed = self.feedList[(indexPath?.row)!]
            
            self.showListContext(feed: feed)
        }
    }
    
    func FeaturedFeedCellShowProfile(cell : FeaturedFeedTableViewCell) {
        let indexPath = self.tableFeed.indexPath(for: cell)
        
        if (indexPath != nil) {
            let feed = self.feedList[(indexPath?.row)!]
            
            self.goProfile(feed: feed)
        }
    }
    
    func FeaturedFeedCellInteractWithURL(URL: URL) {
        self.performSegue(withIdentifier: kClickURLLink, sender: URL)
    }
}

