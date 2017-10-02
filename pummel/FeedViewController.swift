//
//  FeedViewController.swift
//  pummel
//
//  Created by Bear Daddy on 9/7/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire
//import RSKGrowingTextView

class FeedViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, RSKGrowingTextViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var feedDetail : NSDictionary!
    var userFeed : NSDictionary!
   
    @IBOutlet var textBox: RSKGrowingTextView!
    @IBOutlet weak var postButton: UIButton!
    
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
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancel))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont.pmmMonReg13(), NSForegroundColorAttributeName:UIColor.pmmBrightOrangeColor()], for: .normal)
        self.navigationController!.navigationBar.isTranslucent = false;
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.pmmMonReg13()]
        self.navigationItem.title = kNavPost
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 77
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if let userDic = feedDetail[kUser] as? NSDictionary {
            userFeed = userDic
        }
        self.textBox.font = UIFont.pmmMonReg13()
        self.textBox.delegate = self
    
        self.navigationItem.hidesBackButton = true;
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(FeedViewController.handleTap(_:)))
        self.tableView.addGestureRecognizer(recognizer)
        avatarTextBox.layer.cornerRadius = 20
        avatarTextBox.clipsToBounds = true
        avatarTextBox.isHidden = true
        self.getImageAvatarTextBox()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.listComment.removeAll()
        self.stopGetListComment = false
        self.offset = 0
        self.getListComment()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated: animated)
        
        let scrollPoint = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height);
        self.tableView.setContentOffset(scrollPoint, animated: true);
        self.tableView.reloadData()
    }
    
    func getListComment() {
        if (stopGetListComment == false) {
            var commentLink  = kPMAPI_POST
            let postId = String(format:"%0.f", (feedDetail[kId]! as AnyObject).doubleValue)
            commentLink.append(postId)
            commentLink.append(kPM_PATH_COMMENT_OFFSET)
            commentLink.append(String(offset))
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
        let postId = String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)
        commentLink.append(postId)
        commentLink.append(kPM_PATH_COMMENT_LIMIT)
        commentLink.append("1")
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
        self.performSegue(withIdentifier: "goNewPost", sender: nil)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listComment.count + 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row ==  0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedFirstPartTableViewCell, for: indexPath) as! FeedFirstPartTableViewCell
            if userFeed == nil {
                return cell
            }
            let firstname = userFeed[kFirstname] as? String
            cell.nameLB.text = firstname?.uppercased()
            
            if (userFeed[kImageUrl] is NSNull == false) {
                let imageLink = userFeed[kImageUrl] as! String
                
                ImageRouter.getImage(imageURLString: imageLink, sizeString: widthHeight120, completed: { (result, error) in
                    if (error == nil) {
                        let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath as NSIndexPath)
                        if visibleCell == true {
                            let imageRes = result as! UIImage
                            cell.avatarBT.setBackgroundImage(imageRes, for: .normal)
                        }
                    } else {
                        print("Request failed with error: \(error)")
                    }
                }).fetchdata()
            } else {
                cell.avatarBT.setBackgroundImage(UIImage(named: "display-empty.jpg"), for: .normal)
            }
            
            let timeAgo = feedDetail[kCreateAt] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = kFullDateFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            let dateFromString : NSDate = dateFormatter.date(from: timeAgo)! as NSDate
            cell.timeLB.text = self.timeAgoSinceDate(date: dateFromString)
            
            cell.imageContentIMV.image = nil
            if !(feedDetail[kImageUrl] is NSNull) {
                let imageContentLink = feedDetail[kImageUrl] as! String
                var photoContentLink = kPMAPI
                photoContentLink.append(imageContentLink)
                let postfixContent = widthHeightScreenx2
                photoContentLink.append(postfixContent)
                if (NSCache<AnyObject, AnyObject>.sharedInstance.object(forKey: photoContentLink) != nil) {
                    let imageRes = NSCache<AnyObject, AnyObject>.sharedInstance.object(forKey: photoContentLink) as! UIImage
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
            cell.shareBT.addTarget(self, action: #selector(self.showListContext(_:)), for: .touchUpInside)
            cell.likeBT.addTarget(self, action: #selector(self.likeThisPost(_:)), for: .touchUpInside)
            //Get Likes status
            let currentID = String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)
            var likeLink  = kPMAPI_LIKE
            likeLink.append(currentID)
            likeLink.append(kPM_PATH_LIKE)
            Alamofire.request(.GET, likeLink)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        let likeJson = response.result.value as! NSDictionary
                        let rows = likeJson[kRows] as! [NSDictionary]
                        let currentId = PMHelper.getCurrentID()
                        
                        var like = false
                        for row in rows {
                            if (String(format:"%0.f", row[kUserId]!.doubleValue) == currentId){
                                cell.likeBT.setBackgroundImage(UIImage(named: "liked.png"), for: .normal)
                                cell.likeBT.isUserInteractionEnabled = false
                                like = true
                                break
                            }
                        }
                        if (like == false) {
                             cell.likeBT.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
                        }
                    } else {
                    }
            }

            // Check Coach
            cell.isUserInteractionEnabled = false
            let userID = String(format:"%0.f", (feedDetail[kUserId]! as AnyObject).doubleValue)
            var coachLink  = kPMAPICOACH
            coachLink.append(userID)
            
            cell.avatarBT.layer.borderWidth = 0
            cell.coachLB.text = ""
            cell.coachLBTraillingConstraint.constant = 0
            Alamofire.request(.GET, coachLink)
                .responseJSON { response in
                    cell.isUserInteractionEnabled = true
                    
                    if response.response?.statusCode == 200 {
                        cell.avatarBT.layer.borderWidth = 2
                        
                        cell.coachLBTraillingConstraint.constant = 5
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.coachLB.layoutIfNeeded()
                            cell.coachLB.text = kCoach.uppercased()
                        })
                    }
            }
            
            return cell
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedSecondPartTableViewCell, for: indexPath) as! FeedSecondPartTableViewCell
            //Get Likes
            let currentID = String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)
            var likeLink  = kPMAPI_LIKE
            likeLink.append(currentID)
            likeLink.append(kPM_PATH_LIKE)
            Alamofire.request(.GET, likeLink)
                .responseJSON { response in
                    if response.response?.statusCode == 200 {
                        let likeJson = response.result.value as! NSDictionary
                        var likeNumber = String(format:"%0.f", likeJson[kCount]!.doubleValue)
                        likeNumber.append(" likes")
                        cell.likeLB.text = likeNumber
                    } else {
                    }
            }
            return cell
        }else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedThirdPartTableViewCell", for: indexPath) as! FeedThirdPartTableViewCell
            if userFeed == nil {
                return cell
            }
            cell.userCommentLB.text = (userFeed[kFirstname] as! String).uppercased()
            
            cell.contentCommentTV.delegate = self
            cell.contentCommentTV.text = feedDetail[kText] as? String
            cell.contentCommentTVConstraint.constant = (cell.contentCommentTV.text?.heightWithConstrainedWidth(cell.contentCommentTV.frame.width, font: cell.contentCommentTV.font!))! + 20
            return cell
        } else {
            
            let comment = self.listComment[(self.listComment.count - 1) - (indexPath.row-3)]
            if (comment[kImageUrl] is NSNull) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedThirdPartTableViewCell, for: indexPath) as! FeedThirdPartTableViewCell
                let text = comment[kText] as! String
                var userComment = kPMAPIUSER
                let userId = String(format:"%0.f", comment[kUserId]!.doubleValue)
                userComment.append(userId)
                Alamofire.request(.GET, userComment)
                    .responseJSON { response in
                        if response.response?.statusCode == 200 {
                            DispatchQueue.main.async(execute: {
                                let userCommentInfo = response.result.value as! NSDictionary
                                let userName = userCommentInfo[kFirstname] as! String
                                cell.userCommentLB.text = userName.uppercased()
                                cell.contentCommentTV.text = text
                                cell.contentCommentTVConstraint.constant = (cell.contentCommentTV.text?.heightWithConstrainedWidth(cell.contentCommentTV.frame.width, font: cell.contentCommentTV.font!))! + 20
                            })
                        }
                }
                
                return cell

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedFourthPartTableViewCell, for: indexPath) as! FeedFourthPartTableViewCell
                let text = comment[kText] as! String
                var userComment = kPMAPIUSER
                let userId = String(format:"%0.f", comment[kUserId]!.doubleValue)
                userComment.append(userId)
                Alamofire.request(.GET, userComment)
                    .responseJSON { response in
                        if response.response?.statusCode == 200 {
                            DispatchQueue.main.async(execute: {
                                let userCommentInfo = response.result.value as! NSDictionary
                                let userName = userCommentInfo[kFirstname] as! String
                                cell.userCommentLB.text = userName.uppercased()
                                cell.contentCommentLB.text = text
                                cell.contentCommentConstrant.constant = (cell.contentCommentLB.text?.heightWithConstrainedWidth(cell.contentCommentLB.frame.width, font: cell.contentCommentLB.font))! + 20
                            })
                        }
                }
                
                var link = kPMAPI
                link.append(comment[kImageUrl] as! String)
                link.append(widthEqual)
                link.append(String(self.view.frame.width*2))
                link.append(heighEqual)
                link.append(String(self.view.frame.width*2))
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
        likeLink.append(String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue))
        likeLink.append(kPM_PATH_LIKE)
        Alamofire.request(.POST, likeLink, parameters: [kPostId: String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)])
            .responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                } else {
                    print("cant like")
                }
        }
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "goNewPost") {
            let destination = segue.destination as! NewCommentImageViewController
            destination.postId = String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)
        } else if (segue.identifier == kClickURLLink) {
            let destination = segue.destination as! FeedWebViewController
            destination.URL = sender as? NSURL
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
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alertController.addAction(UIAlertAction(title: KReport, style: UIAlertActionStyle.destructive, handler: selectDeleted))
        alertController.addAction(UIAlertAction(title: kShare, style: UIAlertActionStyle.destructive, handler: share))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: selectCancle))
        
        self.present(alertController, animated: true) { }
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
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func getImageAvatarTextBox() {
        let avatarImage = UIImage(named: "display-empty.jpg")
        self.avatarTextBox.image = avatarImage
        
        ImageRouter.getCurrentUserAvatar(sizeString: widthHeight120, completed: { (result, error) in
            if (error == nil) {
                let textBoxImage = result as! UIImage
                
                self.avatarTextBox.image = textBoxImage
            } else {
                print("Request failed with error: \(error)")
            }
        }).fetchdata()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
        self.tableView.setContentOffset(bottomOffset, animated: false)
        if let keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            self.view.frame.origin.y = 64 - keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
            self.view.frame.origin.y = 64
        if (self.textBox.text == "") {
            self.cursorView.isHidden = false
            self.avatarTextBox.isHidden = true
            self.leftMarginLeftChatCT.constant = 15
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.addComment()
        return true
    }
    
    @IBAction func addComment() {
        let text = self.textBox.text
        
        if (text.isEmpty == false) {
            let postId = String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)
            var link = kPMAPI
            link.append("/api/posts/")
            link.append(String(postId))
            link.append("/comments")
            
            self.postButton.isUserInteractionEnabled = false
            
            Alamofire.request(.POST, link, parameters: [kPostId:postId, kText:text])
                .responseJSON { response in
                    self.postButton.isUserInteractionEnabled = true
                    
                    if response.response?.statusCode == 200 {
                        self.textBox.text = ""
                        self.getLastComment()
                    } else {
                        PMHelper.showDoAgainAlert()
                    }
            }
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.cursorView.isHidden = true
        self.avatarTextBox.isHidden = false
        self.leftMarginLeftChatCT.constant = 40
    }
    
    func timeAgoSinceDate(date:NSDate) -> String {
        let calendar = NSCalendar.current
        let unitFlags : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .Month, .Year]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
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
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.performSegue(withIdentifier: kClickURLLink, sender: URL)
        
        return false
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.frame.origin.y = 64
        self.cursorView.isHidden = false
        self.avatarTextBox.isHidden = true
        self.leftMarginLeftChatCT.constant = 15
        self.textBox.resignFirstResponder()
    }
    
    func cancel() {
        if self.fromPhoto == true {
            self.navigationController?.dismissViewControllerAnimated(animated: true, completion: nil)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    

}
