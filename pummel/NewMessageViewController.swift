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
        self.navigationController!.navigationBar.isTranslucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.title = kNavNewMessage
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewMessageViewController.cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        self.toLB.font = .pmmMonReg13()
        self.toUserTF.attributedPlaceholder = NSAttributedString(string:"|",
            attributes:([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()]))
        self.listUserTB.delegate = self
        self.listUserTB.dataSource = self
        self.listUserTB.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.listUserTB.separatorStyle = UITableViewCellSeparatorStyle.none
        self.listUserSearchResultTB.delegate = self
        self.listUserSearchResultTB.dataSource = self
        self.listUserSearchResultTB.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.listUserSearchResultTB.separatorStyle = UITableViewCellSeparatorStyle.none
        self.toUserTF.delegate = self
        self.getListUser()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.text = ""
        self.arrayListUserResult.removeAll()
        self.listUserSearchResultTB.reloadData()
        self.listUserTB.isHidden = true
        self.listUserSearchResultTB.isHidden = false
        return true
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if (textField.text == "") {
            self.listUserTB.isHidden = false
            self.arrayListUserResult.removeAll()
            self.listUserSearchResultTB.reloadData()
            self.listUserSearchResultTB.isHidden = true
        } else {
            self.arrayListUserResult.removeAll()
            self.getListUserSearch()
            self.listUserTB.isHidden = true
            self.listUserSearchResultTB.isHidden = false
            
            
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getListUserSearch() {
        if (self.isStopLoadSearch == false) {
            self.isLoading = true
            var prefix = kPMAPISEARCHUSER
            let offset = self.arrayListUserResult.count
            prefix.append(String(offset))
            prefix.append("&character=")
//            prefix.append(self.toUserTF.text!)
            prefix.append(self.toUserTF.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            
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
                    print("Request failed with error: \(String(describing: error))")
                    }
            }
        }
    }
    
    func getListUser() {
        if (self.isStopLoad == false) {
            self.isLoadingSearch = true
            var prefix = kPMAPIUSER_OFFSET
            let offset = self.arrayListUser.count
            prefix.append(String(offset))
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
                    print("Request failed with error: \(String(describing: error))")
                    }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 70 // Ceiling this value fixes disappearing separators
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == listUserTB) {
            let cell = tableView.dequeueReusableCell(withIdentifier: kUserTableViewCell, for: indexPath) as! UserTableViewCell
            cell.tag = indexPath.row
            let user = arrayListUser[indexPath.row]
            var name = user.object(forKey: kFirstname) as! String
            name.append(" ")
            if !(user.object(forKey: kLastName) is NSNull) {
                name.append(user.object(forKey: kLastName) as! String)
            }
            cell.nameLB.text = name.uppercased()
            
            cell.avatarIMV.image = UIImage(named:"display-empty.jpg")
            
            let idSender = String(format:"%0.f",user.object(forKey: kId)!.doubleValue)
            ImageRouter.getUserAvatar(userID: idSender, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                    let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                    if visibleCell == true {
                        let imageRes = result as! UIImage
                        DispatchQueue.main.async(execute: {
                            cell.avatarIMV.image = imageRes
                        })
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kUserTableViewCell, for: indexPath) as! UserTableViewCell
            cell.tag = indexPath.row
            let user = arrayListUserResult[indexPath.row]
            var name = user.object(forKey: kFirstname) as! String
            name.append(" ")
            if !(user.object(forKey: kLastName) is NSNull) {
                name.append(user.object(forKey: kLastName) as! String)
            }
            cell.nameLB.text = name.uppercased()
            
            cell.avatarIMV.image = UIImage(named:"display-empty.jpg")
            
            let idSender = String(format:"%0.f",(user.object(forKey: kId)! as AnyObject).doubleValue)
            ImageRouter.getUserAvatar(userID: idSender, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                    let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                    if visibleCell == true {
                        let imageRes = result as! UIImage
                        DispatchQueue.main.async(execute: {
                            cell.avatarIMV.image = imageRes
                        })
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == listUserTB) ? arrayListUser.count : arrayListUserResult.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        performSegue(withIdentifier: "chatMessage", sender: indexPath.row)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "chatMessage") {
            let destinationVC = segue.destination as! ChatMessageViewController
            let indexPathRow = sender as! Int
            let user = (listUserTB.isHidden == false) ? arrayListUser[indexPathRow] : arrayListUserResult[indexPathRow]
            destinationVC.nameChatUser = (user.object(forKey: kFirstname) as! String).uppercased()
            destinationVC.userIdTarget = String(format:"%0.f", (user[kId]! as AnyObject).doubleValue)
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
