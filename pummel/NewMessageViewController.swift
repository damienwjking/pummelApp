//
//  NewMessageViewController.swift
//  pummel
//
//  Created by Bear Daddy on 5/10/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class NewMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var listUserTB: UITableView!
    @IBOutlet var toLB : UILabel!
    @IBOutlet var toUserTF : UITextField!
    var arrayListUser: [NSDictionary] = []
    var isStopLoad: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.title = kNavNewMessage
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewMessageViewController.cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.toLB.font = .pmmMonReg13()
        self.toUserTF.attributedPlaceholder = NSAttributedString(string:"|",
            attributes:([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()]))
        self.listUserTB.delegate = self
        self.listUserTB.dataSource = self
        self.listUserTB.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.listUserTB.separatorStyle = UITableViewCellSeparatorStyle.None
        self.getListUser()
    }
    
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getListUser() {
        if (self.isStopLoad == false) {
            var prefix = kPMAPIUSER_OFFSET
            let offset = self.arrayListUser.count
            prefix.appendContentsOf(String(offset))
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    print(JSON)
                    let resultArr = JSON as! [NSDictionary]
                    if (resultArr.count == 0) {
                        self.isStopLoad = true
                    } else {
                        self.arrayListUser += resultArr
                        self.listUserTB.reloadData()
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70 // Ceiling this value fixes disappearing separators
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kUserTableViewCell, forIndexPath: indexPath) as! UserTableViewCell
        cell.tag = indexPath.row
        cell.avatarIMV.image = nil
        let user = arrayListUser[indexPath.row]
        var name = user.objectForKey(kFirstname) as! String
        name.appendContentsOf(" ")
        name.appendContentsOf(user.objectForKey(kLastName) as! String)
        cell.nameLB.text = name.uppercaseString
        let idSender = String(format:"%0.f",user.objectForKey(kId)!.doubleValue)
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(idSender)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetail = JSON as! NSDictionary
                if !(userDetail[kImageUrl] is NSNull) {
                    var link = kPMAPI
                    link.appendContentsOf(userDetail[kImageUrl] as! String)
                    link.appendContentsOf(widthHeight160)
                    
                    if (NSCache.sharedInstance.objectForKey(link) != nil) {
                        let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                        cell.avatarIMV.image = imageRes
                    } else {
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                cell.avatarIMV.image = imageRes
                                NSCache.sharedInstance.setObject(imageRes, forKey: link)
                        }
                    }
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
        if (indexPath.row == arrayListUser.count - 1) {
            self.getListUser()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayListUser.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        performSegueWithIdentifier("chatMessage", sender: indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "chatMessage")
        {
            let destinationVC = segue.destinationViewController as! ChatMessageViewController
            let indexPathRow = sender as! Int
            let user = arrayListUser[indexPathRow]
            destinationVC.nameChatUser = (user.objectForKey(kFirstname) as! String).uppercaseString
            destinationVC.userIdTarget = String(format:"%0.f", user[kId]!.doubleValue)
        }
    }
}
