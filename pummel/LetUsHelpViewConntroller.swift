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
    var arrayTags : [NSDictionary] = []
    var tagIdsArray : NSMutableArray = []
    var offset: Int = 0
    var isStopGetListTag : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.letUsHelpTF.font = .pmmPlayFairReg33()
        self.letUsHelpDetailTF.font = .pmmPlayFairReg15()
        self.genderTF.font = .pmmMonReg11()
        self.genderResultTF.font = .pmmMonReg11()
        self.locationTF.font = .pmmMonReg11()
        self.locationResultTF.font = .pmmMonReg11()
        self.toHelpUsWithTF.font = .pmmPlayFairReg15()
        self.helpMeReachTheCoachBT.layer.cornerRadius = 2
        self.helpMeReachTheCoachBT.layer.borderWidth = 0.5
        self.helpMeReachTheCoachBT.titleLabel?.font = .pmmMonReg11()
        self.helpMeReachTheCoachBT.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.helpMeReachTheCoachBT.backgroundColor = .pmmBrightOrangeColor()
        let cellNib = UINib(nibName: kTagCell, bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: kTagCell)
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCell?
        self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        self.flowLayout.isSearch = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        offset = 0
        isStopGetListTag = false
        self.getListTags()
    }
    
    func getListTags() {
        if (isStopGetListTag == false) {
            var listTagsLink = kPMAPI_TAG_OFFSET
            listTagsLink.appendContentsOf(String(offset))
            Alamofire.request(.GET, listTagsLink)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    print (JSON)
                    self.arrayTags = JSON as! [NSDictionary]
                    if (self.arrayTags.count > 0) {
                        for i in 0 ..< self.arrayTags.count {
                            let tagContent = self.arrayTags[i]
                            let tag = Tag()
                            tag.name = tagContent[kTitle] as? String
                            tag.tagId = String(format:"%0.f", tagContent[kId]!.doubleValue)
                            self.tags.append(tag)
                        }
                        self.offset += 10
                        self.collectionView.reloadData({ 
                            self.tagHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize().height
                            self.scrollHeightConstraint.constant = self.collectionView.frame.origin.y + self.tagHeightConstraint.constant
                        })
                    } else {
                        self.isStopGetListTag = true
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
        } else
        {
            self.isStopGetListTag = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
            if (self.genderResultTF.text ==  kMALEU) {
                 destimation.gender = kMale
            } else if (self.genderResultTF.text ==  kFemaleU) {
                destimation.gender = kFemale
            } else {
                destimation.gender = kDontCare
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTagCell, forIndexPath: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
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
        let contentOffset = self.scrollView.contentOffset 
        self.collectionView.reloadData()
        scrollView.setContentOffset(contentOffset, animated: false)
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
            self.genderResultTF.text = kMALEU
        }
        let selectFemale = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = kFemaleU
        }
        let selectDontCare = { (action:UIAlertAction!) -> Void in
            self.genderResultTF.text = kDontCareUp
        }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kMALEU, style: UIAlertActionStyle.Default, handler: selectMale))
        alertController.addAction(UIAlertAction(title: kFemaleU, style: UIAlertActionStyle.Default, handler: selectFemale))
        alertController.addAction(UIAlertAction(title: kDontCareUp, style: UIAlertActionStyle.Default, handler: selectDontCare))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    @IBAction func clickOnLocation(sender: UIButton) {
        let selectGym = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = kGYM
        }
        let selectSmall = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = kSMALLGROUPTRAINING
        }
        let selectBootcamp = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = kBOOTCAMP
        }
        let selectMobile = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = kMOBILE
        }
        let selectOutdoor = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = kOUTDOOR
        }
        let selectAnywhere = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = kANYWHERE
        }
        let selectPrivateStudio = { (action:UIAlertAction!) -> Void in
            self.locationResultTF.text = kPRIVATESTUDIO
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: kGYM, style: UIAlertActionStyle.Default, handler: selectGym))
        alertController.addAction(UIAlertAction(title: kSMALLGROUPTRAINING, style: UIAlertActionStyle.Default, handler: selectSmall))
        alertController.addAction(UIAlertAction(title: kBOOTCAMP, style: UIAlertActionStyle.Default, handler: selectBootcamp))
        alertController.addAction(UIAlertAction(title: kMOBILE, style: UIAlertActionStyle.Default, handler: selectMobile))
        alertController.addAction(UIAlertAction(title: kOUTDOOR, style: UIAlertActionStyle.Default, handler: selectOutdoor))
        alertController.addAction(UIAlertAction(title: kPRIVATESTUDIO, style: UIAlertActionStyle.Default, handler: selectPrivateStudio))
        alertController.addAction(UIAlertAction(title: kANYWHERE, style: UIAlertActionStyle.Default, handler: selectAnywhere))
        self.presentViewController(alertController, animated: true) { }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

extension UICollectionView {
    func reloadData(completion: ()->()) {
        UIView.animateWithDuration(0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

extension UITableView {
    func reloadData(completion: ()->()) {
        UIView.animateWithDuration(0, animations: { self.reloadData() })
        { _ in completion() }
    }
}
