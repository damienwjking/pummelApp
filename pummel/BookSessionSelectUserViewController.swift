//
//  BookSessionSelectUserViewController.swift
//  pummel
//
//  Created by Hao Nguyen Vu on 1/4/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit
import Alamofire

class BookSessionSelectUserViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tbView: UITableView!
    var arrayNew: [NSDictionary] = []
    var offsetNew: Int = 0
    var arrayCurrent: [NSDictionary] = []
    var offsetCurrent: Int = 0
    var arrayOld: [NSDictionary] = []
    var offsetOld: Int = 0
    let defaults = UserDefaults.standard
    var tag:TagModel?
    var userInfoSelect:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "INVITE"
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancel))
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kNext.uppercased(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.next))
//        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        
        let nibName = UINib(nibName: "BookUserTableViewCell", bundle:nil)
        self.tbView.register(nibName, forCellReuseIdentifier: "BookUserTableViewCell")
        
        self.loadDataWithPrefix(prefixAPI: kPMAPICOACH_LEADS)
        self.loadDataWithPrefix(prefixAPI: kPMAPICOACH_CURRENT)
        self.loadDataWithPrefix(prefixAPI: kPMAPICOACH_OLD)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector:  #selector(BookSessionSelectUserViewController.getListClientAgan), name: NSNotification.Name(rawValue: k_PM_REFRESH_CLIENTS), object: nil)
    }
    
    func getListClientAgan() {
        self.arrayCurrent.removeAll()
        self.offsetCurrent = 0
        self.arrayNew.removeAll()
        self.offsetNew = 0
        self.arrayOld.removeAll()
        self.offsetOld = 0
        self.loadDataWithPrefix(prefixAPI: kPMAPICOACH_LEADS)
        self.loadDataWithPrefix(prefixAPI: kPMAPICOACH_CURRENT)
        self.loadDataWithPrefix(prefixAPI: kPMAPICOACH_OLD)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadDataWithPrefix(prefixAPI:String) {
        var offset = offsetNew // kPMAPICOACH_LEADS
        if (prefixAPI == kPMAPICOACH_CURRENT) {
            offset = offsetCurrent
        } else if (prefixAPI == kPMAPICOACH_OLD) {
            offset = offsetOld
        }
        
        let currentUserID = PMHelper.getCurrentID()
        UserRouter.getLead(userID: currentUserID, type: prefixAPI, offset: offset) { (result, error) in
            if (error == nil) {
                let arrayMessageT =  result as! [NSDictionary]
                if prefixAPI == kPMAPICOACH_LEADS {
                    self.arrayNew += arrayMessageT
                    self.offsetNew = self.offsetNew + 10
                    
                    self.tbView.reloadSections(IndexSet(integer: 0), with: .none)
                } else if prefixAPI == kPMAPICOACH_CURRENT {
                    self.arrayCurrent += arrayMessageT
                    self.offsetCurrent = self.offsetCurrent + 10
                    
                    self.tbView.reloadSections(IndexSet(integer: 1), with: .none)
                } else if prefixAPI == kPMAPICOACH_OLD {
                    self.arrayOld += arrayMessageT
                    self.offsetOld = self.offsetOld + 10
                    
                    self.tbView.reloadSections(IndexSet(integer: 2), with: .none)
                }
                
                if arrayMessageT.count > 0 {
                    self.loadDataWithPrefix(prefixAPI: prefixAPI)
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
            }.fetchdata()
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func next() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrayNew.count
        } else if section == 1 {
            return arrayCurrent.count
        }
        return arrayOld.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.font = .pmmMonLight16()
        title.textColor = UIColor.lightGray
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = .pmmMonReg13()
        header.textLabel?.textColor = title.textColor
        
        var text = "NEW LEADS"
        if section == 1 {
            text = "EXISTING CLIENTS"
        } else if section == 2 {
            text = "PAST CLIENTS"
        }
        header.textLabel?.text = text
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookUserTableViewCell") as! BookUserTableViewCell
        var userInfo:NSDictionary!
        
        if indexPath.section == 0 {
            userInfo = arrayNew[indexPath.row]
        } else if indexPath.section == 1 {
            userInfo = arrayCurrent[indexPath.row]
        } else {
            userInfo = arrayOld[indexPath.row]
        }

        var targetUserId = ""
        if let val = userInfo["userId"] as? Int {
            targetUserId = "\(val)"
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
        var userInfo:NSDictionary!
        
        if indexPath.section == 0 {
            userInfo = arrayNew[indexPath.row]
        } else if indexPath.section == 1 {
            userInfo = arrayCurrent[indexPath.row]
        } else {
            userInfo = arrayOld[indexPath.row]
        }
        
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
