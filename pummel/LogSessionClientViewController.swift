//
//  LogSessionClientViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation
import Alamofire


class LogSessionClientViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tags = [Tag]()
    var arrayTags : [NSDictionary] = []
    var isStopGetListTag = false
    var offset: Int = 0
    var sizingCell: ActivityCell?
    var bodyBuildingTag = Tag()
    @IBOutlet weak var flowLayout: FlowLayout!
    let SCREEN_MAX_LENGTH = max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(LogSessionClientViewController.backClicked))
        
        self.initCollectionView()
        
        self.getListTags()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = kLogSession
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let touch3DType = defaults.objectForKey(k_PM_3D_TOUCH) as! String
        if touch3DType == "3dTouch_2" {
            defaults.setObject(k_PM_3D_TOUCH_VALUE, forKey: k_PM_3D_TOUCH)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Init
    func initCollectionView() {
        let cellNib = UINib(nibName: kActivityCell, bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: kActivityCell)
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! ActivityCell?
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone && SCREEN_MAX_LENGTH == 568.0) {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 8)
        } else {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        
        self.flowLayout.isSearch = true
    }
    
    // MARK: Private function
    func getListTags() {
        if (isStopGetListTag == false) {
            var listTagsLink = kPMAPI_TAG_OFFSET
            listTagsLink.appendContentsOf(String(self.offset))
            Alamofire.request(.GET, listTagsLink)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    self.arrayTags = JSON as! [NSDictionary]
                    if (self.arrayTags.count > 0) {
                        for i in 0 ..< self.arrayTags.count {
                            let tagContent = self.arrayTags[i]
                            let tag = Tag()
                            tag.name = tagContent[kTitle] as? String
                            tag.tagId = String(format:"%0.f", tagContent[kId]!.doubleValue)
                            tag.tagColor = self.getRandomColorString()
                            tag.tagType = (tagContent[kType] as? NSNumber)?.integerValue
                            
                            // get body building tag to set color for ccling tag
                            if tag.name?.uppercaseString == "body building".uppercaseString {
                                self.bodyBuildingTag = tag
                            }
                            
                            if tag.name?.uppercaseString == "Cycling".uppercaseString {
                                tag.tagColor = self.bodyBuildingTag.tagColor
                            }
                            
                            self.tags.append(tag)
                        }
                        self.offset += 10
                        
//                        self.collectionView.reloadData()
                        self.tableView.reloadData()
                    } else {
                        self.isStopGetListTag = true
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
        } else {
            self.isStopGetListTag = true
        }
    }
    
    func getRandomColorString() -> String{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed*255), Int(randomGreen*255),Int(randomBlue*255),255)
    }
    
    func backClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UICOLLECTION
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kActivityCell, forIndexPath: indexPath) as! ActivityCell
        
        self.configureCell(cell, forIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        return self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("selectUser", sender: nil)
    }
    
    func configureCell(cell: ActivityCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name?.uppercaseString
        cell.tagBackgroundV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
    }
    
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogSessionTableViewCell") as! LogSessionTableViewCell
        
        let tag = tags[indexPath.row]
        cell.LogTitleLB.text = tag.name?.uppercaseString
        cell.tagTypeLabel.text = String(format: "%ld", tag.tagType!)
        cell.statusIMV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
        
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let tag = tags[indexPath.row]
        if (self.defaults.boolForKey(k_PM_IS_COACH) == true) {
            self.performSegueWithIdentifier("selectUser", sender: tag)
        } else {
            self.performSegueWithIdentifier("goLogSessionDetail", sender: tag)
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goLogSessionDetail" {
            let destination = segue.destinationViewController as! LogSessionClientDetailViewController
            destination.tag = (sender as! Tag)
        } else if segue.identifier == "selectUser" {
            let destination = segue.destinationViewController as! LogSessionSelectUserViewController
            destination.tag = sender as? Tag
        }
    }
    
}
