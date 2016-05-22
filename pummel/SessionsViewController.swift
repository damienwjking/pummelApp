//
//  SessionsViewController.swift
//  pummel
//
//  Created by Damien King on 21/02/2016.
//  Copyright © 2016 pummel. All rights reserved.
//
// Sessions will show all the users previous sessions


import UIKit


class SessionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var listMessageTB: UITableView!
    var arrayMessages: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = User.init(name: "KATE", avatar: UIImagePNGRepresentation(UIImage(named: "kate.jpg")!)!)
        let mess = Message.init(timeLeft: "now", message: "hello, how are you, i just want to say hello. Im very busy now.", read: false, user: user)
    
        arrayMessages = NSArray.init(object: mess)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.title = "MESSAGES"
        self.tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 13)!]
        let image = UIImage(named: "newmessage")!.imageWithRenderingMode(.AlwaysOriginal)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action:"newMessage")
        let selectedImage = UIImage(named: "messagesSelcted")
        self.tabBarItem.selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        self.listMessageTB.delegate = self
        self.listMessageTB.dataSource = self
        self.listMessageTB.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func newMessage() {
        performSegueWithIdentifier("newMessage", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
        // Ceiling this value fixes disappearing separators
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        let message = arrayMessages.objectAtIndex(indexPath.row) as! Message
        cell.nameLB.text = message.user.name as? String
        cell.messageLB.text = message.message as? String
        cell.avatarIMV.image = UIImage(named: "kate.jpg")
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayMessages.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MessageTableViewCell
        performSegueWithIdentifier("checkChatMessage", sender: cell.nameLB.text)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "checkChatMessage")
        {
            let destinationVC = segue.destinationViewController as! ChatMessageViewController
            destinationVC.nameChatUser = sender as! NSString
            destinationVC.message = arrayMessages[0] as! Message
            destinationVC.user1 = false
            destinationVC.user2 = false
            destinationVC.user3 = false
            destinationVC.user4 = true
        }
    }

    
}