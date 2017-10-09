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

class FeedViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var feedDetail : NSDictionary!
    var userFeed : NSDictionary!
   
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentPlaceHolder: UILabel!
    @IBOutlet weak var commentTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet var cursorView: UIView!
    @IBOutlet var leftMarginLeftChatCT: NSLayoutConstraint!
    @IBOutlet var avatarTextBox: UIImageView!
    var listComment : [NSDictionary] = []
    var stopGetListComment : Bool = false
    var offset: Int = 0
    var fromPhoto = false
    
    // MARK: - Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "blackArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.leftButtonClicked))
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
        
        self.navigationItem.hidesBackButton = true;
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(self.tableViewTapped(recognizer:)))
        self.tableView.addGestureRecognizer(recognizer)
        self.avatarTextBox.layer.cornerRadius = 20
        self.avatarTextBox.clipsToBounds = true
        self.avatarTextBox.isHidden = true
        self.getImageAvatarTextBox()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)
            ), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.listComment.removeAll()
        self.stopGetListComment = false
        self.offset = 0
        self.getListComment()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let scrollPoint = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height);
        self.tableView.setContentOffset(scrollPoint, animated: true);
        self.tableView.reloadData()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let bottomOffset = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.bounds.size.height);
        self.tableView.setContentOffset(bottomOffset, animated: false)
        if let keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) {
            self.view.frame.origin.y = 64 - keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 64
        if (self.commentTextView.text == "") {
            self.cursorView.isHidden = false
            self.avatarTextBox.isHidden = true
            self.leftMarginLeftChatCT.constant = 15
        }
    }
    
    func getListComment() {
        if (stopGetListComment == false) {
            let postId = String(format:"%0.f", (feedDetail[kId]! as AnyObject).doubleValue)
            
            FeedRouter.getComment(postID: postId, offset: self.offset, limit: 10, completed: { (result, error) in
                if (error == nil) {
                    let list = result as! [NSDictionary]
                    if (list.count > 0) {
                        self.listComment = self.listComment + list
                        self.offset += 10
                        self.getListComment()
                        
                        self.tableView.beginUpdates()
                        self.tableView.reloadData()
                        self.tableView.endUpdates()
                    } else {
                        self.stopGetListComment = true
                    }
                } else {
                    self.stopGetListComment = true
                    
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        }
    }
    
    @IBAction func goNewPost() {
        self.commentTextView.resignFirstResponder()
        self.performSegue(withIdentifier: "goNewPost", sender: nil)
    }
    
    func likeThisPost(sender: UIButton!) {
        //Post Likes
        let postID = String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)
        FeedRouter.sendLikePost(postID: postID) { (result, error) in
            let isSendSuccess = result as! Bool
            
            if (isSendSuccess) {
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
                
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
            }
        }.fetchdata()
    }
    
    func showListContext(sender: UIButton) {
        let share = { (action:UIAlertAction!) -> Void in
            self.shareTextImageAndURL(sharingText: pummelSlogan, sharingImage: UIImage(named: "shareLogo.png"), sharingURL: NSURL.init(string: kPM))
        }
        
        let selectCancle = { (action:UIAlertAction!) -> Void in
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: kShare, style: UIAlertActionStyle.destructive, handler: share))
        alertController.addAction(UIAlertAction(title: kCancle, style: UIAlertActionStyle.cancel, handler: selectCancle))
        
        self.present(alertController, animated: true) { }
    }
    
    func shareTextImageAndURL(sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text as AnyObject)
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
        
        ImageVideoRouter.getCurrentUserAvatar(sizeString: widthHeight120, completed: { (result, error) in
            if (error == nil) {
                let textBoxImage = result as! UIImage
                
                self.avatarTextBox.image = textBoxImage
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }).fetchdata()
    }
    
    @IBAction func addComment() {
        let text = self.commentTextView.text
        
        if (text?.isEmpty == false) {
            let postId = String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)
            
            self.postButton.isUserInteractionEnabled = false
            
            FeedRouter.postComment(postID: postId, text: text!, completed: { (result, error) in
                self.postButton.isUserInteractionEnabled = true
                
                let isPostSuccess = result as! Bool
                if (isPostSuccess == true) {
                    self.commentTextView.text = ""
                    
                    self.offset = 0
                    self.listComment.removeAll()
                    self.getListComment()
                } else {
                    PMHelper.showDoAgainAlert()
                }
            }).fetchdata()
        }
    }
    
    func tableViewTapped(recognizer: UITapGestureRecognizer) {
        self.view.frame.origin.y = 64
        self.cursorView.isHidden = false
        self.avatarTextBox.isHidden = true
        self.leftMarginLeftChatCT.constant = 15
        self.commentTextView.resignFirstResponder()
    }
    
    func leftButtonClicked() {
        if self.fromPhoto == true {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationController?.popViewController(animated: true)
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
}

// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
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
                
                ImageVideoRouter.getImage(imageURLString: imageLink, sizeString: widthHeight120, completed: { (result, error) in
                    if (error == nil) {
                        let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath as NSIndexPath)
                        if visibleCell == true {
                            let imageRes = result as! UIImage
                            cell.avatarBT.setBackgroundImage(imageRes, for: .normal)
                        }
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
            } else {
                cell.avatarBT.setBackgroundImage(UIImage(named: "display-empty.jpg"), for: .normal)
            }
            
            let timeAgo = feedDetail[kCreateAt] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = kFullDateFormat
            dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            let date : NSDate = dateFormatter.date(from: timeAgo)! as NSDate
            cell.timeLB.text = date.timeAgoSinceDate()
            
            cell.imageContentIMV.image = nil
            if (feedDetail[kImageUrl] is NSNull == false) {
                let imageContentLink = feedDetail[kImageUrl] as! String
                
                ImageVideoRouter.getImage(imageURLString: imageContentLink, sizeString: widthHeightScreenx2, completed: { (result, error) in
                    if (error == nil) {
                        let imageRes = result as! UIImage
                        cell.imageContentIMV.image = imageRes
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
            }
            
            cell.shareBT.tag = indexPath.row
            cell.shareBT.addTarget(self, action: #selector(self.showListContext(sender:)), for: .touchUpInside)
            cell.likeBT.addTarget(self, action: #selector(self.likeThisPost(sender:)), for: .touchUpInside)
            //Get Likes status
            let postID = String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)
            
            cell.likeBT.isUserInteractionEnabled = true
            cell.likeBT.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
            FeedRouter.getLikePost(postID: postID, completed: { (result, error) in
                if (error == nil) {
                    let JSON = result as! NSDictionary
                    let rows = JSON[kRows] as! [NSDictionary]
                    let currentId = PMHelper.getCurrentID()
                    
                    for row in rows {
                        let userID = String(format:"%0.f", (row[kUserId]! as AnyObject).doubleValue)
                        
                        if (userID == currentId) {
                            cell.likeBT.isUserInteractionEnabled = false
                            cell.likeBT.setBackgroundImage(UIImage(named: "liked.png"), for: .normal)
                            break
                        }
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
            
            // Check Coach
            let userID = String(format:"%0.f", (feedDetail[kUserId]! as AnyObject).doubleValue)
            
            cell.coachLB.text = ""
            cell.avatarBT.layer.borderWidth = 0
            cell.coachLBTraillingConstraint.constant = 0
            
            cell.isUserInteractionEnabled = false
            UserRouter.checkCoachOfUser(userID: userID, completed: { (result, error) in
                cell.isUserInteractionEnabled = true
                
                let isCoach = result as! Bool
                if (isCoach == true) {
                    cell.avatarBT.layer.borderWidth = 2
                    
                    cell.coachLBTraillingConstraint.constant = 5
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.coachLB.layoutIfNeeded()
                        cell.coachLB.text = kCoach.uppercased()
                    })
                }
            }).fetchdata()
            
            
            
            return cell
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: kFeedSecondPartTableViewCell, for: indexPath) as! FeedSecondPartTableViewCell
            //Get Likes
            let postID = String(format:"%0.f", (self.feedDetail[kId]! as AnyObject).doubleValue)
            FeedRouter.getLikePost(postID: postID, completed: { (result, error) in
                if (error == nil) {
                    let likeJson = result as! NSDictionary
                    var likeNumber = String(format:"%0.f", (likeJson[kCount]! as AnyObject).doubleValue)
                    likeNumber.append(" likes")
                    cell.likeLB.text = likeNumber
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
            
            return cell
        }else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedThirdPartTableViewCell", for: indexPath) as! FeedThirdPartTableViewCell
            if userFeed == nil {
                return cell
            }
            cell.userCommentLB.text = (userFeed[kFirstname] as! String).uppercased()
            
            cell.contentCommentTV.delegate = self
            cell.contentCommentTV.text = feedDetail[kText] as? String
            cell.contentCommentTVConstraint.constant = (cell.contentCommentTV.text?.heightWithConstrainedWidth(width: cell.contentCommentTV.frame.width, font: cell.contentCommentTV.font!))! + 20
            return cell
        } else {
            
            let comment = self.listComment[(self.listComment.count - 1) - (indexPath.row - 3)]
            if (comment[kImageUrl] is NSNull) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedThirdPartTableViewCell, for: indexPath) as! FeedThirdPartTableViewCell
                let text = comment[kText] as! String
                let userId = String(format:"%0.f", (comment[kUserId]! as AnyObject).doubleValue)
                
                UserRouter.getUserInfo(userID: userId, completed: { (result, error) in
                    if (error == nil) {
                        DispatchQueue.main.async(execute: {
                            let userCommentInfo = result as! NSDictionary
                            let userName = userCommentInfo[kFirstname] as! String
                            cell.userCommentLB.text = userName.uppercased()
                            cell.contentCommentTV.text = text
                            cell.contentCommentTVConstraint.constant = (cell.contentCommentTV.text?.heightWithConstrainedWidth(width: cell.contentCommentTV.frame.width, font: cell.contentCommentTV.font!))! + 20
                        })
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: kFeedFourthPartTableViewCell, for: indexPath) as! FeedFourthPartTableViewCell
                
                let text = comment[kText] as! String
                let userId = String(format:"%0.f", (comment[kUserId]! as AnyObject).doubleValue)
                
                
                UserRouter.getUserInfo(userID: userId, completed: { (result, error) in
                    if (error == nil) {
                        DispatchQueue.main.async(execute: {
                            let userCommentInfo = result as! NSDictionary
                            let userName = userCommentInfo[kFirstname] as! String
                            cell.userCommentLB.text = userName.uppercased()
                            cell.contentCommentLB.text = text
                            cell.contentCommentConstrant.constant = (cell.contentCommentLB.text?.heightWithConstrainedWidth(width: cell.contentCommentLB.frame.width, font: cell.contentCommentLB.font))! + 20
                        })
                    } else {
                        print("Request failed with error: \(String(describing: error))")
                    }
                }).fetchdata()
                
                let commentImageURL = comment[kImageUrl] as? String
                if (commentImageURL != nil && commentImageURL?.isEmpty == false) {
                    ImageVideoRouter.getImage(imageURLString: commentImageURL!, sizeString: widthHeightScreenx2, completed: { (result, error) in
                        if (error == nil) {
                            let imageRes = result as! UIImage
                            cell.contentCommentImageView.image = imageRes
                        } else {
                            print("Request failed with error: \(String(describing: error))")
                        }
                    }).fetchdata()
                }
                
                return cell
            }
        }
    }

}

// MARK: - UITextViewDelegate
extension FeedViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Hide/unhide placeholder
        let commentText = self.commentTextView.text! as NSString
        self.commentPlaceHolder.isHidden = (commentText.length > 0)
        
        // Get height
        var textHeight = self.commentTextView.getHeightWithWidthFixed()
        if (textHeight > 200) {
            textHeight = 200
        }
        
        self.commentTextViewHeightConstraint.constant = textHeight
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.addComment()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.cursorView.isHidden = true
        self.avatarTextBox.isHidden = false
        self.leftMarginLeftChatCT.constant = 40
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.performSegue(withIdentifier: kClickURLLink, sender: URL)
        
        return false
    }
}
