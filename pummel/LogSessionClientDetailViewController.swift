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
    
    @IBOutlet weak var tappedV: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var intensityPicker: UIPickerView!
    @IBOutlet weak var saveBT: UIButton!
    
    let tempTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        self.tempTextField.frame = CGRectZero
        self.view .addSubview(self.tempTextField)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LogSessionClientDetailViewController.tappedViewClicked))
        self.tappedV.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = kLogSession
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.title = " "
    }
    
    // MARK: Private function
    func tappedViewClicked() {
        self.tempTextField.resignFirstResponder()
        
        self.timePicker.hidden = true
        self.intensityPicker.hidden = true
        
        self.saveBT.hidden = false
        
        self.tappedV.hidden = true
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        }
        return 44
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
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 0 {
            // session
            
        } else if indexPath.row == 1 {
            // time
            self.timePicker.hidden = false
            
        } else if indexPath.row == 2 {
            // Distance
            self.tempTextField.becomeFirstResponder()
            
        } else if indexPath.row == 3 {
            // Intensity
            self.intensityPicker.hidden = false
            
        } else if indexPath.row == 4 {
            // Calories
            self.tempTextField.becomeFirstResponder()
        }
        
        self.saveBT.hidden = true
        self.tappedV.hidden = false
        
    }
}
