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
        
        self.imageView?.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        self.imageView?.layer.cornerRadius = 20
        self.imageView?.layer.masksToBounds = true
        
        self.textLabel?.font = UIFont.pmmMonReg13()
        self.textLabel?.textColor = UIColor.darkGray
        self.textLabel?.frame = CGRect(x: 60, y: 5, width: self.frame.width - 60, height: self.frame.height - 15)
        
        self.detailTextLabel?.font = UIFont.pmmMonReg11()
        self.detailTextLabel?.textColor = UIColor.lightGray
        self.detailTextLabel?.frame = CGRect(x: 60, y: self.frame.height - 25, width: self.frame.width - 60, height: 20)
        
        self.bringSubview(toFront: self.textLabel!)
        
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
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactEmailAddressesKey,
                           CNContactPhoneNumbersKey,
                           CNContactImageDataAvailableKey,
                           CNContactThumbnailImageDataKey
        ] as [Any]
        let store = CNContactStore()
        
        // The container means
        // that the source the contacts from, such as Exchange and iCloud
        var allContainers: [CNContainer] = []
        do {
            allContainers = try store.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        // Loop the containers
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                
                // Put them into "contacts"
                for contact in containerResults {
                    contacts.append(contact)
                }
            } catch {
                print("Error fetching results for container")
            }
        }
        
        self.filterPhoneNumber(filterValue: "")
    }
}

// MARK: UITableView
extension ContactUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterContacts.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
                let phoneNumber = contact.phoneNumbers.first?.value
                phoneNumberString = (phoneNumber?.stringValue.replacingOccurrences(of: "-", with: ""))!
            }
            
            cell?.detailTextLabel?.text = phoneNumberString
        } else {
            let emailString = contact.emailAddresses[0].value as String
            
            cell?.detailTextLabel?.text = emailString
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        if (self.styleInvite == kSMS) {
            if MFMessageComposeViewController.canSendText() {
                let contact = self.filterContacts[indexPath.row]
                
                var phoneNumberString = ""
                if contact.phoneNumbers.count != 0 {
                    let phoneNumber = contact.phoneNumbers.first?.value
                    phoneNumberString = (phoneNumber?.stringValue.replacingOccurrences(of: "-", with: ""))!
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
                    let coachFirstName = currentInfo[kFirstname] as! String
                    let currentUserID = PMHelper.getCurrentID()
                    
                    let contact = self.filterContacts[indexPath.row]
                    let userFirstName = contact.givenName
                    
                    if MFMailComposeViewController.canSendMail() {
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = self
                        
                        mail.setSubject("Come join me on Pummel Fitness")
                        mail.setMessageBody("Hey \(userFirstName),<br /><br />Come join me on the Pummel Fitness app, where we can book appointments, log workouts, save transformation photos and chat for free.<br /><br />Download the app at http://get.pummel.fit<br /><br />Thanks,<br /><br />Coach \(coachFirstName)<br />Link to my profile: pummel://coachid=\(currentUserID)", isHTML: true)
                        self.present(mail, animated: true, completion: nil)
                    } else {
                        PMHelper.showDoAgainAlert()
                    }
                    
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}

extension ContactUserViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterPhoneNumber(filterValue: searchText)
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
                    let phoneNumber = contact.phoneNumbers.first?.value
                    phoneNumberString = (phoneNumber?.stringValue.replacingOccurrences(of: "-", with: ""))!
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
                    
                    var email = contact.emailAddresses[0].value as String
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
extension ContactUserViewController: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
