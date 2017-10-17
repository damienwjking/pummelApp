//
//  LogSessionSelectUserViewController.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 1/5/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class LogSessionSelectUserViewController: BaseViewController {
    
    @IBOutlet weak var tbView: UITableView!
    var activeUserList: [NSDictionary] = []
    var activeUserOffset: Int = 0
    
    var tag:TagModel?
    let defaults = UserDefaults.standard
    var userInfoSelect:NSDictionary!
    
    var isStopLoadActiveUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "INVITE"
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.leftBarButtonClicked))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kSkip.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.rightBarButtonClicked))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        
        let nibName = UINib(nibName: "BookUserTableViewCell", bundle:nil)
        self.tbView.register(nibName, forCellReuseIdentifier: "BookUserTableViewCell")
        
        self.getActiveUser()
    }
    
    func getActiveUser() {
        if (self.isStopLoadActiveUser == false) {
            let currentUserID = PMHelper.getCurrentID()
            UserRouter.getActiveUser(userID: currentUserID, offset: self.activeUserOffset) { (result, error) in
                if (error == nil) {
                    let dataInfo = result as! NSDictionary
                    
                    let activeUserList = dataInfo["list"] as! [NSDictionary]
                    
                    if activeUserList.count == 0 {
                        self.isStopLoadActiveUser = true
                    } else {
                        self.activeUserList += activeUserList
                        self.activeUserOffset = self.activeUserOffset + 20
                        
                        self.tbView.reloadData()
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
                }.fetchdata()
        }
    }
    
    func leftBarButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func rightBarButtonClicked() {
        self.userInfoSelect = nil
        self.performSegue(withIdentifier: "goLogSessionDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goLogSessionDetail" {
            let destination = segue.destination as! LogSessionClientDetailViewController
            destination.tag = self.tag!
            destination.userInfoSelect = self.userInfoSelect
        }
    }
}

// MARK: - UITableViewDelegate
extension LogSessionSelectUserViewController: UITableViewDelegate, UITableViewDataSource {func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return activeUserList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookUserTableViewCell") as! BookUserTableViewCell
        let userInfo = activeUserList[indexPath.row]
        
        var targetUserId = ""
        if let val = userInfo["userId"] as? Int {
            targetUserId = "\(val)"
        }
        
        if (indexPath.row == self.activeUserList.count - 2) {
            self.getActiveUser()
        }
        
        cell.lbName.text = "..."
        cell.imgAvatar.image = UIImage(named: "display-empty.jpg")
        
        // Get name and image
        UserRouter.getUserInfo(userID: targetUserId) { (result, error) in
            if (error == nil) {
                let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                if visibleCell == true {
                    if let userInfo = result as? NSDictionary {
                        let name = userInfo.object(forKey: kFirstname) as! String
                        cell.lbName.text = name.uppercased()
                        
                        let imageURLString = userInfo[kImageUrl] as? String
                        
                        if (imageURLString?.isEmpty == false) {
                            ImageVideoRouter.getImage(imageURLString: imageURLString!, sizeString: widthHeight160, completed: { (result, error) in
                                let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath)
                                if visibleCell == true {
                                    if (error == nil) {
                                        let imageRes = result as! UIImage
                                        cell.imgAvatar.image = imageRes
                                    } else {
                                        print("Request failed with error: \(String(describing: error))")
                                    }
                                }
                            }).fetchdata()
                        }
                        
                        
                    }
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
        
        // Check coach
        UserRouter.checkCoachOfUser(userID: targetUserId) { (result, error) in
            let isCoach = result as! Bool
            
            if (isCoach) {
                cell.imgAvatar.layer.borderWidth = 2
                cell.imgAvatar.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
            }
            }.fetchdata()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = activeUserList[indexPath.row]
        
        self.userInfoSelect = userInfo
        self.performSegue(withIdentifier: "goLogSessionDetail", sender: nil)
        self.tbView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
}
