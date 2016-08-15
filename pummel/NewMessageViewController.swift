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
    var arrayListUser: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        self.navigationItem.title = "NEW MESSAGE"
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewMessageViewController.cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
        self.toLB.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.toUserTF.attributedPlaceholder = NSAttributedString(string:"|",
            attributes:([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)]))
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
        Alamofire.request(.GET, "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users")
            .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    print(JSON)
                    self.arrayListUser = JSON as! NSArray
                    self.listUserTB.reloadData()
                case .Failure(let error):
                    print("Request failed with error: \(error)")
            }
        }
    }
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70 // Ceiling this value fixes disappearing separators
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UserTableViewCell
        let user = arrayListUser[indexPath.row] as! NSDictionary
        var name = user.objectForKey("firstname") as! String
        name.appendContentsOf(" ")
        name.appendContentsOf(user.objectForKey("lastname") as! String)
        cell.nameLB.text = name.uppercaseString
        let idSender = String(format:"%0.f",user.objectForKey("id")!.doubleValue)
        var prefix = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001/api/users/"
        prefix.appendContentsOf(idSender)
        prefix.appendContentsOf("/photos")
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let listPhoto = JSON as! NSArray
                if (listPhoto.count >= 1) {
                    let photo = listPhoto.objectAtIndex(listPhoto.count - 1) as! NSDictionary
                    var link = "http://ec2-52-63-160-162.ap-southeast-2.compute.amazonaws.com:3001"
                    link.appendContentsOf(photo.objectForKey("imageUrl") as! String)
                    link.appendContentsOf("?width=80&height=80")
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
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arrayListUser == nil) {
            return 0
        } else {
            return arrayListUser.count
        }
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
            let user = arrayListUser[indexPathRow] as! NSDictionary
            destinationVC.nameChatUser = (user.objectForKey("firstname") as! String).uppercaseString
            destinationVC.userIdTarget = String(format:"%0.f", user["id"]!.doubleValue)
        }
    }
}