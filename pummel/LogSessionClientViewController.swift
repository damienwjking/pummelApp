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
    var editSession = SessionModel()
    var isEditSession = false
    @IBOutlet weak var flowLayout: FlowLayout!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(LogSessionClientViewController.backClicked))
        
        self.initCollectionView()
        
        self.getListTags()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = kLogSession
        
        if (self.isEditSession == true && self.editSession.id == 0) {
            self.navigationController?.popViewController(animated: false)
        }
        
        if self.editSession.id != 0 {
            self.performSegue(withIdentifier: "goLogSessionDetail", sender: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let moveScreenType = defaults.object(forKey: k_PM_MOVE_SCREEN) as! String
        if moveScreenType == k_PM_MOVE_SCREEN_3D_TOUCH_2 {
            self.defaults.set(k_PM_MOVE_SCREEN_NO_MOVE, forKey: k_PM_MOVE_SCREEN)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Init
    func initCollectionView() {
        let cellNib = UINib(nibName: kActivityCell, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: kActivityCell)
        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! ActivityCell?
        
        if (CURRENT_DEVICE == .phone && SCREEN_MAX_LENGTH == 568.0) {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 8)
        } else {
            self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        
        self.flowLayout.isSearch = true
    }
    
    // MARK: Private function
    func getListTags() {
        if (isStopGetListTag == false) {
            var listTagsLink = kPMAPI_TAG4_OFFSET
            listTagsLink.append(String(self.offset))
            Alamofire.request(.GET, listTagsLink)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    self.arrayTags = JSON as! [NSDictionary]
                    if (self.arrayTags.count > 0) {
                        for i in 0 ..< self.arrayTags.count {
                            let tagContent = self.arrayTags[i]
                            let tag = Tag()
                            tag.name = tagContent[kTitle] as? String
                            tag.tagId = String(format:"%0.f", (tagContent[kId]! as AnyObject).doubleValue)
                            tag.tagColor = self.getRandomColorString()
                            tag.tagType = (tagContent[kType] as? NSNumber)?.integerValue
                            
                            // get body building tag to set color for ccling tag
                            if tag.name?.uppercased() == "body building".uppercased() {
                                self.bodyBuildingTag = tag
                            }
                            
                            if tag.name?.uppercased() == "Cycling".uppercased() {
                                if (self.bodyBuildingTag.tagColor?.isEmpty == false) {
                                    tag.tagColor = self.bodyBuildingTag.tagColor
                                }
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
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UICOLLECTION
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kActivityCell, for: indexPath) as! ActivityCell
        
        self.configureCell(cell: cell, forIndexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath as NSIndexPath)
        return (self.sizingCell?.systemLayoutSizeFitting(UILayoutFittingCompressedSize))!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "selectUser", sender: nil)
    }
    
    func configureCell(cell: ActivityCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name?.uppercased()
        cell.tagBackgroundV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
    }
    
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogSessionTableViewCell") as! LogSessionTableViewCell
        
        let tag = tags[indexPath.row]
//        let tagName = String(format: "#%ld %@", tag.tagType!, (tag.name?.uppercased())!)
        let tagName = tag.name?.uppercased()
        cell.LogTitleLB.text = tagName
        cell.tagTypeLabel.text = ""
        cell.statusIMV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
        
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let tag = tags[indexPath.row]
        if (self.defaults.bool(forKey: k_PM_IS_COACH) == true) {
            self.performSegue(withIdentifier: "selectUser", sender: tag)
        } else {
            self.performSegue(withIdentifier: "goLogSessionDetail", sender: tag)
        }
    }
    
    // MARK: Segue
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goLogSessionDetail" {
            let destination = segue.destination as! LogSessionClientDetailViewController
            
            if sender == nil {
               destination.editSession = self.editSession
                self.editSession = SessionModel()
                self.isEditSession = true
                
                let view = UIView(frame: self.view.bounds)
                view.backgroundColor = UIColor.white
                self.view.addSubview(view)
            } else {
               destination.tag = (sender as! Tag)
            }
        } else if segue.identifier == "selectUser" {
            let destination = segue.destination as! LogSessionSelectUserViewController
            destination.tag = sender as? Tag
        }
    }
    
}
