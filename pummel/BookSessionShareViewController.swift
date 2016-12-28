//
//  BookSessionShareViewController.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class BookSessionShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tbView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:kCancle.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kDone.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        let nibName = UINib(nibName: "GroupLeadTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName, forCellReuseIdentifier: "GroupLeadTableViewCell")
        
        let nibName2 = UINib(nibName: "LeadAddedTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName2, forCellReuseIdentifier: "LeadAddedTableViewCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kBookShare
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel() {
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func done() {
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        }
        return 140
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("LeadAddedTableViewCell") as! LeadAddedTableViewCell
            if cell.arrayMessages.count <= 0 {
                cell.getMessage()
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupLeadTableViewCell") as! GroupLeadTableViewCell
        if indexPath.row == 1 {
            cell.titleHeader.text = "NEW LEAD GROUP"
            cell.typeGroup = TypeGroup.NewLead
        } else if indexPath.row == 2 {
            cell.titleHeader.text = "CURENT GROUP"
            cell.typeGroup = TypeGroup.Current
        } else if indexPath.row == 3 {
            cell.titleHeader.text = "PAST CURENT GROUP"
            cell.typeGroup = TypeGroup.Old
        }
        if cell.arrayMessages.count <= 0 {
            cell.getMessage()
        }
        return cell
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
