//
//  LetUsHelpViewConntroller.swift
//  pummel
//
//  Created by Bear Daddy on 6/27/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class LetUsHelpViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var letUsHelpTF : UILabel!
    @IBOutlet var letUsHelpDetailTF : UILabel!
    @IBOutlet var genderTF : UILabel!
    @IBOutlet var genderResultTF: UILabel!
    @IBOutlet var locationTF : UILabel!
    @IBOutlet var locationResultTF: UILabel!
    @IBOutlet var helpMeReachTheCoachBT : UIButton!
    @IBOutlet var toHelpUsWithTF : UILabel!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet weak var tagHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    var sizingCell: TagCell?
    
    var tags = [Tag]()
    var arrayTags : NSArray = []
    var tagIdsArray : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.letUsHelpTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 33)
        self.letUsHelpDetailTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 15)
        self.genderTF.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.genderResultTF.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.locationTF.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.locationResultTF.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.toHelpUsWithTF.font = UIFont(name: "PlayfairDisplay-Regular", size: 15)
        self.helpMeReachTheCoachBT.layer.cornerRadius = 2
        self.helpMeReachTheCoachBT.layer.borderWidth = 0.5
        self.helpMeReachTheCoachBT.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 11)
        self.helpMeReachTheCoachBT.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.helpMeReachTheCoachBT.backgroundColor = UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "TagCell")
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
       
        self .getListTags()
    }
    
    func getListTags() {
        let listTagsLink = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/tags"
        Alamofire.request(.GET, listTagsLink)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                self.arrayTags = JSON as! NSArray
                for i in 0 ..< self.arrayTags.count {
                    let tagContent = self.arrayTags[i] as! NSDictionary
                    let tag = Tag()
                    tag.name = tagContent["title"] as? String
                    tag.tagId = String(format:"%0.f", tagContent["id"]!.doubleValue)
                    self.tags.append(tag)
                }
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tagHeightConstraint.constant = collectionView.collectionViewLayout.collectionViewContentSize().height
        scrollHeightConstraint.constant = collectionView.frame.origin.y + tagHeightConstraint.constant
    }
    
    
    
    
    @IBAction func closeLetUsHelp(sender:UIButton!) {
        let tabbarVC = self.presentingViewController?.childViewControllers[0] as! BaseTabBarController
        let findVC = tabbarVC.viewControllers![2] as! FindViewController
        findVC.showLetUsHelp = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func goSearching(sender:UIButton!) {
        performSegueWithIdentifier("searching", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "searching")
        {
            let destimation = segue.destinationViewController as! SearchingViewController
            destimation.tagIdsArray = tagIdsArray.objectEnumerator().allObjects as? [String]
            if (self.genderResultTF.text ==  "MALE") {
                 destimation.gender = "Male"
            } else if (self.genderResultTF.text ==  "FEMALE") {
                destimation.gender = "Female"
            } else {
                destimation.gender = "Dont care"
            }
        }
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
        let tag = tags[indexPath.row]
        if (tag.selected) {
            tagIdsArray.addObject(tag.tagId!)
        } else {
            tagIdsArray.removeObject(tag.tagId!)
        }
        print(tagIdsArray)
        self.collectionView.reloadData()
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagBackgroundV.backgroundColor = tag.selected ? cell.tagImage.backgroundColor : UIColor.clearColor()
        //cell.tagName.textColor = tag.selected ? UIColor.whiteColor() : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
       // cell.backgroundColor = tag.selected ? UIColor(red: 0, green: 1, blue: 0, alpha: 1) : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        cell.tagNameLeftMarginConstraint.constant = tag.selected ? 8 : 25
    }
    
    @IBAction func clickOnGender(sender: UIButton) {
        let selectMale = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = "MALE"
        }
        let selectFemale = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = "FEMALE"
        }
        let selectDontCare = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = "DON'T CARE"
        }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "MALE", style: UIAlertActionStyle.Default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: "FEMALE", style: UIAlertActionStyle.Default, handler: selectFemale))
        alertController.addAction(UIAlertAction(title: "DON'T CARE", style: UIAlertActionStyle.Default, handler: selectDontCare))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    @IBAction func clickOnLocation(sender: UIButton) {
        let selectGym = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = "GYM"
        }
        let selectSmall = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = "SMALL GROUP TRAINING"
        }
        let selectBootcamp = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = "BOOTCAMP"
        }
        let selectMobile = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = "MOBILE"
        }
        let selectOutdoor = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = "OUTDOOR"
        }
        let selectAnywhere = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = "ANYWHERE"
        }
        let selectPrivateStudio = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = "PRIVATE SUTDIO"
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "GYM", style: UIAlertActionStyle.Default, handler: selectGym))
        alertController.addAction(UIAlertAction(title: "SMALL GROUP TRAINING", style: UIAlertActionStyle.Default, handler: selectSmall))
        alertController.addAction(UIAlertAction(title: "BOOTCAMP", style: UIAlertActionStyle.Default, handler: selectBootcamp))
        alertController.addAction(UIAlertAction(title: "MOBILE", style: UIAlertActionStyle.Default, handler: selectMobile))
        alertController.addAction(UIAlertAction(title: "OUTDOOR", style: UIAlertActionStyle.Default, handler: selectOutdoor))
        alertController.addAction(UIAlertAction(title: "PRIVATE STUDIO", style: UIAlertActionStyle.Default, handler: selectPrivateStudio))
        alertController.addAction(UIAlertAction(title: "ANYWHERE", style: UIAlertActionStyle.Default, handler: selectAnywhere))
        self.presentViewController(alertController, animated: true) { }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}