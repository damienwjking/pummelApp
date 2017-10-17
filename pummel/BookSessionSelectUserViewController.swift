//
//  BookSessionSelectUserViewController.swift
//  pummel
//
//  Created by Hao Nguyen Vu on 1/4/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class BookSessionSelectUserViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tbView: UITableView!
    var activeUserList: [NSDictionary] = []
    var activeUserOffset = 0
    let defaults = UserDefaults.standard
    var tag:TagModel?
    var userInfoSelect:NSDictionary!
    
    var isStopLoadActiveUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "INVITE"
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancel))
        
        let nibName = UINib(nibName: "BookUserTableViewCell", bundle:nil)
        self.tbView.register(nibName, forCellReuseIdentifier: "BookUserTableViewCell")
        
        self.getActiveUser()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector:  #selector(self.getListClientAgan), name: NSNotification.Name(rawValue: k_PM_REFRESH_CLIENTS), object: nil)
    }
    
    func getListClientAgan() {
        self.activeUserList.removeAll()
        self.activeUserOffset = 0
        self.isStopLoadActiveUser = false
        
        self.getActiveUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func next() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activeUserList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookUserTableViewCell") as! BookUserTableViewCell
        let userInfo = self.activeUserList[indexPath.row]

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
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = self.activeUserList[indexPath.row]
        
        self.userInfoSelect = userInfo
        self.performSegue(withIdentifier: "assignSessionToUser", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "assignSessionToUser" {
            let destination = segue.destination as! BookSessionToUserViewController
            destination.tag = self.tag
            destination.userInfoSelect = self.userInfoSelect
        }
    }

}
