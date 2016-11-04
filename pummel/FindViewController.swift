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

class FindViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    var showLetUsHelp: Bool!
    var swipeableView: ZLSwipeableView!
    var loadCardsFromXib = true
    var resultIndex = 0
    var resultPage : Int = 0
    var sizingCell: TagCell?
    var tags = [Tag]()
    var coachTotalDetail: NSDictionary!
    var coachDetail: NSDictionary!
    var arrayResult : [NSDictionary] = []
    var arrayTags : NSArray!
    var stopSearch: Bool = false
    var firstLoad: Bool = false
    var refined : Bool = false
    @IBOutlet weak var noResultLB: UILabel!
    @IBOutlet weak var noResultContentLB: UILabel!
    @IBOutlet weak var refineSearchBT: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLetUsHelp = true
        self.navigationController!.navigationBar.translucent = false
        swipeableView = ZLSwipeableView()
        view.addSubview(swipeableView)
        swipeableView.didStart = {view, location in
        }
        swipeableView.swiping = {view, location, translation in
        }
        swipeableView.didEnd = {view, location in
        }
        swipeableView.didSwipe = {view, direction, vector in
        }
        swipeableView.didCancel = {view in
        }
        swipeableView.didTap = {view, location in
            self.performSegueWithIdentifier(kGoProfile, sender: self)
        }
        swipeableView.didDisappear = { view in
            self.searchNextPage()
        }
        constrain(swipeableView, view) { view1, view2 in
            view1.left == view2.left + 20
            view1.right == view2.right - 20
            view1.top == view2.top + 20
            view1.bottom == view2.bottom - 80
        }
        
        noResultLB.font = .pmmPlayFairReg18()
        noResultContentLB.font = .pmmMonLight13()
        refineSearchBT.titleLabel!.font = .pmmMonReg12()
        swipeableView.hidden = (self.arrayResult.count >= 1) ? false : true
    }
    
    func searchNextPage() {
        if (self.stopSearch == false) {
            self.resultPage+=6
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
            }
            prefix.appendContentsOf("&limit=1")
            prefix.appendContentsOf("&offset=".stringByAppendingString(String(resultPage)))
            Alamofire.request(.GET, prefix)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        if ((response.result.value as! NSArray).count == 0) {
                            self.stopSearch = true
                        } else {
                            let rArray = response.result.value as! [NSDictionary]
                            self.arrayResult += rArray
                        }
                    }
            }
        } else {
            print("no more resul")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.arrayResult.count > 0) {
            self.swipeableView.hidden = false
            swipeableView.nextView = {
                return self.nextCardView()
            }
        }
    }
    
    // MARK: ()
    func nextCardView() -> UIView? {
        resultIndex += 1
        if resultIndex >= arrayResult.count  {
            resultIndex = 0
        }
        
        coachTotalDetail = arrayResult[resultIndex]
        coachDetail = coachTotalDetail[kUser] as! NSDictionary
        let coachListTags = coachDetail[kTags] as! NSArray
        
        let cardView = CardView(frame: swipeableView.bounds)
        cardView.backgroundColor = UIColor.whiteColor()
        
        if loadCardsFromXib {
            let contentView = NSBundle.mainBundle().loadNibNamed("CardContentView", owner: nil, options: nil)!.first as! CardView
            contentView.avatarIMV.image = nil
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = cardView.backgroundColor
            contentView.connectV.layer.cornerRadius = 50
            contentView.connectV.clipsToBounds = true
            contentView.nameLB.font = .pmmPlayFairReg24()
            contentView.nameLB.text = ((coachDetail[kFirstname] as! String) .stringByAppendingString(" ")) .stringByAppendingString(coachDetail[kLastName] as! String)
            contentView.addressLB.font = .pmmPlayFairReg11()
            if !(coachTotalDetail[kServiceArea] is NSNull) {
                contentView.addressLB.text = coachTotalDetail[kServiceArea] as? String
            }
            let postfix = widthEqual.stringByAppendingString(String(self.view.frame.size.width)).stringByAppendingString(heighEqual).stringByAppendingString(String(self.view.frame.size.width))
            if !(coachDetail[kImageUrl] is NSNull) {
                let imageLink = coachDetail[kImageUrl] as! String
                var prefix = kPMAPI
                prefix.appendContentsOf(imageLink)
                prefix.appendContentsOf(postfix)
                if (NSCache.sharedInstance.objectForKey(prefix) != nil) {
                    let imageRes = NSCache.sharedInstance.objectForKey(prefix) as! UIImage
                    contentView.avatarIMV.image = imageRes
                } else {
                    Alamofire.request(.GET, prefix)
                        .responseImage { response in
                            if (response.response?.statusCode == 200) {
                                let imageRes = response.result.value! as UIImage
                                contentView.avatarIMV.image = imageRes
                                NSCache.sharedInstance.setObject(imageRes, forKey: prefix)
                            }
                    }
                }
            }
            
            //TagList
            contentView.collectionView.delegate = self
            contentView.collectionView.dataSource = self
            let cellNib = UINib(nibName: kTagCell, bundle: nil)
            contentView.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: kTagCell)
            contentView.collectionView.backgroundColor = UIColor.clearColor()
            self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
           // contentView.flowLayout.smaller = true
            
            // Business ImageView
            contentView.connectV.hidden = true
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
                                    contentView.connectV.hidden = false
                                    let imageRes = NSCache.sharedInstance.objectForKey(prefixLogo) as! UIImage
                                    contentView.businessIMV.image = imageRes
                                } else {
                                    Alamofire.request(.GET, prefixLogo)
                                        .responseImage { response in
                                            if (response.response?.statusCode == 200) {
                                                contentView.connectV.hidden = false
                                                let imageRes = response.result.value! as UIImage
                                                contentView.businessIMV.image = imageRes
                                                NSCache.sharedInstance.setObject(imageRes, forKey: prefixLogo)
                                            }
                                    }
                                }
                            }
                        }
                }
            }
            
            
            cardView.addSubview(contentView)
            
            constrain(contentView, cardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top
                view1.width == cardView.bounds.width
                view1.height == cardView.bounds.height
            }
            
            
            self.tags.removeAll()
            for i in 0 ..< coachListTags.count {
                let tagContent = coachListTags[i] as! NSDictionary
                let tag = Tag()
                tag.name = tagContent[kTitle] as? String
                self.tags.append(tag)
            }
            contentView.collectionView.reloadData()
        }
        cardView.tag = resultIndex
        return cardView
    }
    
    func colorForName(name: String) -> UIColor {
        let sanitizedName = name.stringByReplacingOccurrencesOfString(" ", withString: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.performSelector(Selector(selector)).takeUnretainedValue() as! UIColor
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.title = "RESULTS"
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        let selectedImage = UIImage(named: "search")
        self.tabBarItem.image = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        if(showLetUsHelp == true) {
            performSegueWithIdentifier("letUsHelp", sender: nil)
        }
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"REFINE", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FindViewController.refind))
        self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName: UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        self.stopSearch = false
        self.resultPage = 0
        if (swipeableView != nil && refined == true ) {
            swipeableView.removeFromSuperview()
            swipeableView = ZLSwipeableView()
            view.addSubview(swipeableView)
            
            swipeableView.didStart = {view, location in
            }
            swipeableView.swiping = {view, location, translation in
            }
            swipeableView.didEnd = {view, location in
            }
            swipeableView.didSwipe = {view, direction, vector in
            }
            swipeableView.didCancel = {view in
            }
            swipeableView.didTap = {view, location in
                self.performSegueWithIdentifier(kGoProfile, sender: view)
            }
            swipeableView.didDisappear = { view in
                self.searchNextPage()
            }
            constrain(swipeableView, view) { view1, view2 in
                view1.left == view2.left + 20
                view1.right == view2.right - 20
                view1.top == view2.top + 20
                view1.bottom == view2.bottom - 80
            }
            refined = false
            swipeableView.hidden = (self.arrayResult.count >= 1) ? false : true
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "letUsHelp")
        {
        } else if (segue.identifier == kGoConnect)
        {
            let destination = segue.destinationViewController as! ConnectViewController
            let totalDetail = arrayResult[sender.tag]
            destination.coachDetail = totalDetail[kUser] as! NSDictionary
        } else if (segue.identifier == kSendMessageConnection) {
            let destination = segue.destinationViewController as! ChatMessageViewController
            destination.coachName = ((coachDetail[kFirstname] as! String) .stringByAppendingString(" ")).uppercaseString
            destination.typeCoach = true
            destination.coachId = String(format:"%0.f", coachDetail[kId]!.doubleValue)
            destination.userIdTarget =  String(format:"%0.f", coachDetail[kId]!.doubleValue)
        } else if (segue.identifier == kGoProfile) {
            let destination = segue.destinationViewController as! CoachProfileViewController
            let totalDetail = arrayResult[sender.tag]
            destination.coachDetail = totalDetail[kUser] as! NSDictionary
            destination.coachTotalDetail = totalDetail
        }
    }

    @IBAction func refind() {
        self.resultIndex = 0
          performSegueWithIdentifier("letUsHelp", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}

extension UIImageView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}
