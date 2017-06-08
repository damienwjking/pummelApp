//
//  UserViewController.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class UserProfileViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    //@IBOutlet weak var titleUserLB: UILabel!
    @IBOutlet weak var smallIndicatorView: UIView!
    @IBOutlet weak var medIndicatorView: UIView!
    @IBOutlet weak var bigIndicatorView: UIView!
    @IBOutlet weak var bigBigIndicatorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarIMV: UIImageView!
    @IBOutlet weak var aboutLB: UILabel!
    @IBOutlet weak var postLB: UILabel!
    @IBOutlet weak var aboutCollectionView: UICollectionView!
    @IBOutlet weak var aboutFlowLayout: FlowLayout!
    @IBOutlet weak var postV: UIView!
    @IBOutlet weak var aboutV: UIView!
    @IBOutlet weak var aboutHeightDT: NSLayoutConstraint!
    @IBOutlet weak var aboutTV: UITextView!
    @IBOutlet weak var aboutTVHeightDT: NSLayoutConstraint!
    @IBOutlet var postHeightDT: NSLayoutConstraint!
    @IBOutlet weak var ratingLB: UILabel!
    @IBOutlet weak var ratingContentLB: UILabel!
    
    @IBOutlet weak var connectionLB: UILabel!
    @IBOutlet weak var connectionContentLB: UILabel!
    
    @IBOutlet weak var postNumberLB: UILabel!
    @IBOutlet weak var postNumberContentLB: UILabel!
    
    @IBOutlet weak var userNameLB: UILabel!
    
    var statusBarDefault: Bool!
    var userDetail: NSDictionary!
    var userId: String!
    var sizingCell: TagCell?
    var tags = [Tag]()
    
    var arrayPhotos: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
            
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
        
        self.aboutCollectionView.delegate = self
        self.aboutCollectionView.dataSource = self
        
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(userId)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.userDetail = response.result.value as! NSDictionary
                    self.updateUI()
                }
        }
        self.userNameLB.font = .pmmMonReg13()
        self.aboutLB.font = .pmmMonLight11()
        self.postLB.font = .pmmMonLight11()
        self.aboutTV.backgroundColor = UIColor.clearColor()
        self.aboutTV.font = .pmmMonLight13()
        self.aboutTV.scrollEnabled = false
        self.avatarIMV.layer.cornerRadius = 125/2
        self.avatarIMV.clipsToBounds = true
        self.setAvatar()
        self.getListPhoto()
        self.ratingLB.font = .pmmMonLight10()
        self.ratingContentLB.font = .pmmMonReg16()
        self.connectionLB.font = .pmmMonLight10()
        self.connectionLB.text = "SESSIONS"
        self.connectionContentLB.font = .pmmMonReg16()
        self.postNumberLB.font = .pmmMonLight10()
        self.postNumberContentLB.font = .pmmMonReg16()
        self.aboutTV.editable = false
    }
    
    func setting() {
        performSegueWithIdentifier("goSetting", sender: nil)
    }
    
    @IBAction func edit() {
        performSegueWithIdentifier("goEdit", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "goEdit")
        {
            let destinationVC = segue.destinationViewController as! EditProfileViewController
            destinationVC.userInfo = self.userDetail
        } else if segue.identifier == "goToFeedDetail" {
            let navc = segue.destinationViewController as! UINavigationController
            let destination = navc.topViewController as! FeedViewController
            destination.fromPhoto = true
            if let feed = sender as? NSDictionary {
                destination.feedDetail = feed
            }
        }
    }
    
    @IBAction func goBackToFeed(sender:UIButton) {
        self.dismissViewControllerAnimated(true) {
        }
    }
    
    func getListPhoto() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(userId)
        prefix.appendContentsOf(kPM_PATH_PHOTO_PROFILE)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                self.arrayPhotos = JSON as! NSArray
                self.aboutCollectionView.reloadData()
                self.postHeightDT.constant = self.aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
                self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: self.aboutCollectionView.frame.origin.y + self.postHeightDT.constant)
                self.scrollView.scrollEnabled = true
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func setAvatar() {
        ImageRouter.getUserAvatar(userID: self.userId, sizeString: widthHeight160) { (result, error) in
            if (error == nil) {
                let imageRes = result as! UIImage
                self.avatarIMV.image = imageRes
            } else {
                print("Request failed with error: \(error)")
            }
        }.fetchdata()
    }
    
    func updateUI() {
        self.userNameLB.text = (self.userDetail[kFirstname] as! String).uppercaseString
        
        self.ratingContentLB.text = String(format:"%0.f", (self.userDetail[kConnectionCount]!.doubleValue * 120) + (self.userDetail[kPostCount]!.doubleValue * 75))
        
        self.connectionContentLB.text = String(format:"%0.f", self.userDetail[kConnectionCount]!.doubleValue)
        
        self.postNumberContentLB.text = String(format:"%0.f", self.userDetail[kPostCount]!.doubleValue)
        
        self.aboutTV.text = !(self.userDetail[kBio] is NSNull) ? self.userDetail[kBio] as! String : letAddYourDetail
        
        let sizeAboutTV = self.aboutTV.sizeThatFits(self.aboutTV.frame.size)
        
        self.aboutTVHeightDT.constant = sizeAboutTV.height
        
        self.aboutHeightDT.constant = self.aboutTV.frame.origin.y + sizeAboutTV.height + 8
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        postHeightDT.constant = aboutCollectionView.collectionViewLayout.collectionViewContentSize().height
        self.scrollView.contentSize = CGSize.init(width: self.view.frame.width, height: aboutCollectionView.frame.origin.y + postHeightDT.constant)
        self.scrollView.scrollEnabled = true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kAboutCollectionViewCell, forIndexPath: indexPath) as! AboutCollectionViewCell
        self.configureAboutCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.aboutCollectionView.frame.size.width/2, self.aboutCollectionView.frame.size.width/2)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.view.makeToastActivity()
        var prefix = kPMAPI
        prefix.appendContentsOf(kPMAPI_POSTOFPHOTO)
        let photo = self.arrayPhotos[indexPath.row] as! NSDictionary
        print(photo.objectForKey(kId)!)
        Alamofire.request(.GET, prefix, parameters: ["photoId":photo["uploadId"]!])
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                if let arr = JSON as? NSArray {
                    if arr.count > 0 {
                        if let dic = arr.objectAtIndex(0) as? NSDictionary {
                            self.performSegueWithIdentifier("goToFeedDetail", sender: dic)
                            self.view.hideToastActivity()
                            return
                        }
                    }
                }
                
                let alertController = UIAlertController(title: pmmNotice, message: notfindPhoto, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
                self.view.hideToastActivity()
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
                self.view.hideToastActivity()
        }
    }
    
    func configureAboutCell(cell: AboutCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        var prefix = kPMAPI
        let photo = self.arrayPhotos[indexPath.row] as! NSDictionary
        let postfix = widthEqual.stringByAppendingString((self.view.frame.size.width).description).stringByAppendingString(heighEqual).stringByAppendingString((self.view.frame.size.width).description)
        var link = photo.objectForKey(kImageUrl) as! String
        link.appendContentsOf(postfix)
        prefix.appendContentsOf(link)
        Alamofire.request(.GET, prefix)
            .responseImage { response in
                let imageRes = response.result.value! as UIImage
                cell.imageCell.image = imageRes
        }
    }
}

