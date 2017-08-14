//
//  ContactUserViewController.swift
//  pummel
//
//  Created by Nguyễn Tấn Phúc on 1/10/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class ContactUserCell : UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView?.frame = CGRectMake(10, 10, 40, 40)
        self.imageView?.layer.cornerRadius = 20
        self.imageView?.layer.masksToBounds = true
        
        self.textLabel?.font = UIFont.pmmMonReg13()
        self.textLabel?.textColor = UIColor.darkGrayColor()
        self.textLabel?.frame = CGRectMake(60, 0, self.frame.width, self.frame.height)
        
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

class ContactUserViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var contacts: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancel))
        
        self.getAllContact()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = kInvite.uppercaseString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Private function
    func getAllContact() {
        // You may add more "keys" to fetch referred to official documentation
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                           CNContactEmailAddressesKey,
                           CNContactPhoneNumbersKey,
                           CNContactImageDataAvailableKey,
                           CNContactThumbnailImageDataKey
        ]
        let store = CNContactStore()
        
        // The container means
        // that the source the contacts from, such as Exchange and iCloud
        var allContainers: [CNContainer] = []
        do {
            allContainers = try store.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        // Loop the containers
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try store.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                // Put them into "contacts"
                contacts.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("kContactUserCell")
        
        let contact = self.contacts[indexPath.row]
        
        if (contact.thumbnailImageData == nil) {
            cell?.imageView?.image = UIImage(named: "avatar")
        } else {
            cell?.imageView?.image = UIImage(data: contact.thumbnailImageData!)
        }
        
        let contactName = contact.givenName + " " + contact.familyName
        
        cell?.textLabel?.text = contactName.uppercaseString
        
        return cell!
    }
    
    
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if MFMessageComposeViewController.canSendText() {
            let contact = self.contacts[indexPath.row]
            let messageImage = UIImage(named: "shareLogo.png")
            let messageImageData = UIImagePNGRepresentation(messageImage!)
            
            var phoneNumberString = ""
            if contact.phoneNumbers.count != 0 {
                let phoneNumber = contact.phoneNumbers.first?.value as! CNPhoneNumber
                phoneNumberString = phoneNumber.stringValue.stringByReplacingOccurrencesOfString("-", withString: "")
            }
            
            let controller = MFMessageComposeViewController()
            controller.body = kMessageInviteContact
            controller.recipients = [phoneNumberString]
            controller.addAttachmentData(messageImageData!, typeIdentifier: "public.data", filename: "image.png")
            
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    
    // MARK: MFMessageComposeViewControllerDelegate
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
