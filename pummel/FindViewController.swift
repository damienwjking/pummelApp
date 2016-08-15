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
    var sizingCell: TagCell?
    var tags = [Tag]()
    var coachDetail: NSDictionary!
    var arrayResult : NSArray = []
    var arrayTags : NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLetUsHelp = true
        self.navigationController!.navigationBar.translucent = false;
        swipeableView = ZLSwipeableView()
        view.addSubview(swipeableView)
        swipeableView.didStart = {view, location in
            print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            print("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
            print("Did swipe view in direction: \(direction), vector: \(vector)")
        }
        swipeableView.didCancel = {view in
            print("Did cancel swiping view")
        }
        swipeableView.didTap = {view, location in
            self.performSegueWithIdentifier("goProfile", sender: self)
        }
        swipeableView.didDisappear = { view in
            print("Did disappear swiping view")
        }
        constrain(swipeableView, view) { view1, view2 in
            view1.left == view2.left + 20
            view1.right == view2.right - 20
            view1.top == view2.top + 20
            view1.bottom == view2.bottom - 80
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.arrayResult.count > 0) {
            swipeableView.nextView = {
                return self.nextCardView()
            }
        }
    }
    
    // MARK: ()
    func nextCardView() -> UIView? {
        if resultIndex >= arrayResult.count {
            resultIndex = 0
        }
        
        let resultItemDetail = arrayResult[resultIndex]
        coachDetail = resultItemDetail["user"] as! NSDictionary
        let coachListTags = coachDetail["tags"] as! NSArray
        self.tags.removeAll()
        for i in 0 ..< coachListTags.count {
            let tagContent = coachListTags[i] as! NSDictionary
            let tag = Tag()
            tag.name = tagContent["title"] as? String
            self.tags.append(tag)
        }
        
        let imageLink = coachDetail["imageUrl"] as! String
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
        prefix.appendContentsOf(imageLink)
        
        resultIndex += 1
        let cardView = CardView(frame: swipeableView.bounds)
        cardView.backgroundColor = UIColor.whiteColor()
        
        if loadCardsFromXib {
            let contentView = NSBundle.mainBundle().loadNibNamed("CardContentView", owner: self, options: nil).first! as! CardView
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = cardView.backgroundColor
            contentView.connectV.layer.cornerRadius = 55/2
            contentView.connectV.clipsToBounds = true
            contentView.connectV.backgroundColor = UIColor(red: 255.0 / 255.0, green: 91.0 / 255.0, blue: 16.0 / 255.0, alpha: 1.0)
            contentView.nameLB.font = UIFont(name: "PlayfairDisplay-Regular", size: 24)
            contentView.nameLB.text = ((coachDetail["firstname"] as! String) .stringByAppendingString(" ")) .stringByAppendingString(coachDetail["lastname"] as! String)
            contentView.address.font = UIFont(name: "PlayfairDisplay-Regular", size: 11)
            contentView.address.text = "Waiting for address"
            let postfix = "?width=".stringByAppendingString(contentView.frame.size.width.description).stringByAppendingString("&height=").stringByAppendingString(contentView.frame.size.width.description)
            print(postfix)
            prefix.appendContentsOf(postfix)
            print(link)
            Alamofire.request(.GET, prefix)
                .responseImage { response in
                    let imageRes = response.result.value! as UIImage
                    contentView.avatarIMV.image = imageRes
            }
            //TagList
            contentView.collectionView.delegate = self
            contentView.collectionView.dataSource = self
            let cellNib = UINib(nibName: "TagCell", bundle: nil)
            contentView.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "TagCell")
            contentView.collectionView.backgroundColor = UIColor.clearColor()
            self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
            
            contentView.connectBT.addTarget(self, action: #selector(FindViewController.goConnect(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            // Border
          //  contentView.avatarIMV.layer.cornerRadius = 5
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: contentView.avatarIMV.bounds, byRoundingCorners: UIRectCorner.TopRight, cornerRadii: CGSizeMake(0, 0)).CGPath
            contentView.avatarIMV.layer.mask = maskLayer
            contentView.avatarIMV.clipsToBounds = true
            contentView.flowLayout.smaller = true
            
    
            cardView.addSubview(contentView)
            // This is important:
            // https://github.com/zhxnlai/ZLSwipeableView/issues/9
            /*// Alternative:
             let metrics = ["width":cardView.bounds.width, "height": cardView.bounds.height]
             let views = ["contentView": contentView, "cardView": cardView]
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(width)]", options: .AlignAllLeft, metrics: metrics, views: views))
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView(height)]", options: .AlignAllLeft, metrics: metrics, views: views))
             */
            
            constrain(contentView, cardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top
                view1.width == cardView.bounds.width
                view1.height == cardView.bounds.height
            }
        }
        return cardView
    }
    
    func colorForName(name: String) -> UIColor {
        let sanitizedName = name.stringByReplacingOccurrencesOfString(" ", withString: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.performSelector(Selector(selector)).takeUnretainedValue() as! UIColor
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.title = "FIND"
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        let selectedImage = UIImage(named: "search")
        self.tabBarItem.image = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        if(showLetUsHelp == true) {
            performSegueWithIdentifier("letUsHelp", sender: nil)
        }
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"REFINE", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FindViewController.refind))
         self.tabBarController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "letUsHelp")
        {
        } else if (segue.identifier == "goConnect")
        {
            let destimation = segue.destinationViewController as! ConnectViewController
            destimation.coachDetail = self.coachDetail
        } else if (segue.identifier == "sendMessageConnection") {
            let destimation = segue.destinationViewController as! ChatMessageViewController
            destimation.coachName = ((coachDetail["firstname"] as! String) .stringByAppendingString(" ")).uppercaseString
            destimation.typeCoach = true
            destimation.coachId = String(format:"%0.f", coachDetail["id"]!.doubleValue)
            destimation.userIdTarget =  String(format:"%0.f", coachDetail["id"]!.doubleValue)
        } else if (segue.identifier == "goProfile") {
            let destimation = segue.destinationViewController as! CoachProfileViewController
            destimation.coachDetail = self.coachDetail
        }
    }

    func refind() {
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCell", forIndexPath: indexPath) as! TagCell
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
        //cell.tagName.textColor = tag.selected ? UIColor.whiteColor() : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        // cell.backgroundColor = tag.selected ? UIColor(red: 0, green: 1, blue: 0, alpha: 1) : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
    }
    
    func goConnect(sender:UIButton!) {
        self.performSegueWithIdentifier("goConnect", sender: self)
    }
    
}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}