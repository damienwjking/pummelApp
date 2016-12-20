//
//  LogSessionClientViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation


class LogSessionClientViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = kLogSession
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.title = " "
    }
    
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogSessionTableViewCell") as! LogSessionTableViewCell
        
        if indexPath.row == 0 {
            cell.statusIMV.backgroundColor = UIColor.yellowColor();
            cell.LogTitleLB.text = "RUNNING"
        } else {
            cell.statusIMV.backgroundColor = UIColor.greenColor();
            cell.LogTitleLB.text = "SWIMMING"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("goLogSessionDetail", sender: nil)
    }
    
}
