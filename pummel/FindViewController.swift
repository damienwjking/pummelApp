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
//import ReactiveUI
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
    var currentOffset: CGPoint = CGPoint()
    var touchPoint: CGPoint = CGPoint()
    var loadmoreTime = 0
    let badgeLabel = UILabel()
    
    @IBOutlet weak var noResultViewVerticalConstraint: NSLayoutConstraint! // default -32
    @IBOutlet weak var noResultLB: UILabel!
    @IBOutlet weak var noResultContentLB: UILabel!
    @IBOutlet weak var refineSearchBT: UIButton!
    let defaults = UserDefaults.standard
    
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
        self.navigationController!.navigationBar.isTranslucent = false
        self.tabBarController?.navigationController?.navigationBar.addSubview(self.badgeLabel)
        
        self.setupCollectionView()
        self.setupHorizontalView()
        
        noResultLB.font = .pmmPlayFairReg18()
        noResultContentLB.font = .pmmMonLight13()
        refineSearchBT.titleLabel!.font = .pmmMonReg12()
        refineSearchBT.layer.cornerRadius = 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startSearchCoachNotification), name: NSNotification.Name(rawValue: k_PM_FIRST_SEARCH_COACH), object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(self.updateSMLCBadge), name: NSNotification.Name(rawValue: k_PM_SHOW_MESSAGE_BADGE), object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(self.updateLBadge(notification:)), name: NSNotification.Name(rawValue: k_PM_UPDATE_LEAD_BADGE), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupLayout()
        
        let showSeachViewController = self.defaults.bool(forKey: "SHOW_SEARCH_AFTER_REGISTER")
        if (showSeachViewController == true) {
            self.defaults.set(false, forKey: "SHOW_SEARCH_AFTER_REGISTER")
            self.defaults.synchronize()
            performSegue(withIdentifier: "letUsHelp", sender: nil)
        }
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FindViewController.refind), name: NSNotification.Name(rawValue: "SELECTED_MIDDLE_TAB"), object: nil)
        
        self.stopSearch = false
        
        self.badgeLabel.alpha = 1
        
        self.endPagingCarousel(scrollView: self.collectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let moveScreenType = defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_1 {
            self.refind()
        } else if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_SEARCH {
            self.defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        }
        
        self.collectionView.reloadData { 
            self.checkPlayVideoOnPresentCell()
        }
        
        self.coachOffset = 0
        self.stopGetCoach = false
        self.getCoachArray()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SELECTED_MIDDLE_TAB"), object: nil)

        self.badgeLabel.alpha = 0
    }
    
    func setupLayout() {
        self.tabBarController?.title = "RESULTS"
        
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let selectedImage = UIImage(named: "search")
        self.tabBarItem.image = selectedImage?.withRenderingMode(.alwaysOriginal)
        self.tabBarItem.selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        
        // Left button
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            let leftBarButtonItem = UIBarButtonItem(title:"CLIENTS",
                                                    style: UIBarButtonItemStyle.plain,
                                                    target: self,
                                                    action: #selector(FindViewController.btnClientClick))
            self.tabBarController?.navigationItem.leftBarButtonItem = leftBarButtonItem
        } else {
            let leftBarButtonItem = UIBarButtonItem(title:"COACHES",
                                                    style: UIBarButtonItemStyle.plain,
                                                    target: self,
                                                    action: #selector(FindViewController.btnCoachsClick))
            self.tabBarController?.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
    }
    
    func setupHorizontalView() {
        self.horizontalTableView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2.0))
        
        self.separeateline!.backgroundColor = UIColor.pmmWhiteColor()
        
        self.horizontalButton.titleLabel?.font = UIFont.pmmMonLight11()
        self.horizontalButton.setTitleColor(UIColor.pmmBrightOrangeColor(), for: .normal)
//        self.horizontalButton.setTitle("Show List Coach", for: .normal)
        
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.horizontalViewSwipeUp))
        swipeUp.direction = .right // Up direction: horizontal table view tranform 90 degree
        self.horizontalTableView.addGestureRecognizer(swipeUp)
    }
    
    func setupCollectionView() {
        // register cell
        let nibName = UINib(nibName: "CardContentView", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "CardView")
        
        let noResultNibName = UINib(nibName: "CardContentNoResult", bundle: nil)
        self.collectionView.register(noResultNibName, forCellWithReuseIdentifier: "SearchNoCoach")
        
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
        
        self.expandCollapseCoachView(isExpand: false)
        
        self.searchCoachPage()
    }
    
    func searchCoachPage() {
        if (self.stopSearch == false) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let aVariable = appDelegate.searchDetail as NSDictionary
            
            var gender = ""
            if ((aVariable[kGender] as! String) != kDontCare) {
                gender = aVariable[kGender] as! String
            }
            
            let offset = self.loadmoreTime * 30
            let longitude = aVariable[kLong] as! CLLocationDegrees
            let latitude = aVariable[kLat] as! CLLocationDegrees
            let stage = aVariable[kState] as! String
            let city = aVariable[kCity] as! String
            
            let tagArray = aVariable["tagIds"] as? NSArray
            
            UserRouter.searchCoachNearby(gender: gender, tags: tagArray!, longitude: longitude, latitute: latitude, stage: stage, city: city, offset: offset, completed: { (result, error) in
                if (error == nil) {
                    if (result == nil) {
                        self.stopSearch = true
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AFTER_SEARCH_PAGE"), object: nil)
                        
                        return
                    }
                    
                    // First time search
                    var needReloadCollection = true
                    
                    if (self.loadmoreTime == 0) {
                        PMHelper.actionWithDelaytime(delayTime: 2, delayAction: { (_) in
                            self.arrayResult.removeAll()
                            self.arrayResult = result  as! [NSDictionary]
                            self.viewDidLayoutSubviews()
                            self.collectionView.contentOffset = CGPoint()
                            
                            // Post notification for dismiss search animation screen
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AFTER_SEARCH_PAGE"), object: nil)
                        })
                    } else {
                        if ((result as! NSArray).count == 0) {
                            self.stopSearch = true
                            
                            needReloadCollection = false
                        } else {
                            let rArray = result as! [NSDictionary]
                            self.arrayResult += rArray
                        }
                    }
                    
                    if (needReloadCollection == true) {
                        // Increase load more time and reload page
                        self.collectionView.reloadData {
                            self.loadmoreTime = self.loadmoreTime + 1
                        }
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AFTER_SEARCH_PAGE"), object: nil)
                }
            }).fetchdata()
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
                            if (coachDetail.existInList(userList: self.coachArray) == false) {
                                self.coachArray.append(coachDetail)
                            }
                        }
                    }
                    
                    self.coachOffset = self.coachOffset + 20
                    self.horizontalTableView.reloadData()
                } else {
                    self.stopGetCoach = true
                    
                    print("Request failed with error: \(String(describing: error))")
                }
                }.fetchdata()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "letUsHelp") {
            // Do nothing
        } else if (segue.identifier == kGoConnect) {
            let destination = segue.destination as! ConnectViewController
            let view = sender as! UIView
            let totalDetail = arrayResult[view.tag]
            destination.coachDetail = totalDetail[kUser] as! NSDictionary
        } else if (segue.identifier == kSendMessageConnection) {
            let destination = segue.destination as! ChatMessageViewController
            
            let coachDetail = (sender as! NSArray)[0] as! NSDictionary
            let message = (sender as! NSArray)[1] as! String
            
            let firstName = coachDetail[kFirstname] as! String
            destination.coachName = (firstName + " ").uppercased()
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
        }
    }

    @IBAction func refind() {
        self.resultIndex = 0
        performSegue(withIdentifier: "letUsHelp", sender: nil)
        
        // Tracker mixpanel
        let mixpanel = Mixpanel.sharedInstance()
        let properties = ["Name": "Navigation Click", "Label":"Refine"]
        mixpanel?.track("IOS.Search", properties: properties)
    }
    
    func updateLBadge(notification: NSNotification) {
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            let badgeValue = notification.object as? Int
            
            if (badgeValue != nil && badgeValue! > 0) {
                // Create badge label
                self.badgeLabel.textColor = UIColor.white
                self.badgeLabel.font = UIFont.systemFont(ofSize: 12)
                self.badgeLabel.backgroundColor = UIColor.pmmBrightOrangeColor()
                self.badgeLabel.textAlignment = .center
                
                // Add badge label value & layout
                self.badgeLabel.text = String(format: "%d", badgeValue!)
                self.badgeLabel.sizeToFit()
                
                let maxSize = max(badgeLabel.frame.width, badgeLabel.frame.height)
                self.badgeLabel.layer.cornerRadius = maxSize / 2
                self.badgeLabel.layer.masksToBounds = true
                self.badgeLabel.frame = CGRect(x: 70, y: 5, width: maxSize, height: maxSize)
                
                self.badgeLabel.isHidden = false
            } else {
                self.badgeLabel.isHidden = true
            }
        }
    }
    
    func btnClientClick() {
        self.performSegue(withIdentifier: "gotoClient", sender: nil)
    }
    
    func btnCoachsClick() {
//        self.performSegue(withIdentifier: "gotoCoachs", sender: nil)
        
        if (self.horizontalTableView.alpha == 0) {
            self.expandCollapseCoachView(isExpand: true)
        } else {
            self.expandCollapseCoachView(isExpand: false)
        }
    }
    
    @IBAction func horizontalViewClicked(_ sender: Any) {
        // For expand coach view
        self.expandCollapseCoachView(isExpand: true)
    }
    
    func horizontalViewSwipeUp() {
        self.expandCollapseCoachView(isExpand: false)
    }
    
    func expandCollapseCoachView(isExpand: Bool) {
        self.tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = false
        
        if (isExpand == true) {
            self.horizontalViewHeightConstraint.constant = 120
            self.noResultViewVerticalConstraint.constant = -32 + 60 // Default vertical value
            
            self.separeateline.isHidden = true // For animation
            
            UIView.animate(withDuration: 0.3, animations: {
                self.horizontalTableView.alpha = 1
                self.tabBarController?.navigationItem.leftBarButtonItem?.customView?.alpha = 1
                
                self.horizontalButton.isHidden = true
                
                self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmLightBrightOrangeColor()], for: .normal)
                
                self.horizontalView.layoutIfNeeded()
            }) { (_) in
                self.separeateline.isHidden = false
                
                self.tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = true
            }
        } else {
            self.horizontalViewHeightConstraint.constant = 0
            self.noResultViewVerticalConstraint.constant = -32 // Default vertical value
            
            self.separeateline.isHidden = true // For animation
            
            UIView.animate(withDuration: 0.3, animations: {
                self.horizontalTableView.alpha = 0
                self.tabBarController?.navigationItem.leftBarButtonItem?.customView?.alpha = 0.5
                
                self.horizontalButton.isHidden = false
                
                self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], for: .normal)
                
                self.horizontalView.layoutIfNeeded()
            }) { (_) in
                self.separeateline.isHidden = false
                
                self.tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = true
            }
        }
    }
}

// MARK: - CardViewCellDelegate
extension FindViewController: CardViewCellDelegate {
    func cardViewCellTagClicked(cell: CardViewCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        let cellIndex = indexPath!.row
        let userID = self.arrayResult[cellIndex][kUserId] as! Int
        let userIDString = String(format: "%ld", userID)
        
        PMHelper.showCoachOrUserView(userID: userIDString)
    }
    
    func cardViewCellMoreInfoClicked(cell: CardViewCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        let cellIndex = indexPath!.row
        let userID = self.arrayResult[cellIndex][kUserId] as! Int
        let userIDString = String(format: "%ld", userID)
        
        PMHelper.showCoachOrUserView(userID: userIDString)
    }
}

extension FindViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.coachArray.count == 0) {
            self.horizontalView.isHidden = true
        } else {
            self.horizontalView.isHidden = false
        }
        
        return self.coachArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (defaults.bool(forKey: k_PM_IS_COACH) == true) {
            self.horizontalViewHeightConstraint.constant = 0
            
            return 0
        } else {
            if (self.horizontalTableView.alpha == 1) {
                self.expandCollapseCoachView(isExpand: true)
            }
            
            return 96
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == self.coachArray.count - 2) {
            self.getCoachArray()
        }
        
        let cellId = "HorizontalCell"
        var cell:HorizontalCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? HorizontalCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed(cellId, owner: nil, options: nil)!.first as? HorizontalCell
            cell!.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
        }
        cell!.addButton.isHidden = true
        cell?.imageV.image = UIImage(named: "display-empty.jpg")
        cell?.imageV.layer.borderWidth = 2
        
        let coach = self.coachArray[indexPath.row]
        let targetUserId = String(format:"%ld", coach.id)
        
        if (coach.firstname?.isEmpty == false) {
            self.setupDataForCell(cell: cell!, coach: coach)
        } else {
            UserRouter.getUserInfo(userID: targetUserId, completed: { (result, error) in
                if (error == nil) {
                    let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                    if visibleCell == true {
                        let userData = result as! NSDictionary
                        coach.parseData(data: userData)
                        
                        self.setupDataForCell(cell: cell!, coach: coach)
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
        cell!.selectionStyle = .none
        return cell!
    }
    
    func setupDataForCell(cell: HorizontalCell, coach: UserModel) {
        cell.name.text = coach.firstname!.uppercased()
        
        if (coach.imageUrl != nil) {
            let imageURLString = coach.imageUrl
            
            ImageVideoRouter.getImage(imageURLString: imageURLString!, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                        let imageRes = result as! UIImage
                        cell.imageV.image = imageRes
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        } else {
            cell.imageV.image = UIImage(named: "display-empty.jpg")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.coachArray.count {
            let cellIndex = indexPath.row
            let userID = self.coachArray[cellIndex].id
            let userIDString = String(format: "%ld", userID)
            
            PMHelper.showCoachOrUserView(userID: userIDString)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FindViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            if (self.arrayResult.count == 0) {
                self.collectionView.isHidden = true
                
                return 0
            } else {
                self.collectionView.isHidden = false
                
                return self.arrayResult.count + 1
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            if indexPath.row == self.arrayResult.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchNoCoach", for: indexPath) as! NoResultCell
                
                // add refind action
                cell.refineSearchBT.addTarget(self, action: #selector(refind), for: .touchUpInside)
                
                // add Swipe gesture
                if (cell.gestureRecognizers == nil || (cell.gestureRecognizers?.count)! < 1) {
                    let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeRight))
                    swipeRightGesture.direction = .right
                    cell.addGestureRecognizer(swipeRightGesture)
                }
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardView", for: indexPath) as! CardViewCell
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
                    let tag = TagModel()
                    tag.tagTitle = tagContent[kTitle] as? String
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
                
                let firstName = coachDetail[kFirstname] as! String
                if (coachDetail[kLastName] is NSNull == false) {
                    let lastName = coachDetail[kLastName] as! String
                    
                    cell.cardView.nameLB.text = firstName + " " + lastName
                } else {
                    cell.cardView.nameLB.text = firstName
                }
                
                // Show Coach avatar
                cell.cardView.addressLB.font = .pmmPlayFairReg11()
                if (coachTotalDetail[kServiceArea] is NSNull == false) {
                    cell.cardView.addressLB.text = coachTotalDetail[kServiceArea] as? String
                }
                
                if (coachDetail[kImageUrl] is NSNull == false) {
                    let imageLink = coachDetail[kImageUrl] as! String
                    
                    ImageVideoRouter.getImage(imageURLString: imageLink, sizeString: widthHeightScreen, completed: { (result, error) in
                        if (error == nil) {
                            let imageRes = result as! UIImage
                            cell.cardView.avatarIMV.image = imageRes
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }).fetchdata()
                }
                
                // Business ImageView
                cell.cardView.connectV.isHidden = true
                if (coachDetail[kBusinessId] is NSNull == false) {
                    let businessId = String(format:"%0.f", (coachDetail[kBusinessId]! as AnyObject).doubleValue)
                    
                    ImageVideoRouter.getBusinessLogo(businessID: businessId, sizeString: widthHeight120, completed: { (result, error) in
                        if (error == nil) {
                            cell.cardView.connectV.isHidden = false
                            
                            let imageRes = result as! UIImage
                            cell.cardView.businessIMV.image = imageRes
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }).fetchdata()
                }
                
                // add Swipe gesture
                if (cell.gestureRecognizers == nil || (cell.gestureRecognizers?.count)! < 2) {
                    
                    let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeLeft))
                    swipeLeftGesture.direction = .left
                    cell.addGestureRecognizer(swipeLeftGesture)
                    
                    let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeRight))
                    swipeRightGesture.direction = .right
                    cell.addGestureRecognizer(swipeRightGesture)
                }
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return self.collectionViewLayout.itemSize
        }
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            if indexPath.row < self.arrayResult.count {
                let cellIndex = indexPath.row
                let userID = self.arrayResult[cellIndex][kUserId] as! Int
                let userIDString = String(format: "%ld", userID)
                
                PMHelper.showCoachOrUserView(userID: userIDString)
            }
        }
    }
    
    
    
    func checkPlayVideoOnPresentCell() {
        PMHelper.actionWithDelaytime(delayTime: 0.1) { (_) in
            // Play video on present cell
            let cellIndex = Int(round(self.collectionView.contentOffset.x / self.widthCell))
            let indexPath = NSIndexPath(row: cellIndex, section: 0)
            let cell = self.collectionView.cellForItem(at: indexPath as IndexPath) as? CardViewCell
            if (cell != nil) {
                // Show video layout
                let coachDetail = self.arrayResult[cellIndex]
                let userDetail = coachDetail[kUser] as! NSDictionary
                let videoURL = userDetail[kVideoURL] as? String
                if (videoURL != nil && videoURL!.isEmpty == false) {
                    cell?.playVideoButton.isHidden = false
                    cell?.playVideoButton.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    func carouselSwipeLeft() {
        var offsetX = self.collectionView.contentOffset.x + self.widthCell
        let remainSpace = self.collectionView.contentSize.width - self.widthCell
        if (offsetX > remainSpace) {
            offsetX = remainSpace
        }
        
        let newContentOffset = CGPoint(x: offsetX, y: 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.collectionView.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(scrollView: self.collectionView)
            self.checkPlayVideoOnPresentCell()
        }
    }
    
    func carouselSwipeRight() {
        var offsetX = self.collectionView.contentOffset.x - self.widthCell
        offsetX = offsetX < 0 ? 0 : offsetX
        
        let newContentOffset = CGPoint(x: offsetX, y: 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.collectionView.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(scrollView: self.collectionView)
            self.checkPlayVideoOnPresentCell()
        }
    }
    
    func carouselLongPress(longPress:UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            self.currentOffset = self.collectionView.contentOffset
            self.touchPoint = longPress.location(ofTouch: 0, in: self.collectionView)
            break
        case .changed:
            let movePoint = longPress.location(ofTouch: 0, in: self.collectionView)
            let deltaX = (self.touchPoint.x - movePoint.x)
            
            if deltaX > 3 {
                let newOffsetX = self.currentOffset.x + deltaX
                self.collectionView.setContentOffset(CGPoint(x: newOffsetX, y: 0), animated: false)
            }
            break
        case .ended:
            print("end")
            self.endPagingCarousel(scrollView: self.collectionView)
            
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
