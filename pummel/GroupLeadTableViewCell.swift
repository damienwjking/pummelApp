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
    optional func selectUserWithCoachInfo(coachInfo:NSDictionary)
}


class GroupLeadTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var titleHeader: UILabel!
    var arrayMessages: [NSDictionary] = []
    var arrayCoachesInfo: [NSDictionary] = []
    let defaults = UserDefaults.standard
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
        self.cv.register(nibName, forCellWithReuseIdentifier: "LeadCollectionViewCell")
        self.cv.collectionViewLayout = layout
        self.cv.reloadData()
        self.titleHeader.font = .pmmMonReg13()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LeadCollectionViewCell", for: indexPath) as! LeadCollectionViewCell
        cell.btnAdd.isHidden = true
        
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
    
        UserRouter.getUserInfo(userID: targetUserId) { (result, error) in
            if (error == nil) {
                let updateCell = collectionView.cellForItemAtIndexPath(indexPath)
                if (updateCell != nil) {
                    cell.imgAvatar.image = UIImage(named: "display-empty.jpg")
                    cell.btnAdd.isHidden = false
                    if self.typeGroup == TypeGroup.CoachJustConnected || self.typeGroup == TypeGroup.CoachOld || self.typeGroup == TypeGroup.CoachCurrent {
                        cell.btnAdd.isHidden = true
                    }
                    
                    if let userInfo = result as? NSDictionary {
                        let name = userInfo.object(forKey: kFirstname) as! String
                        cell.nameUser.text = name.uppercased()
                        self.arrayCoachesInfo[indexPath.row] = userInfo
                        
                        if (userInfo[kImageUrl] is NSNull == false) {
                            let imageURLString = userInfo[kImageUrl] as! String
                            
                            ImageVideoRouter.getImage(imageURLString: imageURLString, sizeString: widthHeight160, completed: { (result, error) in
                                if (error == nil) {
                                    let updateCell = collectionView.cellForItemAtIndexPath(indexPath)
                                    if (updateCell != nil) {
                                        let imageRes = result as! UIImage
                                        cell.imgAvatar.image = imageRes
                                    }
                                } else {
                                    print("Request failed with error: \(String(describing: error))")
                                }
                            }).fetchdata()
                        }
                    }
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.delegateGroupLeadTableViewCell != nil {
            let userInfo = arrayMessages[indexPath.row]
            
            var targetUserId = ""
            if let val = userInfo["userId"] as? Int {
                targetUserId = "\(val)"
            }
            if self.typeGroup == TypeGroup.CoachJustConnected || self.typeGroup == TypeGroup.CoachOld || self.typeGroup == TypeGroup.CoachCurrent {
                self.delegateGroupLeadTableViewCell?.selectUserWithCoachInfo!(self.arrayCoachesInfo[indexPath.row])
                return
            }
            self.delegateGroupLeadTableViewCell?.selectUserWithID!(targetUserId, typeGroup: self.typeGroup.rawValue)
        }
    }
    
    func getMessage() {
        var prefix = kPMAPICOACHES
        if self.typeGroup == TypeGroup.CoachJustConnected || self.typeGroup == TypeGroup.CoachOld || self.typeGroup == TypeGroup.CoachCurrent {
            prefix = kPMAPIUSER
        }
        
        prefix.append(PMHelper.getCurrentID())
        
        if self.typeGroup == TypeGroup.NewLead {
            prefix.append(kPMAPICOACH_LEADS)
        } else if self.typeGroup == TypeGroup.Current {
            prefix.append(kPMAPICOACH_CURRENT)
        } else if self.typeGroup == TypeGroup.Old {
            prefix.append(kPMAPICOACH_OLD)
        } else if self.typeGroup == TypeGroup.CoachJustConnected {
            prefix.append(kPMAPICOACH_JUSTCONNECTED)
        } else if self.typeGroup == TypeGroup.CoachCurrent {
            prefix.append(kPMAPICOACH_COACHCURRENT)
        } else if self.typeGroup == TypeGroup.CoachOld {
            prefix.append(kPMAPICOACH_COACHOLD)
        }
        
        Alamofire.request(.GET, prefix)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                if let arrayMessageT = JSON as? [NSDictionary] {
                    self.arrayMessages = arrayMessageT
                    self.arrayCoachesInfo = arrayMessageT
                    self.cv.reloadData()
                }
            case .Failure(let error):
                print("Request failed with error: \(String(describing: error))")
                }
        }
    }
}
