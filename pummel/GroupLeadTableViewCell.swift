//
//  GroupLeadTableViewCell.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

enum TypeGroup:Int {
    case NewLead = 0, Current, Old, CoachJustConnected, CoachCurrent, CoachOld
}

@objc protocol GroupLeadTableViewCellDelegate: class {
    optional func selectUserWithID(userId:String, typeGroup:Int)
}


class GroupLeadTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var titleHeader: UILabel!
    var arrayMessages: [NSDictionary] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    var typeGroup:TypeGroup!
    weak var delegateGroupLeadTableViewCell: GroupLeadTableViewCellDelegate?
    var userIdSelected = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        //layout.estimatedItemSize =  CGSize(width: 70, height: 70)
        self.cv.dataSource = self
        self.cv.delegate = self
        let nibName = UINib(nibName: "LeadCollectionViewCell" , bundle:nil)
        self.cv.registerNib(nibName, forCellWithReuseIdentifier: "LeadCollectionViewCell")
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LeadCollectionViewCell", forIndexPath: indexPath) as! LeadCollectionViewCell
        cell.btnAdd.hidden = true
        
        let message = arrayMessages[indexPath.row]
        var targetUserId = ""
        if self.typeGroup == TypeGroup.CoachJustConnected || self.typeGroup == TypeGroup.CoachOld || self.typeGroup == TypeGroup.CoachCurrent {
            if let val = message["coachId"] as? Int {
                targetUserId = "\(val)"
            }
        } else{
            if let val = message["userId"] as? Int {
                targetUserId = "\(val)"
            }
        }
        
        cell.nameUser.text = "Name"
        var prefixUser = kPMAPIUSER
        prefixUser.appendContentsOf(targetUserId)
        Alamofire.request(.GET, prefixUser)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                cell.imgAvatar.image = UIImage(named: "display-empty.jpg")
                cell.btnAdd.hidden = false
                if self.typeGroup == TypeGroup.CoachJustConnected || self.typeGroup == TypeGroup.CoachOld || self.typeGroup == TypeGroup.CoachCurrent {
                    cell.btnAdd.hidden = true
                }
                
                if let userInfo = JSON as? NSDictionary {
                    let name = userInfo.objectForKey(kFirstname) as! String
                    cell.nameUser.text = name.uppercaseString
                    var link = kPMAPI
                    if !(JSON[kImageUrl] is NSNull) {
                        link.appendContentsOf(JSON[kImageUrl] as! String)
                        link.appendContentsOf(widthHeight160)
                        Alamofire.request(.GET, link)
                            .responseImage { response in
                                let imageRes = response.result.value! as UIImage
                                cell.imgAvatar.image = imageRes
                        }
                    }
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
        let userInfo = arrayMessages[indexPath.row]
        
        var targetUserId = ""
        if let val = userInfo["userId"] as? Int {
            targetUserId = "\(val)"
        }
        
        if userIdSelected == targetUserId {
            return CGSize(width: 0,height: 90)
        }
        return CGSize(width: 90,height: 90)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.delegateGroupLeadTableViewCell != nil {
            let userInfo = arrayMessages[indexPath.row]
            
            var targetUserId = ""
            if let val = userInfo["userId"] as? Int {
                targetUserId = "\(val)"
            }
            self.delegateGroupLeadTableViewCell?.selectUserWithID!(targetUserId, typeGroup: self.typeGroup.rawValue)
        }
    }
    
    func getMessage() {
        var prefix = kPMAPICOACHES
        if self.typeGroup == TypeGroup.CoachJustConnected || self.typeGroup == TypeGroup.CoachOld || self.typeGroup == TypeGroup.CoachCurrent {
            prefix = kPMAPIUSER
        }
        prefix.appendContentsOf(defaults.objectForKey(k_PM_CURRENT_ID) as! String)
        if self.typeGroup == TypeGroup.NewLead {
            prefix.appendContentsOf(kPMAPICOACH_LEADS)
        } else if self.typeGroup == TypeGroup.Current {
            prefix.appendContentsOf(kPMAPICOACH_CURRENT)
        } else if self.typeGroup == TypeGroup.Old {
            prefix.appendContentsOf(kPMAPICOACH_OLD)
        } else if self.typeGroup == TypeGroup.CoachJustConnected {
            prefix.appendContentsOf(kPMAPICOACH_JUSTCONNECTED)
        } else if self.typeGroup == TypeGroup.CoachCurrent {
            prefix.appendContentsOf(kPMAPICOACH_COACHCURRENT)
        } else if self.typeGroup == TypeGroup.CoachOld {
            prefix.appendContentsOf(kPMAPICOACH_COACHOLD)
        }
        
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                if let arrayMessageT = JSON as? [NSDictionary] {
                    self.arrayMessages = arrayMessageT
                    self.cv.reloadData()
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
}
