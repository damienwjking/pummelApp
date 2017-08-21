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
        self.textLabel?.frame = CGRectMake(60, 5, self.frame.width - 60, self.frame.height - 15)
        
        self.detailTextLabel?.font = UIFont.pmmMonReg11()
        self.detailTextLabel?.textColor = UIColor.lightGrayColor()
        self.detailTextLabel?.frame = CGRectMake(60, self.frame.height - 25, self.frame.width - 60, 20)
        
        self.bringSubviewToFront(self.textLabel!)
        
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

class ContactUserViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var contacts: [CNContact] = []
    var filterContacts: [CNContact] = []
    
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
        
        self.filterPhoneNumber("")
    }
}

// MARK: UITableView
extension ContactUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterContacts.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("kContactUserCell")
        
        let contact = self.filterContacts[indexPath.row]
        
        if (contact.thumbnailImageData == nil) {
            cell?.imageView?.image = UIImage(named: "avatar")
        } else {
            cell?.imageView?.image = UIImage(data: contact.thumbnailImageData!)
        }
        
        let contactName = contact.givenName + " " + contact.familyName
        
        cell?.textLabel?.text = contactName.uppercaseString
        
        var phoneNumberString = ""
        if contact.phoneNumbers.count != 0 {
            let phoneNumber = contact.phoneNumbers.first?.value as! CNPhoneNumber
            phoneNumberString = phoneNumber.stringValue.stringByReplacingOccurrencesOfString("-", withString: "")
        }
        cell?.detailTextLabel?.text = phoneNumberString
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchBar.resignFirstResponder()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if MFMessageComposeViewController.canSendText() {
            let contact = self.filterContacts[indexPath.row]
            
            var phoneNumberString = ""
            if contact.phoneNumbers.count != 0 {
                let phoneNumber = contact.phoneNumbers.first?.value as! CNPhoneNumber
                phoneNumberString = phoneNumber.stringValue.stringByReplacingOccurrencesOfString("-", withString: "")
            }
            
            let messageCompose = MFMessageComposeViewController()
            messageCompose.body = kMessageInviteContact
            messageCompose.recipients = [phoneNumberString]
            
            messageCompose.messageComposeDelegate = self
            self.presentViewController(messageCompose, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}

extension ContactUserViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterPhoneNumber(searchText)
    }
    
    func filterPhoneNumber(filterString: String) {
        self.filterContacts = self.contacts.filter({ (contact) -> Bool in
            if (filterString.isEmpty == true) {
                return true
            }
            
            var phoneNumberString = ""
            if contact.phoneNumbers.count != 0 {
                let phoneNumber = contact.phoneNumbers.first?.value as! CNPhoneNumber
                phoneNumberString = phoneNumber.stringValue.stringByReplacingOccurrencesOfString("-", withString: "")
            }
            var isFilterNumber = phoneNumberString.contains(filterString)
            isFilterNumber = false // only search name
            
            
            
            let phoneName = contact.givenName + " " + contact.familyName
            let isFilterName = phoneName.contains(filterString)
            
            
            return (isFilterNumber || isFilterName) // search phone number or name
        })
        
        self.tableView.reloadData()
    }
}

// MARK: MFMessageComposeViewControllerDelegate
extension ContactUserViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
