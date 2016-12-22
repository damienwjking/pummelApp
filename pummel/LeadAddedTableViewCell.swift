//
//  LeadAddedTableViewCell.swift
//  pummel
//
//  Created by Hao Nguyen Vu on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

class LeadAddedTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var titleHeader: UILabel!
    var arrayMessages: [NSDictionary] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    var isAdded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.cv.dataSource = self
        self.cv.delegate = self
        let nibName = UINib(nibName: "LeadAddedCollectionViewCell" , bundle:nil)
        self.cv.registerNib(nibName, forCellWithReuseIdentifier: "LeadAddedCollectionViewCell")
        self.cv.collectionViewLayout = layout
        self.cv.reloadData()
        self.titleHeader.font = .pmmMonReg13()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayMessages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LeadAddedCollectionViewCell", forIndexPath: indexPath) as! LeadAddedCollectionViewCell

        let message = arrayMessages[indexPath.row]
        let conversations = message[kConversation] as! NSDictionary
        let conversationUsers = conversations[kConversationUser] as! NSArray
        var targetUser = conversationUsers[0] as! NSDictionary
        let currentUserid = defaults.objectForKey(k_PM_CURRENT_ID) as! String
        var targetUserId = String(format:"%0.f", targetUser[kUserId]!.doubleValue)
        if (currentUserid == targetUserId){
            targetUser = conversationUsers[1] as! NSDictionary
            targetUserId = String(format:"%0.f", targetUser[kUserId]!.doubleValue)
        }
        
        var prefixUser = kPMAPIUSER
        prefixUser.appendContentsOf(targetUserId)
        Alamofire.request(.GET, prefixUser)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let userInfo = JSON as! NSDictionary
                var link = kPMAPI
                if !(JSON[kImageUrl] is NSNull) {
                    link.appendContentsOf(JSON[kImageUrl] as! String)
                    link.appendContentsOf(widthHeight160)
                    Alamofire.request(.GET, link)
                        .responseImage { response in
                            let imageRes = response.result.value! as UIImage
                            cell.imgAvatar.image = imageRes
                    }
                } else {
                    cell.imgAvatar.image = UIImage(named: "display-empty.jpg")
           
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 50,height: 50)
    }
    
    func getMessage() {
        var prefix = kPMAPIUSER
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        prefix.appendContentsOf(kPM_PATH_CONVERSATION_OFFSET)
        prefix.appendContentsOf(String(0))
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                let arrayMessageT = JSON as! [NSDictionary]
                if (arrayMessageT.count > 0) {
                    self.arrayMessages += arrayMessageT
                    self.cv.reloadData()
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
}
