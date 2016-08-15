//
//  CoachProfileViewController.swift
//  pummel
//
//  Created by Bear Daddy on 7/1/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class CoachProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var smallIndicatorView: UIView!
    @IBOutlet weak var medIndicatorView: UIView!
    @IBOutlet weak var bigIndicatorView: UIView!
    @IBOutlet weak var bigBigIndicatorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var connectV : UIView!
    @IBOutlet weak var connectBT : UIView!
    @IBOutlet var addressLB: UILabel!
    @IBOutlet weak var interestLB: UILabel!
    @IBOutlet weak var aboutLB: UILabel!
    @IBOutlet weak var aboutNameLB: UILabel!
    @IBOutlet weak var interestCollectionView: UICollectionView!
    @IBOutlet weak var interestFlowLayout: FlowLayout!
    @IBOutlet weak var aboutCollectionView: UICollectionView!
    @IBOutlet weak var aboutFlowLayout: FlowLayout!
    @IBOutlet var aboutHeightDT: NSLayoutConstraint!
    @IBOutlet var interestHeightDT: NSLayoutConstraint!
    @IBOutlet var scrollHeightConstraint: NSLayoutConstraint!
    @IBOutlet var backBTDT: NSLayoutConstraint!
    @IBOutlet var aboutShowBTDT: NSLayoutConstraint!
    @IBOutlet weak var aboutV: UIView!
    @IBOutlet weak var imageV: UIView!
    @IBOutlet weak var detailV: UIView!
    @IBOutlet weak var interestV: UIView!
    @IBOutlet weak var aboutShowBT: UIButton!
    @IBOutlet weak var titleAboutLB: UILabel!
    @IBOutlet weak var backBT: UIButton!
    var oldPositionAboutV: CGFloat!
    var statusBarDefault: Bool!
    var coachDetail: NSDictionary!
   
    var sizingCell: TagCell?
    var tags = [Tag]()

    var arrayPhotos: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.bigBigIndicatorView.alpha = 0.005
        self.bigIndicatorView.alpha = 0.01
        self.medIndicatorView.alpha = 0.025
        self.smallIndicatorView.alpha = 0.05
        
        self.bigBigIndicatorView.layer.cornerRadius = 374/2
        self.bigIndicatorView.layer.cornerRadius = 312/2
        self.medIndicatorView.layer.cornerRadius = 240/2
        self.smallIndicatorView.layer.cornerRadius = 180/2
        
        self.bigBigIndicatorView.clipsToBounds = true
        self.bigIndicatorView.clipsToBounds = true
        self.medIndicatorView.clipsToBounds = true
        self.smallIndicatorView.clipsToBounds = true

        self.connectV.layer.cornerRadius = 55/2
        self.connectV.clipsToBounds = true
        self.connectV.backgroundColor = UIColor(red: 255.0 / 255.0, green: 91.0 / 255.0, blue: 16.0 / 255.0, alpha: 1.0)
        self.addressLB.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.interestLB.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.aboutLB.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.aboutNameLB.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.titleAboutLB.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.titleAboutLB.text = (self.coachDetail["firstname"] as! String).uppercaseString
        self.avatarIMV.layer.cornerRadius = 125/2
        self.avatarIMV.clipsToBounds = true
        let imageLink = coachDetail["imageUrl"] as! String
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
        prefix.appendContentsOf(imageLink)
        let postfix = "?width=".stringByAppendingString(avatarIMV.frame.size.width.description).stringByAppendingString("&height=").stringByAppendingString(avatarIMV.frame.size.width.description)
        prefix.appendContentsOf(postfix)
        Alamofire.request(.GET, prefix)
            .responseImage { response in
                let imageRes = response.result.value! as UIImage
                self.avatarIMV.image = imageRes
        }

        let coachListTags = coachDetail["tags"] as! NSArray
        self.tags.removeAll()
        for i in 0 ..< coachListTags.count {
            let tagContent = coachListTags[i] as! NSDictionary
            let tag = Tag()
            tag.name = tagContent["title"] as? String
            self.tags.append(tag)
        }
        
        self.interestCollectionView.delegate = self
        self.interestCollectionView.dataSource = self
        let flow = interestCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        self.interestCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "TagCell")
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        self.interestFlowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        self.interestCollectionView.backgroundColor = UIColor.clearColor()
        self.aboutCollectionView.backgroundColor = UIColor.clearColor()
        self.statusBarDefault = false
        
        getListImage()
    }
    
    func getListImage() {
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        prefix.appendContentsOf(String(format:"%0.f", coachDetail["id"]!.doubleValue))
        prefix.appendContentsOf("/photos")
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                print(JSON)
                self.arrayPhotos = JSON as! NSArray
                self.aboutCollectionView.delegate = self
                self.aboutCollectionView.dataSource = self
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        aboutHeightDT.constant = aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
        self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + aboutHeightDT.constant)
        self.scrollView.scrollEnabled = true
    }
    
    
    @IBAction func goBackToResult(sender:UIButton) {
        self.dismissViewControllerAnimated(true) { 
            print("goBackToResult")
        }
    }
    
    @IBAction func goConnection(sender:UIButton) {
        self.performSegueWithIdentifier("goConnect", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "goConnect")
        {
            let destimation = segue.destinationViewController as! ConnectViewController
            destimation.coachDetail = coachDetail
            destimation.isFromProfile = true
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if (statusBarDefault == true) {
            return UIStatusBarStyle.Default
        } else {
            return UIStatusBarStyle.LightContent
        }
    }
    
    @IBAction func expandInterest(sender:UIButton) {
        if (self.interestHeightDT.constant == 50) {
            self.interestHeightDT.constant = 128
            self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + aboutHeightDT.constant)

        } else {
            self.interestHeightDT.constant = 50
            self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + aboutHeightDT.constant)

        }
    }
    
    @IBAction func expandAboutDetail(sender: UIButton) {
        if (self.aboutHeightDT.constant == 50) {
            self.aboutHeightDT.constant = 70
        } else {
            self.aboutHeightDT.constant = 50
        }
        if (self.view.frame.origin.y == 0.0) {
            self.oldPositionAboutV = self.view.frame.size.height - (self.aboutV.frame.size.height +
                self.aboutCollectionView.frame.size.height)
            var frameV : CGRect!
            frameV = self.view.frame
            frameV.origin.y = -self.aboutV.frame.origin.y
            frameV.size.height += self.oldPositionAboutV
            self.view.frame = frameV
            self.aboutNameLB.hidden = true
            self.aboutLB.hidden = true
            self.backBTDT.constant = 10
            self.aboutShowBTDT.constant = 20
            self.backBT.setImage(UIImage(named:"blackArrow"), forState: UIControlState.Normal)
            self.titleAboutLB.text = "SARAH"
            self.titleAboutLB.hidden = false
            self.statusBarDefault = true
            self.setNeedsStatusBarAppearanceUpdate()
            
        } else {
            self.statusBarDefault = false
            self.setNeedsStatusBarAppearanceUpdate()
            self.titleAboutLB.hidden = true
            self.aboutNameLB.hidden = false
            self.aboutLB.hidden = false
            var frameV : CGRect!
            frameV = self.view.frame
            frameV.origin.y = 0
            frameV.size.height -= self.oldPositionAboutV
            self.view.frame = frameV
            self.backBTDT.constant = 0
            self.aboutShowBTDT.constant = 0
            self.backBT.setImage(UIImage(named:"back"), forState: UIControlState.Normal)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.interestCollectionView) {
            return tags.count
        } else {
            return arrayPhotos.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (collectionView == self.interestCollectionView) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCell", forIndexPath: indexPath) as! TagCell
            self.configureCell(cell, forIndexPath: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AboutCollectionViewCell", forIndexPath: indexPath) as! AboutCollectionViewCell
            self.configureAboutCell(cell, forIndexPath: indexPath)
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
         if (collectionView == self.interestCollectionView) {
            self.configureCell(self.sizingCell!, forIndexPath: indexPath)
            return self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
         } else {
            return CGSizeMake(self.aboutCollectionView.frame.size.width/2, self.aboutCollectionView.frame.size.width/2)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView == self.interestCollectionView) {
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            tags[indexPath.row].selected = !tags[indexPath.row].selected
            collectionView.reloadData()
        }
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagName.textColor = UIColor.blackColor()
        cell.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    func configureAboutCell(cell: AboutCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
            var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
            let photo = self.arrayPhotos[indexPath.row] as! NSDictionary
            let postfix = "?width=".stringByAppendingString((self.view.frame.size.width/2).description).stringByAppendingString("&height=").stringByAppendingString((self.view.frame.size.width/2).description)
            var link = photo.objectForKey("imageUrl") as! String
            link.appendContentsOf(postfix)
            prefix.appendContentsOf(link)
            Alamofire.request(.GET, prefix)
                .responseImage { response in
                    let imageRes = response.result.value! as UIImage
                    cell.imageCell.image = imageRes
            }
    }
}
