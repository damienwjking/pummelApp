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

class NewMessageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var listUserTB: UITableView!
    @IBOutlet var listUserSearchResultTB: UITableView!
    @IBOutlet var toLB : UILabel!
    @IBOutlet var toUserTF : UITextField!
    var arrayListUser: [NSDictionary] = []
    var arrayListUserResult: [NSDictionary] = []
    var isStopLoad: Bool = false
    var isStopLoadSearch: Bool = false
    var offset : Int = 0
    var isLoading : Bool = false
    var isLoadingSearch : Bool = false
    
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
        self.listUserSearchResultTB.delegate = self
        self.listUserSearchResultTB.dataSource = self
        self.listUserSearchResultTB.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.listUserSearchResultTB.separatorStyle = UITableViewCellSeparatorStyle.None
        self.toUserTF.delegate = self
        self.getListUser()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.text = ""
        self.arrayListUserResult.removeAll()
        self.listUserSearchResultTB.reloadData()
        self.listUserTB.hidden = true
        self.listUserSearchResultTB.hidden = false
        return true
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if (textField.text == "") {
            self.listUserTB.hidden = false
            self.arrayListUserResult.removeAll()
            self.listUserSearchResultTB.reloadData()
            self.listUserSearchResultTB.hidden = true
        } else {
            self.arrayListUserResult.removeAll()
            self.getListUserSearch()
            self.listUserTB.hidden = true
            self.listUserSearchResultTB.hidden = false
            
            
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getListUserSearch() {
        if (self.isStopLoadSearch == false) {
            self.isLoading = true
            var prefix = kPMAPISEARCHUSER
            let offset = self.arrayListUserResult.count
            prefix.appendContentsOf(String(offset))
            prefix.appendContentsOf("&character=")
//            prefix.appendContentsOf(self.toUserTF.text!)
            prefix.appendContentsOf(self.toUserTF.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let resultArrS = JSON as! [NSDictionary]
                    if (resultArrS.count == 0) {
                        self.isLoadingSearch = false
                        self.isStopLoadSearch = true
                    } else {
                        self.arrayListUserResult += resultArrS
                        self.isLoadingSearch = false
                        self.listUserSearchResultTB.reloadData()
                    }
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    }
            }
        }
    }
    
    func getListUser() {
        if (self.isStopLoad == false) {
            self.isLoadingSearch = true
            var prefix = kPMAPIUSER_OFFSET
            let offset = self.arrayListUser.count
            prefix.appendContentsOf(String(offset))
            Alamofire.request(.GET, prefix)
                .responseJSON { response in switch response.result {
                case .Success(let JSON):
                    let resultArr = JSON as! [NSDictionary]
                    if (resultArr.count == 0) {
                        self.isLoading = false
                        self.isStopLoad = true
                    } else {
                        self.arrayListUser += resultArr
                        self.isLoading = false
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
        if (tableView == listUserTB) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kUserTableViewCell, forIndexPath: indexPath) as! UserTableViewCell
            cell.tag = indexPath.row
            let user = arrayListUser[indexPath.row]
            var name = user.objectForKey(kFirstname) as! String
            name.appendContentsOf(" ")
            if !(user.objectForKey(kLastName) is NSNull) {
                name.appendContentsOf(user.objectForKey(kLastName) as! String)
            }
            cell.nameLB.text = name.uppercaseString
            
            cell.avatarIMV.image = UIImage(named:"display-empty.jpg")
            
            let idSender = String(format:"%0.f",user.objectForKey(kId)!.doubleValue)
            ImageRouter.getUserAvatar(userID: idSender, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                    let updateCell = tableView.cellForRowAtIndexPath(indexPath)
                    if updateCell != nil {
                        let imageRes = result as! UIImage
                        dispatch_async(dispatch_get_main_queue(),{
                            cell.avatarIMV.image = imageRes
                        })
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(kUserTableViewCell, forIndexPath: indexPath) as! UserTableViewCell
            cell.tag = indexPath.row
            let user = arrayListUserResult[indexPath.row]
            var name = user.objectForKey(kFirstname) as! String
            name.appendContentsOf(" ")
            if !(user.objectForKey(kLastName) is NSNull) {
                name.appendContentsOf(user.objectForKey(kLastName) as! String)
            }
            cell.nameLB.text = name.uppercaseString
            
            cell.avatarIMV.image = UIImage(named:"display-empty.jpg")
            
            let idSender = String(format:"%0.f",user.objectForKey(kId)!.doubleValue)
            ImageRouter.getUserAvatar(userID: idSender, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                    let updateCell = tableView.cellForRowAtIndexPath(indexPath)
                    if updateCell != nil {
                        let imageRes = result as! UIImage
                        dispatch_async(dispatch_get_main_queue(),{
                            cell.avatarIMV.image = imageRes
                        })
                    }
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
                        
            return cell

        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell , forRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == listUserTB) {
            if (indexPath.row == self.arrayListUser.count - 1 && isLoading == false) {
                offset += 10
                self.getListUser()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == listUserTB) ? arrayListUser.count : arrayListUserResult.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        performSegueWithIdentifier("chatMessage", sender: indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "chatMessage") {
            let destinationVC = segue.destinationViewController as! ChatMessageViewController
            let indexPathRow = sender as! Int
            let user = (listUserTB.hidden == false) ? arrayListUser[indexPathRow] : arrayListUserResult[indexPathRow]
            destinationVC.nameChatUser = (user.objectForKey(kFirstname) as! String).uppercaseString
            destinationVC.userIdTarget = String(format:"%0.f", user[kId]!.doubleValue)
        }
    }
}

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.rangeOfString(find, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil
    }
}
