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
    let defaults = NSUserDefaults.standardUserDefaults()
    var tag:Tag?
    var userInfoSelect:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "INVITE"
        self.navigationItem.setHidesBackButton(true, animated: false)
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancel))
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kNext.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.next))
//        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        let nibName = UINib(nibName: "BookUserTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName, forCellReuseIdentifier: "BookUserTableViewCell")
        
        self.loadDataWithPrefix(kPMAPICOACH_LEADS)
        self.loadDataWithPrefix(kPMAPICOACH_CURRENT)
        self.loadDataWithPrefix(kPMAPICOACH_OLD)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(BookSessionSelectUserViewController.getListClientAgan), name: k_PM_REFRESH_CLIENTS, object: nil)
    }
    
    func getListClientAgan() {
        self.arrayCurrent.removeAll()
        self.offsetCurrent = 0
        self.arrayNew.removeAll()
        self.offsetNew = 0
        self.arrayOld.removeAll()
        self.offsetOld = 0
        self.loadDataWithPrefix(kPMAPICOACH_LEADS)
        self.loadDataWithPrefix(kPMAPICOACH_CURRENT)
        self.loadDataWithPrefix(kPMAPICOACH_OLD)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func loadDataWithPrefix(prefixAPI:String) {
        var prefix = kPMAPICOACHES
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(prefixAPI)
        if prefixAPI == kPMAPICOACH_LEADS {
            prefix.appendContentsOf("\(offsetNew)")
        } else if prefixAPI == kPMAPICOACH_CURRENT {
            prefix.appendContentsOf("\(offsetCurrent)")
        } else if prefixAPI == kPMAPICOACH_OLD {
            prefix.appendContentsOf("\(offsetOld)")
        }
        
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                if let arrayMessageT = JSON as? [NSDictionary] {
                    if prefixAPI == kPMAPICOACH_LEADS {
                        self.arrayNew += arrayMessageT
                        self.tbView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
                        
                        self.offsetNew = self.arrayNew.count
                        if arrayMessageT.count > 0 {
                            self.loadDataWithPrefix(kPMAPICOACH_LEADS)
                        }
                    } else if prefixAPI == kPMAPICOACH_CURRENT {
                        self.arrayCurrent += arrayMessageT
                        self.tbView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                        
                        self.offsetCurrent = self.arrayCurrent.count
                        if arrayMessageT.count > 0 {
                            self.loadDataWithPrefix(kPMAPICOACH_CURRENT)
                        }
                    } else if prefixAPI == kPMAPICOACH_OLD {
                        self.arrayOld += arrayMessageT
                        self.tbView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
                        
                        self.offsetOld = self.arrayOld.count
                        if arrayMessageT.count > 0 {
                            self.loadDataWithPrefix(kPMAPICOACH_OLD)
                        }
                    }
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func next() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrayNew.count
        } else if section == 1 {
            return arrayCurrent.count
        }
        return arrayOld.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.font = .pmmMonLight16()
        title.textColor = UIColor.lightGrayColor()
        
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

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookUserTableViewCell") as! BookUserTableViewCell
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
        var prefixUser = kPMAPIUSER
        prefixUser.appendContentsOf(targetUserId)
        Alamofire.request(.GET, prefixUser)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                cell.imgAvatar.image = UIImage(named: "display-empty.jpg")
                if let userInfo = JSON as? NSDictionary {
                    let name = userInfo.objectForKey(kFirstname) as! String
                    cell.lbName.text = name.uppercaseString
                    var link = kPMAPI
                    if !(JSON[kImageUrl] is NSNull) {
                        link.appendContentsOf(JSON[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight160)
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                cell.imgAvatar.image = imageRes
                        }
                    }
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }

        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var userInfo:NSDictionary!
        
        if indexPath.section == 0 {
            userInfo = arrayNew[indexPath.row]
        } else if indexPath.section == 1 {
            userInfo = arrayCurrent[indexPath.row]
        } else {
            userInfo = arrayOld[indexPath.row]
        }
        
        self.userInfoSelect = userInfo
        self.performSegueWithIdentifier("assignSessionToUser", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "assignSessionToUser" {
            let destination = segue.destinationViewController as! BookSessionToUserViewController
            destination.tag = self.tag
            destination.userInfoSelect = self.userInfoSelect
        }
    }

}
