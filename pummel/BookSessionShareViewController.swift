//
//  BookSessionShareViewController.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class BookSessionShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupLeadTableViewCellDelegate, LeadAddedTableViewCellDelegate {

    @IBOutlet weak var tbView: UITableView!
    var image:UIImage?
    var tag:Tag?
    var textToPost = ""
    var dateToPost = ""
    var userIdSelected = ""
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:kCancle.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:kSave.uppercaseString, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.done))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        let nibName = UINib(nibName: "GroupLeadTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName, forCellReuseIdentifier: "GroupLeadTableViewCell")
        
        let nibName2 = UINib(nibName: "LeadAddedTableViewCell", bundle:nil)
        self.tbView.registerNib(nibName2, forCellReuseIdentifier: "LeadAddedTableViewCell")
        self.tbView.allowsSelection = false
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
        self.view.makeToastActivity(message: "Saving")
        var prefix = kPMAPICOACHES
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPMAPICOACH_BOOK)

        var imageData : NSData!
        let type : String!
        let filename : String!
        if self.image != nil {
            imageData = UIImageJPEGRepresentation(self.image!, 0.2)
        }
        
        type = imageJpeg
        filename = jpgeFile
        let textPost = textToPost
        var parameters = [String:AnyObject]()
        var tagname = ""
        tagname = (self.tag?.name?.uppercaseString)!
        parameters = [kUserId:defaults.objectForKey(k_PM_CURRENT_ID) as! String, kText: textPost, kUserIdTarget:userIdSelected, kType:"#\(tagname)", "datetime": dateToPost]
        Alamofire.upload(
            .POST,
            prefix,
            multipartFormData: { multipartFormData in
                if imageData != nil {
                    multipartFormData.appendBodyPart(data: imageData, name: "file",
                        fileName:filename, mimeType:type)
                }
                for (key, value) in parameters {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
            },
            encodingCompletion: { encodingResult in
                self.view.hideToastActivity()
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                    }
                    upload.validate()
                    upload.responseJSON { response in
                       let json = response.result.value as! NSDictionary
                        print(json)
                        if response.result.error != nil {
                            let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .Alert)
                            let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                                // ...
                            }
                            alertController.addAction(OKAction)
                            self.presentViewController(alertController, animated: true) {
                                // ...
                            }
                        } else {
                            self.navigationController?.popToRootViewControllerAnimated(false)
                        }
                    }
                    
                case .Failure(let encodingError):
                    let alertController = UIAlertController(title: pmmNotice, message: pleaseDoItAgain, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: kOk, style: .Default) { (action) in
                        // ...
                    }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true) {
                        // ...
                    }
                }
            }
        )
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
            cell.idUser = self.userIdSelected
            cell.cv.reloadData()
            cell.delegateLeadAddedTableViewCell = self
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
        cell.userIdSelected = self.userIdSelected
        cell.delegateGroupLeadTableViewCell = self
        if cell.arrayMessages.count <= 0 {
            cell.getMessage()
        } else {
            cell.cv.reloadData()
        }
        return cell
    }
    
    func selectUserWithID(userId:String) {
        
        if userIdSelected == userId {
            return
        }
        
        userIdSelected = userId
        self.tbView.reloadData()
    }
    
    func removeUserWithID(userId:String) {
        userIdSelected = ""
        self.tbView.reloadData()
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
