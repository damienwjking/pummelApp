//
//  ListCoachsViewController.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 1/7/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

import UIKit
import Alamofire

class ListCoachsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupLeadTableViewCellDelegate {
    
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
        
        let nibName = UINib(nibName: "GroupLeadTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName, forCellReuseIdentifier: "GroupLeadTableViewCell")

        self.tbView.allowsSelection = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kCoaches
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            cell.titleHeader.text = "JUST CONNECTED"
            cell.typeGroup = TypeGroup.CoachJustConnected
        } else if indexPath.row == 1 {
            cell.titleHeader.text = "CURRENT COACHES"
            cell.typeGroup = TypeGroup.CoachCurrent
        } else if indexPath.row == 2 {
            cell.titleHeader.text = "PAST COACHES"
            cell.typeGroup = TypeGroup.CoachOld
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
    
    func selectUserWithID(coachInfo:NSDictionary) {
        self.performSegueWithIdentifier(kGoProfile, sender:coachInfo)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == kGoProfile) {
            let destination = segue.destinationViewController as! CoachProfileViewController
            let currentFeedDetail = sender as! NSDictionary
            destination.coachDetail = currentFeedDetail
            destination.isFromListCoaches = true
        }
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

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Move to Old", style: UIAlertActionStyle.Default, handler: clickMoveToOld))
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
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Move to Current", style: UIAlertActionStyle.Default, handler: clickMoveToCurrent))
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

