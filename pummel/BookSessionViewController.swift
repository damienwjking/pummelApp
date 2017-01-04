//
//  BookSessionViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class BookSessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tbView: UITableView!
    var tags = [Tag]()
    var arrayTags : [NSDictionary] = []
    var offset: Int = 0
    var tagSelect:Tag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        let nibName = UINib(nibName: "BookSessionTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName, forCellReuseIdentifier: "BookSessionTableViewCell")
    
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BookSessionViewController.cancel))
        
        self.getListTags()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kBookSession
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = " "
    }
    
    // MARK: Private function
    func getListTags() {
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
                    self.tbView.reloadData()
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func getRandomColorString() -> String{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return String(format: "#%02x%02x%02x%02x", Int(randomRed*255), Int(randomGreen*255),Int(randomBlue*255),255)
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookSessionTableViewCell") as! BookSessionTableViewCell
        if tags.count <= indexPath.row {
            return cell
        }
        let tag = tags[indexPath.row]
        cell.bookTitleLB.text = tag.name?.uppercaseString
        cell.statusIMV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let tag = tags[indexPath.row]
        tagSelect = tag
        self.performSegueWithIdentifier("selectUser", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectUser" {
            let destination = segue.destinationViewController as! BookSessionSelectUserViewController
            destination.tag = tagSelect
        }
    }
}

