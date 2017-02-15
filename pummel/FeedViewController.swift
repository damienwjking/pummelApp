//
//  FeedViewController.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
import RSKGrowingTextView

class FeedViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, RSKGrowingTextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var feedDetail : NSDictionary!
    var userFeed : NSDictionary!
   
    @IBOutlet var textBox: RSKGrowingTextView!
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var cursorView: UIView!
    @IBOutlet var leftMarginLeftChatCT: NSLayoutConstraint!
    @IBOutlet var avatarTextBox: UIImageView!
    var listComment : [NSDictionary] = []
    var stopGetListComment : Bool = false
    var offset: Int = 0
    var fromPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FeedViewController.cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], forState: .Normal)
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.title = kNavPost
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 77
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if let userDic = feedDetail[kUser] as? NSDictionary {
            userFeed = userDic
        }
        self.textBox.font = .pmmMonReg13()
        self.textBox.delegate = self
    
        self.navigationItem.hidesBackButton = true;
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(FeedViewController.handleTap(_:)))
        self.tableView.addGestureRecognizer(recognizer)
        avatarTextBox.layer.cornerRadius = 20
        avatarTextBox.clipsToBounds = true
        avatarTextBox.hidden = true
        self.getImageAvatarTextBox()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.listComment.removeAll()
        self.stopGetListComment = false
        self.offset = 0
        self.getListComment()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let scrollPoint = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height);
        self.tableView.setContentOffset(scrollPoint, animated: true);
        self.tableView.reloadData()
    }
    
    func getListComment() {
        if (stopGetListComment == false) {
            var commentLink  = kPMAPI_POST
            let postId = String(format:"%0.f", feedDetail[kId]!.doubleValue)
            commentLink.appendContentsOf(postId)
            commentLink.appendContentsOf(kPM_PATH_COMMENT_OFFSET)
            commentLink.appendContentsOf(String(offset))
            Alamofire.request(.GET, commentLink)
                .responseJSON { response in
                    print (response.result.value)
                    if response.response?.statusCode == 200 {
                        let list = response.result.value as! [NSDictionary]
                        if (list.count > 0) {
                            self.listComment = self.listComment + list
                            self.offset += 10
                            self.getListComment()
                            self.tableView.reloadData()
                        } else {
                            self.stopGetListComment = true
                        }
                    } else {
                        self.stopGetListComment = true
                    }
            }
        }
    }
    
    func getLastComment() {
        var commentLink  = kPMAPI_POST
        let postId = String(format:"%0.f", feedDetail[kId]!.doubleValue)
        commentLink.appendContentsOf(postId)
        commentLink.appendContentsOf(kPM_PATH_COMMENT_LIMIT)
        commentLink.appendContentsOf("1")
        Alamofire.request(.GET, commentLink)
            .responseJSON { response in
                print (response.result.value)
                if response.response?.statusCode == 200 {
                    let list = response.result.value as! [NSDictionary]
                    if (list.count > 0) {
                        self.listComment.insert(list[0], atIndex: 0)
                        self.offset += 10
                        self.getListComment()
                        self.tableView.reloadData()
                    }
                }
        }
    }
    
    @IBAction func goNewPost() {
        self.textBox.resignFirstResponder()
        self.performSegueWithIdentifier("goNewPost", sender: nil)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listComment.count + 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row ==  0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kFeedFirstPartTableViewCell, forIndexPath: indexPath) as! FeedFirstPartTableViewCell
            if userFeed == nil {
                return cell
            }
            let firstname = userFeed[kFirstname] as? String
            cell.nameLB.text = firstname?.uppercaseString
            
            if !(userFeed[kImageUrl] is NSNull) {
                let imageLink = userFeed[kImageUrl] as! String
                var photoLink = kPMAPI
                photoLink.appendContentsOf(imageLink)
                photoLink.appendContentsOf(widthHeight120)
                if (NSCache.sharedInstance.objectForKey(photoLink) != nil) {
                    let imageRes = NSCache.sharedInstance.objectForKey(photoLink) as! UIImage
                    cell.avatarBT.setBackgroundImage(imageRes, forState: .Normal)
                } else {
                    Alamofire.request(.GET, photoLink)
                        .responseImage { response in
                            if (response.response?.statusCode == 200) {
                                let imageRes = response.result.value! as UIImage
                                cell.avatarBT.setBackgroundImage(imageRes, forState: .Normal)
                                NSCache.sharedInstance.setObject(imageRes, forKey: photoLink)
                            }
                    }
                }
            } else {
                cell.avatarBT.setBackgroundImage(UIImage(named: "display-empty.jpg"), forState: .Normal)
            }
            
            let timeAgo = feedDetail[kCreateAt] as! String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = kFullDateFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            let dateFromString : NSDate = dateFormatter.dateFromString(timeAgo)!
            cell.timeLB.text = self.timeAgoSinceDate(dateFromString)
            
            cell.imageContentIMV.image = nil
            if !(feedDetail[kImageUrl] is NSNull) {
                let imageContentLink = feedDetail[kImageUrl] as! String
                var photoContentLink = kPMAPI
                photoContentLink.appendContentsOf(imageContentLink)
                let postfixContent = widthEqual.stringByAppendingString(String(self.view.frame.size.width*2)).stringByAppendingString(heighEqual).stringByAppendingString(String(self.view.frame.size.width*2))
                photoContentLink.appendContentsOf(postfixContent)
                if (NSCache.sharedInstance.objectForKey(photoContentLink) != nil) {
                    let imageRes = NSCache.sharedInstance.objectForKey(photoContentLink) as! UIImage
                    cell.imageContentIMV.image = imageRes
                } else {
                    Alamofire.request(.GET, photoContentLink)
                        .responseImage { response in
                            if (response.response?.statusCode == 200) {
                                let imageRes = response.result.value! as UIImage
                                cell.imageContentIMV.image = imageRes
                                NSCache.sharedInstance.setObject(imageRes, forKey: photoContentLink)
                            }
                    }
                }
            }
            
            cell.shareBT.tag = indexPath.row
            cell.shareBT.addTarget(self, action: #selector(FeaturedViewController.showListContext(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeBT.addTarget(self, action: #selector(FeedViewController.likeThisPost(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            //Get Likes status
            let coachId = String(format:"%0.f", feedDetail[kId]!.doubleValue)
            var likeLink  = kPMAPI_LIKE
            likeLink.appendContentsOf(coachId)
            likeLink.appendContentsOf(kPM_PATH_LIKE)
            Alamofire.request(.GET, likeLink)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        let likeJson = response.result.value as! NSDictionary
                        let rows = likeJson[kRows] as! [NSDictionary]
                        let defaults = NSUserDefaults.standardUserDefaults()
                        let currentId = defaults.objectForKey(k_PM_CURRENT_ID) as! String
                        var like = false
                        for row in rows {
                            if (String(format:"%0.f", row[kUserId]!.doubleValue) == currentId){
                                cell.likeBT.setBackgroundImage(UIImage(named: "liked.png"), forState: .Normal)
                                cell.likeBT.userInteractionEnabled = false
                                like = true
                                break
                            }
                        }
                        if (like == false) {
                             cell.likeBT.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
                        }
                    } else {
                    }
            }

            return cell
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kFeedSecondPartTableViewCell, forIndexPath: indexPath) as! FeedSecondPartTableViewCell
            //Get Likes
            let coachId = String(format:"%0.f", feedDetail[kId]!.doubleValue)
            var likeLink  = kPMAPI_LIKE
            likeLink.appendContentsOf(coachId)
            likeLink.appendContentsOf(kPM_PATH_LIKE)
            Alamofire.request(.GET, likeLink)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        let likeJson = response.result.value as! NSDictionary
                        var likeNumber = String(format:"%0.f", likeJson[kCount]!.doubleValue)
                        likeNumber.appendContentsOf(" likes")
                        cell.likeLB.text = likeNumber
                    } else {
                    }
            }
            return cell
        }else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCellWithIdentifier("FeedThirdPartTableViewCell", forIndexPath: indexPath) as! FeedThirdPartTableViewCell
            if userFeed == nil {
                return cell
            }
            cell.userCommentLB.text = (userFeed[kFirstname] as! String).uppercaseString
            cell.contentCommentLB.text = feedDetail[kText] as? String
            cell.contentCommentConstrant.constant = (cell.contentCommentLB.text?.heightWithConstrainedWidth(cell.contentCommentLB.frame.width, font: cell.contentCommentLB.font))! + 20
            return cell
        } else {
            
            let comment = self.listComment[(self.listComment.count - 1) - (indexPath.row-3)]
            if (comment[kImageUrl] is NSNull) {
                let cell = tableView.dequeueReusableCellWithIdentifier(kFeedThirdPartTableViewCell, forIndexPath: indexPath) as! FeedThirdPartTableViewCell
                let text = comment[kText] as! String
                var userComment = kPMAPIUSER
                let userId = String(format:"%0.f", comment[kUserId]!.doubleValue)
                userComment.appendContentsOf(userId)
                Alamofire.request(.GET, userComment)
                    .responseJSON { response in
                        if response.response?.statusCode == 200 {
                            dispatch_async(dispatch_get_main_queue(),{
                                let userCommentInfo = response.result.value as! NSDictionary
                                let userName = userCommentInfo[kFirstname] as! String
                                cell.userCommentLB.text = userName.uppercaseString
                                cell.contentCommentLB.text = text
                                cell.contentCommentConstrant.constant = (cell.contentCommentLB.text?.heightWithConstrainedWidth(cell.contentCommentLB.frame.width, font: cell.contentCommentLB.font))! + 20
                            })
                        }
                }
                
                return cell

            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(kFeedFourthPartTableViewCell, forIndexPath: indexPath) as! FeedFourthPartTableViewCell
                let text = comment[kText] as! String
                var userComment = kPMAPIUSER
                let userId = String(format:"%0.f", comment[kUserId]!.doubleValue)
                userComment.appendContentsOf(userId)
                Alamofire.request(.GET, userComment)
                    .responseJSON { response in
                        if response.response?.statusCode == 200 {
                            dispatch_async(dispatch_get_main_queue(),{
                                let userCommentInfo = response.result.value as! NSDictionary
                                let userName = userCommentInfo[kFirstname] as! String
                                cell.userCommentLB.text = userName.uppercaseString
                                cell.contentCommentLB.text = text
                                cell.contentCommentConstrant.constant = (cell.contentCommentLB.text?.heightWithConstrainedWidth(cell.contentCommentLB.frame.width, font: cell.contentCommentLB.font))! + 20
                            })
                        }
                }
                
                var link = kPMAPI
                link.appendContentsOf(comment[kImageUrl] as! String)
                link.appendContentsOf(widthEqual)
                link.appendContentsOf(String(self.view.frame.width*2))
                link.appendContentsOf(heighEqual)
                link.appendContentsOf(String(self.view.frame.width*2))
                Alamofire.request(.GET, link)
                    .responseImage { response in
                        let imageRes = response.result.value! as UIImage
                        cell.contentCommentImageView.image = imageRes
                }

                
                return cell
            }
        }
    }
    
    func likeThisPost(sender: UIButton!) {
        //Post Likes
        var likeLink  = kPMAPI_LIKE
        likeLink.appendContentsOf(String(format:"%0.f", feedDetail[kId]!.doubleValue))
        likeLink.appendContentsOf(kPM_PATH_LIKE)
        Alamofire.request(.POST, likeLink, parameters: [kPostId: String(format:"%0.f", feedDetail[kId]!.doubleValue)])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                } else {
                    print("cant like")
                }
        }
    }
    
    func goProfile(sender: UIButton) {
        
        self.performSegueWithIdentifier(kGoProfile, sender:sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == kGoProfile) {
            let destination = segue.destinationViewController as! CoachProfileViewController
            destination.coachDetail = userFeed
            destination.coachTotalDetail = feedDetail
            destination.isFromFeed = true
        } else if (segue.identifier == "goNewPost") {
            let destination = segue.destinationViewController as! NewCommentImageViewController
            destination.postId = String(format:"%0.f", feedDetail[kId]!.doubleValue)
        }
        
    }
    
    func showListContext(sender: UIButton) {
//        let selectDeleted = { (action:UIAlertAction!) -> Void in
//        }
        
        let share = { (action:UIAlertAction!) -> Void in
            self.sharePummel()
        }
        
        let selectCancle = { (action:UIAlertAction!) -> Void in
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        alertController.addAction(UIAlertAction(title: KReport, style: UIAlertActionStyle.Destructive, handler: selectDeleted))
        alertController.addAction(UIAlertAction(title: kShare, style: UIAlertActionStyle.Destructive, handler: share))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.Cancel, handler: selectCancle))
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func sharePummel() {
        self.shareTextImageAndURL(pummelSlogan, sharingImage: UIImage(named: "shareLogo.png"), sharingURL: NSURL.init(string: kPM))
    }
    
    func shareTextImageAndURL(sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func getImageAvatarTextBox() {
        var prefix = kPMAPIUSER
        let defaults = NSUserDefaults.standardUserDefaults()
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userDetail = JSON as! NSDictionary
                if !(userDetail[kImageUrl] is NSNull) {
                    var link = kPMAPI
                    link.appendContentsOf(userDetail[kImageUrl] as! String)
                    link.appendContentsOf(widthHeight120)
                    if (NSCache.sharedInstance.objectForKey(link) != nil) {
                        let imageRes = NSCache.sharedInstance.objectForKey(link) as! UIImage
                        self.avatarTextBox.image = imageRes
                    } else {
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                self.avatarTextBox.image = imageRes
                                NSCache.sharedInstance.setObject(imageRes, forKey: link)
                        }
                    }
                } else {
                    self.avatarTextBox.image = UIImage(named: "display-empty.jpg")
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
        self.tableView.setContentOffset(bottomOffset, animated: false)
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 64 - keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
            self.view.frame.origin.y = 64
        if (self.textBox.text == "") {
            self.cursorView.hidden = false
            self.avatarTextBox.hidden = true
            self.leftMarginLeftChatCT.constant = 15
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.addComment()
        return true
    }
    
    @IBAction func addComment() {
        let postId = String(format:"%0.f",feedDetail[kId]!.doubleValue)
        let text = self.textBox.text
        self.cursorView.userInteractionEnabled = true
        var link = kPMAPI
        link.appendContentsOf("/api/posts/")
        link.appendContentsOf(String(postId))
        link.appendContentsOf("/comments")
        Alamofire.request(.POST, link, parameters: [kPostId:postId, kText:text])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.textBox.text = ""
                    self.cursorView.userInteractionEnabled = false
                    self.getLastComment()
                }else {
                    self.cursorView.userInteractionEnabled = false
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
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.cursorView.hidden = true
        self.avatarTextBox.hidden = false
        self.leftMarginLeftChatCT.constant = 40
    }
    
    func timeAgoSinceDate(date:NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .Month, .Year]
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options:NSCalendarOptions.MatchPreviousTimePreservingSmallerUnits)
        
        if (components.year >= 2) {
            return "\(components.year)y"
        } else if (components.year >= 1){
            return "1y"
        } else if (components.month >= 2) {
            return "\(components.month)m"
        } else if (components.month >= 1){
            return "1m"
        } else if (components.day >= 2) {
            return "\(components.day)d"
        } else if (components.day >= 1){
            return "1d"
        } else if (components.hour >= 2) {
            return "\(components.hour)hr"
        } else if (components.hour >= 1){
            return "1hr"
        } else if (components.minute >= 2) {
            return "\(components.minute)m"
        } else if (components.minute >= 1){
            return "1m"
        } else if (components.second >= 3) {
            return "\(components.second)s"
        } else {
            return "Just now"
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.frame.origin.y = 64
        self.cursorView.hidden = false
        self.avatarTextBox.hidden = true
        self.leftMarginLeftChatCT.constant = 15
        self.textBox.resignFirstResponder()
    }
    
    func cancel() {
        if self.fromPhoto == true {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}
