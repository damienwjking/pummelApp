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
        self.detailTextLabel?.textColor = UIColor.lightGray
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
    var styleInvite = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancel))
        
        self.getAllContact()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = kInvite.uppercased()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
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
                contacts.append(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        self.filterPhoneNumber("")
    }
}

// MARK: UITableView
extension ContactUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterContacts.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kContactUserCell")
        
        let contact = self.filterContacts[indexPath.row]
        
        if (contact.thumbnailImageData == nil) {
            cell?.imageView?.image = UIImage(named: "avatar")
        } else {
            cell?.imageView?.image = UIImage(data: contact.thumbnailImageData!)
        }
        
        let contactName = contact.givenName + " " + contact.familyName
        cell?.textLabel?.text = contactName.uppercased()
        
        if (self.styleInvite == kSMS) {
            var phoneNumberString = ""
            if contact.phoneNumbers.count != 0 {
                let phoneNumber = contact.phoneNumbers.first?.value as! CNPhoneNumber
                phoneNumberString = phoneNumber.stringValue.replacingOccurrences(of: "-", with: "")
            }
            
            cell?.detailTextLabel?.text = phoneNumberString
        } else {
            let emailString = contact.emailAddresses[0].value as! String
            
            cell?.detailTextLabel?.text = emailString
        }
        
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (self.styleInvite == kSMS) {
            if MFMessageComposeViewController.canSendText() {
                let contact = self.filterContacts[indexPath.row]
                
                var phoneNumberString = ""
                if contact.phoneNumbers.count != 0 {
                    let phoneNumber = contact.phoneNumbers.first?.value as! CNPhoneNumber
                    phoneNumberString = phoneNumber.stringValue.replacingOccurrences(of: "-", with: "")
                }
                
                let messageCompose = MFMessageComposeViewController()
                messageCompose.body = kMessageInviteContact
                messageCompose.recipients = [phoneNumberString]
                
                messageCompose.messageComposeDelegate = self
                self.present(messageCompose, animated: true, completion: nil)
            }
        } else if (self.styleInvite == kEmail) {
            self.view.makeToastActivity()
            
            UserRouter.getCurrentUserInfo(completed: { (result, error) in
                self.view.hideToastActivity()
                
                if (error == nil) {
                    let currentInfo = result as! NSDictionary
                    let currentMail = currentInfo[kEmail] as! String
                    let coachFirstName = currentInfo[kFirstname] as! String
                    
                    let contact = self.filterContacts[indexPath.row]
                    let userFirstName = contact.givenName.replacingOccurrences(of: " ", with: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    let userMail = contact.emailAddresses[0].value as! String
                    
                    var urlString = "mailto:"
                    urlString = urlString.stringByAppendingString(userMail)
                    
                    urlString = urlString.stringByAppendingString("?subject=")
                    urlString = urlString.stringByAppendingString("Come%20join%20me%20on%20Pummel%20Fitness")
                    
                    urlString = urlString.stringByAppendingString("&from=")
                    urlString = urlString.stringByAppendingString(currentMail)
                    
                    urlString = urlString.stringByAppendingString("&body=")
                    urlString = urlString.stringByAppendingString("Hey%20\(userFirstName),%0A%0ACome%20join%20me%20on%20the%20Pummel%20Fitness%20app,%20where%20we%20can%20book%20appointments,%20log%20workouts,%20save%20transformation%20photos%20and%20chat%20for%20free.%0A%0ADownload%20the%20app%20at%20http://get.pummel.fit%0A%0AThanks,%0A%0ACoach%0A\(coachFirstName)")
                    
                    let mailURL = NSURL(string: urlString)
                    if (UIApplication.sharedApplication().canOpenURL(mailURL!)) {
                        UIApplication.sharedApplication().openURL(mailURL!)
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
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
    
    func filterPhoneNumber(filterValue: String) {
        let filterString = filterValue.lowercased()
        
        self.filterContacts = self.contacts.filter({ (contact) -> Bool in
            var isFilterNumber = false
            var isFilterName = false
            var isFilterEmail = false
            
            if (self.styleInvite == kSMS) {
                if (filterString.isEmpty == true) {
                    return true
                }
                
                var phoneNumberString = ""
                if contact.phoneNumbers.count != 0 {
                    let phoneNumber = contact.phoneNumbers.first?.value as! CNPhoneNumber
                    phoneNumberString = phoneNumber.stringValue.replacingOccurrences(of: "-", with: "")
                }
                isFilterNumber = phoneNumberString.contains(filterString)
                isFilterNumber = false // not available filter number now
                
                var phoneName = contact.givenName + " " + contact.familyName
                phoneName = phoneName.lowercased()
                isFilterName = phoneName.contains(filterString)
            } else if (self.styleInvite == kEmail) {
                if (contact.emailAddresses.count > 0) {
                    if (filterString.isEmpty == true) {
                        return true
                    }
                    
                    var phoneName = contact.givenName + " " + contact.familyName
                    phoneName = phoneName.lowercased()
                    isFilterName = phoneName.contains(filterString)
                    
                    var email = contact.emailAddresses[0].value as! String
                    email = email.lowercased()
                    isFilterEmail = email.contains(filterString)
                }
            }
            
            return (isFilterNumber || isFilterName || isFilterEmail) // search phone number or name
        })
        
        self.tableView.reloadData()
    }
}

// MARK: MFMessageComposeViewControllerDelegate
extension ContactUserViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(animated: true, completion: nil)
    }
}
