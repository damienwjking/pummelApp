//
//  BookSessionToUserViewController.swift
//  pummel
//
//  Created by Bear Daddy on 12/18/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Foundation


class BookSessionToUserViewController: UIViewController {
    
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var contentTF: UITextField!
    @IBOutlet weak var tapView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.backgroundColor = UIColor.whiteColor()
        dateTF.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(BookSessionToUserViewController.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        self.tapView.hidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapView))
        self.tapView.addGestureRecognizer(tap)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:kCancle.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kNext.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.next))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func didTapView() {
        self.contentTF.resignFirstResponder()
        self.dateTF.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = kBookSession
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = " "
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "MM/dd/YYYY"
        dateTF.text = timeFormatter.stringFromDate(sender.date)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.tapView.hidden = false
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tapView.hidden = true
    }
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func next() {
        self.performSegueWithIdentifier("gotoShare", sender: nil)
    }
}
