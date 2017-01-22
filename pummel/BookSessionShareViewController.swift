//
//  BookSessionShareViewController.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class BookSessionShareViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, GroupLeadTableViewCellDelegate, LeadAddedTableViewCellDelegate {

    @IBOutlet weak var tbView: UITableView!
    var image:UIImage?
    var tag:Tag?
    var textToPost = ""
    var dateToPost = ""
    var userIdSelected = ""
    let defaults = NSUserDefaults.standardUserDefaults()
    var forceUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BookSessionViewController.cancel))
        
        // TODO: add right invite button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kInvite.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.invite))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        let nibName = UINib(nibName: "GroupLeadTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName, forCellReuseIdentifier: "GroupLeadTableViewCell")
        
        let nibName2 = UINib(nibName: "LeadAddedTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName2, forCellReuseIdentifier: "LeadAddedTableViewCell")
        self.tbView.allowsSelection = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kClients.uppercaseString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func invite() {
        self.performSegueWithIdentifier("inviteContactUser", sender: nil)
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupLeadTableViewCell") as! GroupLeadTableViewCell
        if indexPath.row == 0 {
            cell.titleHeader.text = "NEW LEADS"
            cell.typeGroup = TypeGroup.NewLead
        } else if indexPath.row == 1 {
            cell.titleHeader.text = "EXISTING CLIENTS"
            cell.typeGroup = TypeGroup.Current
        } else if indexPath.row == 2 {
            cell.titleHeader.text = "PAST CLIENTS"
            cell.typeGroup = TypeGroup.Old
        }
        cell.userIdSelected = self.userIdSelected
        cell.delegateGroupLeadTableViewCell = self
        if cell.arrayMessages.count <= 0 || self.forceUpdate == true {
            cell.getMessage()
        } else {
            cell.cv.reloadData()
        }
        return cell
    }
    
    func selectUserWithID(userId:String, typeGroup:Int) {
        if typeGroup == TypeGroup.Current.rawValue {
            self.showAlertMovetoOldAction(userId)
        } else {
            self.showAlertMovetoCurrentAction(userId,typeGroup: typeGroup)
        }
    }
    
    func removeUserWithID(userId:String) {
        userIdSelected = ""
        self.tbView.reloadData()
    }
    
    func showAlertMovetoOldAction(userID:String) {
        let clickMoveToOld = { (action:UIAlertAction!) -> Void in
            var prefix = kPMAPICOACHES
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPMAPICOACH_OLD)
            prefix.appendContentsOf("/")
            Alamofire.request(.PUT, prefix, parameters: [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, kUserIdRequest:userID])
                .responseJSON { response in
                    self.view.hideToastActivity()
                    if response.response?.statusCode == 200 {
                        self.forceUpdate = true
                        self.tbView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 0),NSIndexPath(forItem: 2, inSection: 0)], withRowAnimation: .None)
                        self.forceUpdate = false
                    }
            }
        }
        
        let clickShare = { (action:UIAlertAction!) -> Void in
            self.userIdSelected = userID
            self.tbView.reloadData()
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Move to Old", style: UIAlertActionStyle.Destructive, handler: clickMoveToOld))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func showAlertMovetoCurrentAction(userID:String,typeGroup:Int) {
        let clickMoveToCurrent = { (action:UIAlertAction!) -> Void in
            var prefix = kPMAPICOACHES
            prefix.appendContentsOf(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            prefix.appendContentsOf(kPMAPICOACH_CURRENT)
            prefix.appendContentsOf("/")
            print(self.defaults.objectForKey(k_PM_CURRENT_ID) as! String)
            Alamofire.request(.PUT, prefix, parameters: [kUserId:self.defaults.objectForKey(k_PM_CURRENT_ID) as! String, kUserIdRequest:userID])
                .responseJSON { response in
                    self.view.hideToastActivity()
                    if response.response?.statusCode == 200 {
                        self.forceUpdate = true
                        if typeGroup == TypeGroup.NewLead.rawValue {
                            self.tbView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0),NSIndexPath(forItem: 1, inSection: 0)], withRowAnimation: .None)
                        } else {
                            self.tbView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 0),NSIndexPath(forItem: 2, inSection: 0)], withRowAnimation: .None)
                        }
                        self.forceUpdate = false
                    }
            }
        }
        
        let clickShare = { (action:UIAlertAction!) -> Void in
            self.userIdSelected = userID
            self.tbView.reloadData()
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Move to Current", style: UIAlertActionStyle.Destructive, handler: clickMoveToCurrent))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true) { }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
