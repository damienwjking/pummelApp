//
//  BookSessionViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation

class BookSessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tbView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        let nibName = UINib(nibName: "BookSessionTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName, forCellReuseIdentifier: "BookSessionTableViewCell")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:kCancle.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BookSessionViewController.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kBookSession
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = " "
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookSessionTableViewCell") as! BookSessionTableViewCell
        
        if indexPath.row == 0 {
            cell.statusIMV.backgroundColor = UIColor.yellowColor();
            cell.bookTitleLB.text = "RUNNING"
        } else {
            cell.statusIMV.backgroundColor = UIColor.greenColor();
            cell.bookTitleLB.text = "SWIMMING"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("assignSessionToUser", sender: nil)
    }
    
}

