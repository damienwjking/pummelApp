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


class LogSessionClientViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tags = [Tag]()
    var arrayTags : [NSDictionary] = []
    var isStopGetListTag = false
    var offset: Int = 0
    var sizingCell: ActivityCell?
    @IBOutlet weak var flowLayout: FlowLayout!
    let SCREEN_MAX_LENGTH = max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        self.initCollectionView()
        
        
        self.getListTags()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = kLogSession
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.title = " "
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
                            self.tags.append(tag)
                        }
                        self.offset += 10
                        self.collectionView.reloadData()
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
    
    // MARK: UICOLLECTION
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kActivityCell, forIndexPath: indexPath) as! ActivityCell
        
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
        self.performSegueWithIdentifier("goLogSessionDetail", sender: nil)
    }
    
    func configureCell(cell: ActivityCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagBackgroundV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
    }
    
    
    //MARK: TableView
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 60
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 4
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("LogSessionTableViewCell") as! LogSessionTableViewCell
//        
//        if indexPath.row == 0 {
//            cell.statusIMV.backgroundColor = UIColor.yellowColor();
//            cell.LogTitleLB.text = "RUNNING"
//        } else {
//            cell.statusIMV.backgroundColor = UIColor.greenColor();
//            cell.LogTitleLB.text = "SWIMMING"
//        }
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        
//        self.performSegueWithIdentifier("goLogSessionDetail", sender: nil)
//    }
    
}
