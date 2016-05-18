//
//  NewMessageViewController.swift
//  pummel
//
//  Created by Bear Daddy on 5/10/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit


class NewMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var listUserTB: UITableView!
    @IBOutlet var toLB : UILabel!
    @IBOutlet var toUserTF : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        self.navigationItem.title = "NEW MESSAGE"
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel")
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)], forState: UIControlState.Normal)
        self.toLB.font = UIFont(name: "Montserrat-Regular", size: 13)
        self.toUserTF.attributedPlaceholder = NSAttributedString(string:"|",
            attributes:([NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!, NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 91.0/255.0, blue: 16.0/255.0, alpha: 1.0)]))
        self.listUserTB.delegate = self
        self.listUserTB.dataSource = self
        self.listUserTB.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.listUserTB.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70 // Ceiling this value fixes disappearing separators
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCell", forIndexPath: indexPath) as! UserTableViewCell
        if (indexPath.row == 0) {
            cell.nameLB.text = "USER 1" as String
        } else if (indexPath.row == 1) {
            cell.nameLB.text =  "USER 2" as String
        } else {
            cell.nameLB.text =  "USER 3" as String
        }
        cell.avatarIMV.image = UIImage(named: "kate.jpg")
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserTableViewCell
        performSegueWithIdentifier("chatMessage", sender: cell.nameLB.text)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "chatMessage")
        {
            let destinationVC = segue.destinationViewController as! ChatMessageViewController
            destinationVC.nameChatUser = sender as! NSString
            if (destinationVC.nameChatUser.isEqualToString("USER 1")) {
                destinationVC.user1 = true
                destinationVC.user2 = false
                destinationVC.user3 = false
                destinationVC.user4 = false
            } else if (destinationVC.nameChatUser.isEqualToString("USER 2")) {
                destinationVC.user1 = false
                destinationVC.user2 = true
                destinationVC.user3 = false
                destinationVC.user4 = false
            } else {
                destinationVC.user1 = false
                destinationVC.user2 = false
                destinationVC.user3 = true
                destinationVC.user4 = false
            }
        }
    }

    
}