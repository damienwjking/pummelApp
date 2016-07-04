//
//  CoachProfileViewController.swift
//  pummel
//
//  Created by Bear Daddy on 7/1/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class CoachProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var smallIndicatorView: UIView!
    @IBOutlet weak var medIndicatorView: UIView!
    @IBOutlet weak var bigIndicatorView: UIView!
    @IBOutlet weak var bigBigIndicatorView: UIView!
    
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

   
    let TAGS = ["Running", "Nutrition", "Weight Training"]
    var sizingCell: TagCell?
    var tags = [Tag]()

    
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
        self.titleAboutLB.hidden = true
        self.avatarIMV.layer.cornerRadius = 125/2
        self.avatarIMV.clipsToBounds = true
        for name in TAGS {
            let tag = Tag()
            tag.name = name
            self.tags.append(tag)
        }
        
        self.interestCollectionView.delegate = self
        self.interestCollectionView.dataSource = self
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        self.interestCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "TagCell")
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        self.interestFlowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        self.interestCollectionView.backgroundColor = UIColor.clearColor()
        self.aboutCollectionView.backgroundColor = UIColor.clearColor()
        self.aboutCollectionView.delegate = self
        self.aboutCollectionView.dataSource = self
        self.statusBarDefault = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goBackToResult(sender:UIButton) {
        self.dismissViewControllerAnimated(true) { 
            print("goBackToResult")
        }
    }
    
    @IBAction func goConnection(sender:UIButton) {
        self.performSegueWithIdentifier("goConnect", sender: self)
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
        } else {
            self.interestHeightDT.constant = 50
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
            return 10
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
       cell.imageCell.image = UIImage(named: "kateupon.jpg")
    }

}
