//
//  LogSessionClientDetailViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation

class LogSessionClientDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("LogSessionTableViewCell") as! LogSessionTableViewCell
            
            cell.statusIMV.image = UIImage(named: "sessionRunning")
            cell.LogTitleLB.text = "RUNNING"
            
            return cell
        } else if indexPath.row == 1 {
            let cell =  tableView.dequeueReusableCellWithIdentifier("kTimeTableViewCell")
            
            
            return cell!
        } else if indexPath.row == 2 {
            let cell =  tableView.dequeueReusableCellWithIdentifier("kDistanceTableViewCell")
            
            
            return cell!
        } else if indexPath.row == 3 {
            let cell =  tableView.dequeueReusableCellWithIdentifier("kIntensityTableViewCell")
            
            
            return cell!
        } else if indexPath.row == 4 {
            let cell =  tableView.dequeueReusableCellWithIdentifier("kCaloriesTableViewCell")
            
            
            return cell!
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
