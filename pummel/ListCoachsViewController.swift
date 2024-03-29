//
//  ListCoachsViewController.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 1/7/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

class ListCoachsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, GroupLeadTableViewCellDelegate {
    
    @IBOutlet weak var tbView: UITableView!
    var image:UIImage?
    var tag:TagModel?
    var textToPost = ""
    var dateToPost = ""
    var userIdSelected = ""
    let defaults = UserDefaults.standard
    var forceUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancel))
        
        let nibName = UINib(nibName: "GroupLeadTableViewCell", bundle:nil)
        self.tbView.register(nibName, forCellReuseIdentifier: "GroupLeadTableViewCell")

        self.tbView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kCoaches
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupLeadTableViewCell") as! GroupLeadTableViewCell
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        
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
        
        cell.getNewUserLead()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func selectUserWithCoachInfo(coachInfo: NSDictionary) {
        // Maybe need conver ID from int to string
        let userID = coachInfo[kId] as! String
        
        PMHelper.showCoachOrUserView(userID: userID)
    }
    
    
    func showAlertMovetoOldAction(userID:String) {
        let clickMoveToOld = { (action:UIAlertAction!) -> Void in
            self.view.makeToastActivity()
            
            UserRouter.setOldLead(requestID: userID, completed: { (result, error) in
                self.view.hideToastActivity()
                
                let isChangeSuccess = result as! Bool
                if (isChangeSuccess) {
                    self.forceUpdate = true
                    
//                    self.tbView.reloadRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .fade)
                    self.tbView.reloadData()
                    
                    self.forceUpdate = false
                }
                
            }).fetchdata()
        }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Move to Old", style: UIAlertActionStyle.destructive, handler: clickMoveToOld))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    
    func showAlertMovetoCurrentAction(userID:String,typeGroup:Int) {
        let clickMoveToCurrent = { (action:UIAlertAction!) -> Void in
            self.view.makeToastActivity()
            
            UserRouter.setCurrentLead(requestID: userID, completed: { (result, error) in
                self.view.hideToastActivity()
                
                let isChangeSuccess = result as! Bool
                if (isChangeSuccess) {
                    self.forceUpdate = true
                    
                    self.tbView.reloadData()
                    
                    self.forceUpdate = false
                }
                
            }).fetchdata()
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Move to Current", style: UIAlertActionStyle.destructive, handler: clickMoveToCurrent))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alertController, animated: true) { }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

