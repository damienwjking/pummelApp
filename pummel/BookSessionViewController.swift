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

class BookSessionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tbView: UITableView!
    var tags = [Tag]()
    var arrayTags : [NSDictionary] = []
    var offset: Int = 0
    var tagSelect:Tag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        let nibName = UINib(nibName: "BookSessionTableViewCell", bundle:nil)
        self.tbView.register(nibName, forCellReuseIdentifier: "BookSessionTableViewCell")
    
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(BookSessionViewController.cancel))
        
        self.getListTags()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kBookSession
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = " "
    }
    
    // MARK: Private function
    func getListTags() {
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
                        self.tags.append(tag)
                    }
                    self.offset += 10
                    self.tbView.reloadData()
                }
            case .Failure(let error):
                print("Request failed with error: \(String(describing: error))")
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
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookSessionTableViewCell") as! BookSessionTableViewCell
        if tags.count <= indexPath.row {
            return cell
        }
        let tag = tags[indexPath.row]
        
//        let tagName = String(format: "#%ld %@", tag.tagType!, (tag.name?.uppercased())!)
        let tagName = (tag.name?.uppercased())
        cell.bookTitleLB.text = tagName
        cell.statusIMV.backgroundColor = UIColor.init(hexString: tag.tagColor!)
        if (indexPath.row == tags.count - 1) {
            self.getListTags()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tag = tags[indexPath.row]
        tagSelect = tag
        self.performSegue(withIdentifier: "selectUser", sender: nil)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectUser" {
            let destination = segue.destination as! BookSessionSelectUserViewController
            destination.tag = tagSelect
        }
    }
}

