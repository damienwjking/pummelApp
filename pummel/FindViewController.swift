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
import MessageUI
import Cartography
import UIColor_FlatColors

class FindViewController: BaseViewController, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout{
    var loadCardsFromXib = true
    
    var arrayResult : [NSDictionary] = []
    var loadmoreTime = 0
    var isStopSearch: Bool = false
    
    var followCoachList: [UserModel] = []
    var followCoachOffset = 0
    var isStopGetFollowCoach: Bool = false
    
    var leadList: [UserModel] = []
    var leadOffset = 0
    var isStopGetLead: Bool = false
    
    var totalFollowCoach = 0
    var totalLead = 0
    var totalPurchaseProduct = 0
    var numberNewMessage = 0
    var numberProfileView = 0
    var numberSocialClick = 0
    
    var purchaseProductOffset = 0
    var isStopGetPurchaseProduct = false
    var purchaseProductList: [ProductModel] = []
    
    var arrayTags : NSArray!
    var widthCell : CGFloat = 0.0
    let badgeLabel = UILabel()
    
    var lastTrackingCoachID = ""
    
    let defaults = UserDefaults.standard
    
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var scrollView: UIScrollView!
    
    // I know name is bullshit, please don't f**k me
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var firstCollectionView: UICollectionView!
    @IBOutlet weak var firstCollectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var firstViewHeightConstraint: NSLayoutConstraint! // Default: 145
    
    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var totalNewMessageLabel: UILabel!
    @IBOutlet weak var totalSocialClickLabel: UILabel!
    @IBOutlet weak var totalProfileViewLabel: UILabel!
    @IBOutlet weak var trackViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondCollectionView: UICollectionView!
    @IBOutlet weak var secondCollectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var secondViewHeightConstraint: NSLayoutConstraint! // Default: 145
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchCollectionViewLayout: UICollectionViewFlowLayout!
    
    // MARK: - View controller circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.isTranslucent = false
        self.tabBarController?.navigationController?.navigationBar.addSubview(self.badgeLabel)
        
        self.setupCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startSearchCoachNotification), name: NSNotification.Name(rawValue: k_PM_FIRST_SEARCH_COACH), object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(self.updateSMLCBadge), name: NSNotification.Name(rawValue: k_PM_SHOW_MESSAGE_BADGE), object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(self.updateLBadge(notification:)), name: NSNotification.Name(rawValue: k_PM_UPDATE_LEAD_BADGE), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupTabNavigationBar()
        
        self.refeshData()
        
        let showSeachViewController = self.defaults.bool(forKey: "SHOW_SEARCH_AFTER_REGISTER")
        if (showSeachViewController == true) {
            self.defaults.set(false, forKey: "SHOW_SEARCH_AFTER_REGISTER")
            self.defaults.synchronize()
            performSegue(withIdentifier: "letUsHelp", sender: nil)
        }
        
        self.isStopSearch = false
        
        self.badgeLabel.alpha = 1
        
        self.endPagingCarousel(scrollView: self.searchCollectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let moveScreenType = defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_1 {
            self.refind()
        } else if moveScreenType == k_PM_MOVE_SCREEN_DEEPLINK_SEARCH {
            self.defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.badgeLabel.alpha = 0
    }
    
    func setupTabNavigationBar() {
        // Tab bar
        let selectedImage = UIImage(named: "search")
        self.tabBarItem.image = selectedImage?.withRenderingMode(.alwaysOriginal)
        self.tabBarItem.selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        
        // Navigation bar
        self.tabBarController?.title = "RESULTS"
        
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        // Left bar button
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            let leftBarButtonItem = UIBarButtonItem(title:"CLIENTS", style: .plain, target: self, action: #selector(self.btnClientClick))
            leftBarButtonItem.setAttributeForAllStage()
            
            self.tabBarController?.navigationItem.leftBarButtonItem = leftBarButtonItem
        } else {
            self.tabBarController?.navigationItem.leftBarButtonItem = nil
        }
        
        // Right bar button
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        let rightBarButtonItem = UIBarButtonItem(title:"FIND", style: .plain, target: self, action: #selector(self.refind))
        rightBarButtonItem.setAttributeForAllStage()
        
        self.tabBarController?.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func refeshData() {
        // First collection view
        // Tracking view
        self.leadList.removeAll()
        self.followCoachList.removeAll()
        
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            self.leadOffset = 0
            self.isStopGetLead = false
            self.getTotalLead()
            
            self.getCoachTrackInfo()
        } else {
            self.followCoachOffset = 0
            self.isStopGetFollowCoach = false
            self.getFollowCoach()
        }
        
        // Second collection view
        self.purchaseProductOffset = 0
        self.isStopGetPurchaseProduct = false
        self.purchaseProductList.removeAll()
        self.getPurchaseProduct()
        
        self.updateLayout()
    }
    
    func setupCollectionView() {
        // Setup scrollview
        self.refreshControl.addTarget(self, action: #selector(self.refeshData), for: .valueChanged)
        self.scrollView.addSubview(self.refreshControl)
        
        // First collection view
        let leadNib = UINib(nibName: "LeadCollectionViewCell", bundle: nil)
        self.firstCollectionView.register(leadNib, forCellWithReuseIdentifier: "LeadCollectionViewCell")
        
        self.firstCollectionViewLayout.itemSize = CGSize(width: 90, height: 95)
        self.firstCollectionViewLayout.minimumLineSpacing = 0
        self.firstCollectionViewLayout.sectionInset =  UIEdgeInsetsMake(0, 5, 0, 0)
        
         // Second collection view
        let purchaseNib = UINib(nibName: "ProductPurchasedCell", bundle: nil)
        self.secondCollectionView.register(purchaseNib, forCellWithReuseIdentifier: "ProductPurchasedCell")
        
        self.secondCollectionViewLayout.itemSize = CGSize(width: SCREEN_WIDTH - 100, height: 100)
        self.secondCollectionViewLayout.minimumLineSpacing = 0
        self.secondCollectionViewLayout.sectionInset =  UIEdgeInsetsMake(0, 15, 0, 0)
        
        // Search collection view
        let nibName = UINib(nibName: "CardViewCell", bundle: nil)
        self.searchCollectionView.register(nibName, forCellWithReuseIdentifier: "CardViewCell")
        
        let noResultNibName = UINib(nibName: "NoResultCell", bundle: nil)
        self.searchCollectionView.register(noResultNibName, forCellWithReuseIdentifier: "NoResultCell")
        
        // Cell size
        self.widthCell = (SCREEN_WIDTH - 30)
        let heightCell = ((self.widthCell * 1920) / 1080) - 100// 1920:1080 : resolution of iphone +
        self.searchCollectionViewLayout.itemSize = CGSize(width: (SCREEN_WIDTH - 40), height: heightCell)
        self.searchCollectionViewLayout.sectionInset = UIEdgeInsetsMake(-40, 20, 0, 0)
        self.searchCollectionViewLayout.minimumLineSpacing = 10
    }
    
    func startSearchCoachNotification() {
        self.isStopSearch = false
        self.loadmoreTime = 0

        self.searchCoachPage()
    }
    
    func searchCoachPage() {
        if (self.isStopSearch == false) {
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
                        self.isStopSearch = true
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
                            self.searchCollectionView.contentOffset = CGPoint()
                            
                            // Post notification for dismiss search animation screen
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AFTER_SEARCH_PAGE"), object: nil)
                        })
                    } else {
                        if ((result as! NSArray).count == 0) {
                            self.isStopSearch = true
                            
                            needReloadCollection = false
                        } else {
                            let rArray = result as! [NSDictionary]
                            self.arrayResult += rArray
                        }
                    }
                    
                    if (needReloadCollection == true) {
                        // Increase load more time and reload page
                        self.searchCollectionView.reloadData {
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
    
    func getTotalLead() {
        if (self.isStopGetLead == false) {
            UserRouter.getTotalLead(offset: self.leadOffset) { (result, error) in
                if (error == nil) {
                    let resultDetail = result as! NSDictionary
                    
                    // Get total
                    self.totalLead = resultDetail["total"] as! Int
                    
                    // Get lead list
                    let leadDetails = resultDetail["list"] as! [NSDictionary]
                    
                    if (leadDetails.count == 0) {
                        self.isStopGetLead = true
                    } else {
                        for leadDetail in leadDetails {
                            let user = UserModel()
                            user.id = leadDetail[kUserId] as! Int
                            
                            if (user.existInList(userList: self.leadList) == false) {
                                user.delegate = self
                                user.synsData()
                                
                                self.leadList.append(user)
                            }
                        }
                    }
                    
                    self.updateLayout()
                    self.leadOffset = self.leadOffset + 20
                } else {
                    self.isStopGetLead = true
                    
                    print("Request failed with error: \(String(describing: error))")
                }
                }.fetchdata()
        }
    }
    
    func getFollowCoach() {
        if (self.isStopGetFollowCoach == false) {
            UserRouter.getFollowCoach(offset: self.followCoachOffset) { (result, error) in
                if (error == nil) {
                    let resultDetail = result as! NSDictionary
                    
                    // Get total
                    self.totalFollowCoach = resultDetail["total"] as! Int
                    
                    // Get lead list
                    let coachDetails = resultDetail["list"] as! [NSDictionary]
                    if (coachDetails.count == 0) {
                        self.isStopGetFollowCoach = true
                    } else {
                        for coachDetail in coachDetails {
                            let user = UserModel()
                            user.id = coachDetail[kCoachId] as! Int
                            
                            if (user.existInList(userList: self.followCoachList) == false) {
                                user.delegate = self
                                user.synsData()
                                
                                self.followCoachList.append(user)
                            }
                        }
                    }
                    
                    self.firstCollectionView.reloadData()
                    
                    self.updateLayout()
                    self.followCoachOffset = self.followCoachOffset + 20
                } else {
                    self.isStopGetFollowCoach = true
                    
                    print("Request failed with error: \(String(describing: error))")
                }
                }.fetchdata()
        }
    }
    
    func getCoachTrackInfo() {
        UserRouter.getTrackInfo { (result, error) in
            if (error == nil) {
                let resultDetail = result as! NSDictionary
                
                self.numberNewMessage = resultDetail["leads"] as! Int
                self.numberProfileView = resultDetail["profileView"] as! Int
                self.numberSocialClick = resultDetail["socialClick"] as! Int
                
                self.updateLayout()
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func getPurchaseProduct() {
        if (self.isStopGetPurchaseProduct == false) {
            ProductRouter.getPurchaseProduct(offset: self.purchaseProductOffset) { (result, error) in
                if (error == nil) {
                    let resultDetail = result as! NSDictionary
                    
                    // Get total
                    self.totalPurchaseProduct = resultDetail["total"] as! Int
                    
                    // Get list
                    let productDetails = resultDetail["list"] as! [NSDictionary]
                    for productDetail in productDetails {
                        let productInfo = productDetail["product"] as! NSDictionary
                        let product = ProductModel()
                        product.parseData(data: productInfo)
                        
                        if (product.existInList(productList: self.purchaseProductList) == false) {
                            product.isBought = true
                            product.delegate = self
                            
                            self.purchaseProductList.append(product)
                        }
                    }
                    
                    self.secondCollectionView.reloadData()
                    
                    self.updateLayout()
                    self.purchaseProductOffset = self.purchaseProductOffset + 20
                } else {
                    print("Request failed with error: \(String(describing: error))")
                    
                    self.isStopGetPurchaseProduct = true
                }
                
                self.refreshControl.endRefreshing()
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
        } else if (segue.identifier == "goBookAndBuy") {
            let destination = segue.destination as! UINavigationController
            let bookBuyVC = destination.topViewController as! BookAndBuyViewController
            
            let product: ProductModel = sender as! ProductModel
            bookBuyVC.productBought = product
        } else if (segue.identifier == kSendMessageConnection) {
            let destination = segue.destination as! ChatMessageViewController
            
            // TODO: Need refactor
            var message = ""
            if (sender as? NSArray != nil) {
                let coachDetail = (sender as! NSArray)[0] as! NSDictionary
                message = (sender as! NSArray)[1] as! String
                
                let firstName = coachDetail[kFirstname] as! String
                destination.coachName = (firstName + " ").uppercased()
                destination.typeCoach = true
                destination.coachId = String(format:"%0.f", (coachDetail[kId]! as AnyObject).doubleValue)
                destination.userIdTarget =  String(format:"%0.f", (coachDetail[kId]! as AnyObject).doubleValue)
                destination.preMessage = message
            } else {
                let userTargetID = sender as! String
                
                destination.userIdTarget = userTargetID
            }
            
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
    
    func updateLayout() {
        // Update first view
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            self.firstTitleLabel.text = "LEAD (\(self.totalLead))"
        } else {
            self.firstTitleLabel.text = "COACH (\(self.totalFollowCoach))"
        }
        
        if (self.totalLead > 0 || self.totalFollowCoach > 0) {
            if (self.firstViewHeightConstraint.constant == 0) {
                self.firstCollectionView.reloadData()
            }
            
            self.firstViewHeightConstraint.constant = 145
        } else {
            self.firstViewHeightConstraint.constant = 0
        }
        
        // Update track view
        self.totalNewMessageLabel.text = "\(self.numberNewMessage)"
        self.totalProfileViewLabel.text = "\(self.numberProfileView)"
        self.totalSocialClickLabel.text = "\(self.numberSocialClick)"
        
        if (self.numberNewMessage > 0 || self.numberProfileView > 0 || self.numberSocialClick > 0) {
            self.trackViewHeightContraint.constant = 100
        } else {
            self.trackViewHeightContraint.constant = 0
        }
        
        // Second view: product view
        self.secondTitleLabel.text = "PURCHASES (\(self.totalPurchaseProduct))"
        if (self.totalPurchaseProduct > 0) {
            if (self.secondViewHeightConstraint.constant == 0) {
                self.secondCollectionView.reloadData()
            }
            
            self.secondViewHeightConstraint.constant = 145
        } else {
            self.secondViewHeightConstraint.constant = 0
        }
        
        // Animation
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func btnClientClick() {
        self.performSegue(withIdentifier: "gotoClient", sender: nil)
    }
}

// MARK: - UserModelDelegate
extension FindViewController: UserModelDelegate {
    func userModelSynsCompleted(user: UserModel) {
        let followCoachIndex = self.followCoachList.index(of: user)
        if (followCoachIndex != nil) {
            let indexPath = IndexPath(item: followCoachIndex!, section: 0)
            self.firstCollectionView.reloadItems(at: [indexPath])
        }
        
        let leadIndex = self.leadList.index(of: user)
        if (leadIndex != nil) {
            let indexPath = IndexPath(item: leadIndex!, section: 0)
            self.firstCollectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - ProductDelegate
extension FindViewController: ProductDelegate {
    func productSynsCompleted(product: ProductModel) {
        self.secondCollectionView.reloadData()
    }
}

// MARK: - CardViewCellDelegate
extension FindViewController: CardViewCellDelegate {
    func cardViewCellTagClicked(cell: CardViewCell) {
        let indexPath = self.searchCollectionView.indexPath(for: cell)
        let cellIndex = indexPath!.row
        let userID = self.arrayResult[cellIndex][kUserId] as! Int
        let userIDString = String(format: "%ld", userID)
        
        PMHelper.showCoachOrUserView(userID: userIDString)
    }
    
    func cardViewCellMoreInfoClicked(cell: CardViewCell) {
        let indexPath = self.searchCollectionView.indexPath(for: cell)
        let cellIndex = indexPath!.row
        let userID = self.arrayResult[cellIndex][kUserId] as! Int
        let userIDString = String(format: "%ld", userID)
        
        PMHelper.showCoachOrUserView(userID: userIDString)
    }
    
    func cardViewSwipeLeft() {
        var offsetX = self.searchCollectionView.contentOffset.x + self.widthCell
        let remainSpace = self.searchCollectionView.contentSize.width - self.widthCell
        if (offsetX > remainSpace) {
            offsetX = remainSpace
        }
        
        let newContentOffset = CGPoint(x: offsetX, y: 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.searchCollectionView.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(scrollView: self.searchCollectionView)
        }
    }
    
    func cardViewSwipeRight() {
        var offsetX = self.searchCollectionView.contentOffset.x - self.widthCell
        offsetX = offsetX < 0 ? 0 : offsetX
        
        let newContentOffset = CGPoint(x: offsetX, y: 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.searchCollectionView.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(scrollView: self.searchCollectionView)
        }
    }
    
    func cardViewRefineButtonClicked() {
        self.refind()
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FindViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.firstCollectionView) {
            if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
                return self.leadList.count
            } else {
                return self.followCoachList.count
            }
        } else if (collectionView == self.secondCollectionView) {
            return self.purchaseProductList.count
        } else if collectionView == self.searchCollectionView {
            return self.arrayResult.count + 1
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.firstCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeadCollectionViewCell", for: indexPath) as! LeadCollectionViewCell
            
            var user: UserModel
            if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
                if (indexPath.row == self.leadList.count - 2) {
                    self.getTotalLead()
                }
                
                user = self.leadList[indexPath.row]
            } else {
                if (indexPath.row == self.followCoachList.count - 2) {
                    self.getFollowCoach()
                }
                
                user = self.followCoachList[indexPath.row]
            }
            
            cell.setupData(userInfo: user)
            cell.setupLayout(isShowAddButton: false)
            
            return cell
        } else if (collectionView == self.secondCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductPurchasedCell", for: indexPath) as! ProductPurchasedCell
            
            let product = self.purchaseProductList[indexPath.row]
            cell.setupData(product: product)
            
            return cell
        } else if (collectionView == self.searchCollectionView) {
            if indexPath.row == self.arrayResult.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoResultCell", for: indexPath) as! NoResultCell
                cell.delegate = self
                
                if (self.arrayResult.count == 0) {
                    cell.setupData(isNoResult: true)
                } else {
                    cell.setupData(isNoResult: false)
                }
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardViewCell", for: indexPath) as! CardViewCell
                cell.delegate = self
                
                let cellIndex = indexPath.row
                if (cellIndex == self.arrayResult.count - 1) {
                    self.searchCoachPage()
                }
                
                let coachTotalDetail = arrayResult[cellIndex]
                
                let coachDetail = coachTotalDetail[kUser] as! NSDictionary
                
                if (coachDetail[kId] is NSNull == false) {
                    let coachID = String(format:"%0.f", (coachDetail[kId]! as AnyObject).doubleValue)
                    
                    if (lastTrackingCoachID != coachID) {
                        TrackingPMAPI.sharedInstance.trackingProfileCard(coachId: coachID)
                    }
                    
                    lastTrackingCoachID = coachID
                }
                
                cell.setupData(coachTotalDetail: coachTotalDetail)
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.firstCollectionView) {
            var leadUser: UserModel
            if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
                leadUser = self.leadList[indexPath.row]
            } else {
                leadUser = self.followCoachList[indexPath.row]
            }
            
            self.showLeadOption(leadUser: leadUser)
        } else if (collectionView == self.secondCollectionView) {
            // Show product detail
            let product = self.purchaseProductList[indexPath.row]
            
            self.performSegue(withIdentifier: "goBookAndBuy", sender: product)
        } else if (collectionView == self.searchCollectionView) {
            if indexPath.row < self.arrayResult.count {
                let cellIndex = indexPath.row
                let userID = self.arrayResult[cellIndex][kUserId] as! Int
                let userIDString = String(format: "%ld", userID)
                
                PMHelper.showCoachOrUserView(userID: userIDString)
            }
        }
    }
    
    func endPagingCarousel(scrollView: UIScrollView) {
        if scrollView == self.searchCollectionView {
            // custom pageing
            var point = scrollView.contentOffset
            point.x = self.widthCell * CGFloat(Int(round((point.x / self.widthCell))))
            
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
    func showLeadOption(leadUser: UserModel) {
        let userID = String(format:"%ld", leadUser.id)
        let userMail = leadUser.email
        let phoneNumber = leadUser.mobile?.replacingOccurrences(of: " ", with: "")
        
        // Email action
        let emailClientAction = { (action:UIAlertAction!) -> Void in
            UserRouter.getCurrentUserInfo(completed: { (result, error) in
                if (error == nil) {
                    let currentInfo = result as! NSDictionary
                    let coachFirstName = currentInfo[kFirstname] as! String
                    let currentUserID = PMHelper.getCurrentID()
                    let userFirstName = leadUser.firstname!
                    
                    if MFMailComposeViewController.canSendMail() {
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = self
                        
                        mail.setToRecipients([userMail!])
                        mail.setSubject("Come join me on Pummel Fitness")
                        mail.setMessageBody("Hey \(userFirstName),<br /><br />Come join me on the Pummel Fitness app, where we can book appointments, log workouts, save transformation photos and chat for free.<br /><br />Download the app at http://get.pummel.fit<br /><br />Thanks,<br /><br />Coach \(coachFirstName)<br />Link to my profile: pummel://coachid=\(currentUserID)", isHTML: true)
                        self.present(mail, animated: true, completion: nil)
                    } else {
                        PMHelper.showDoAgainAlert()
                    }
                    
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
        // Call action
        let callClientAction = { (action:UIAlertAction!) -> Void in
            let urlString = "tel:///" + phoneNumber!
            
            let tellURL = NSURL(string: urlString)
            if (UIApplication.shared.canOpenURL(tellURL! as URL)) {
                UIApplication.shared.openURL(tellURL! as URL)
            }
        }
        
        // Send message action
        let sendMessageClientAction = { (action:UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: kSendMessageConnection, sender: userID)
        }
        
        let viewProfileAction = { (action:UIAlertAction!) -> Void in
            PMHelper.showCoachOrUserView(userID: userID)
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: kViewProfile, style: .destructive, handler: viewProfileAction))
        
        alertController.addAction(UIAlertAction(title: kSendMessage, style: .destructive, handler: sendMessageClientAction))
        
        // Check exist phone number
        if (phoneNumber != nil && phoneNumber!.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kCallClient, style: .destructive, handler: callClientAction))
        }
        
        // Check exist email
        if (userMail != nil && userMail?.isEmpty == false) {
            alertController.addAction(UIAlertAction(title: kEmailClient, style: .destructive, handler: emailClientAction))
        }
        
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
}

extension FindViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
