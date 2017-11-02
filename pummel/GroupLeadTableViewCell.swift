//
//  GroupLeadTableViewCell.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

enum TypeGroup:Int {
    case NewLead = 0, Current, Old, CoachJustConnected, CoachCurrent, CoachOld
}

@objc protocol GroupLeadTableViewCellDelegate: class {
    @objc optional func selectUserWithID(userId:String, typeGroup:Int)
    @objc optional func selectUserWithCoachInfo(coachInfo:NSDictionary)
}


class GroupLeadTableViewCell: UITableViewCell {
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var titleHeader: UILabel!
    var arrayUserLead: [UserModel] = []
    let defaults = UserDefaults.standard
    var typeGroup:TypeGroup!
    weak var delegateGroupLeadTableViewCell: GroupLeadTableViewCellDelegate?
    var userIdSelected = ""
    
    var userOffset = 0
    var isStopLoadUser = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        //layout.estimatedItemSize =  CGSize(width: 70, height: 70)
        self.cv.dataSource = self
        self.cv.delegate = self
        let nibName = UINib(nibName: "LeadCollectionViewCell" , bundle:nil)
        self.cv.register(nibName, forCellWithReuseIdentifier: "LeadCollectionViewCell")
        self.cv.collectionViewLayout = layout
        self.cv.reloadData()
        self.titleHeader.font = .pmmMonReg13()
    }
    
    func getUserLead() {
        if (self.isStopLoadUser == false) {
            SessionRouter.getGroupInfo(groupType: self.typeGroup, offset: self.userOffset) { (result, error) in
                if (error == nil) {
                    if let userDetails = result as? [NSDictionary] {
                        if (userDetails.count == 0) {
                            self.isStopLoadUser = true
                        } else {
                            for userInfo in userDetails {
                                let userTemp = UserModel()
                                
                                if (self.typeGroup == TypeGroup.CoachJustConnected ||
                                    self.typeGroup == TypeGroup.CoachOld ||
                                    self.typeGroup == TypeGroup.CoachCurrent) {
                                    if let val = userInfo["coachId"] as? Int {
                                        userTemp.id = val
                                    }
                                } else{
                                    if let val = userInfo["userId"] as? Int {
                                        userTemp.id = val
                                    }
                                }
                                
                                if (userTemp.existInList(userList: self.arrayUserLead) == false) {
                                    userTemp.delegate = self
                                    userTemp.synsData()
                                    
                                    self.arrayUserLead.append(userTemp)
                                }
                            }
                
                            self.userOffset = self.userOffset + 20
                            
                            self.cv.reloadData()
                        }
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
                }.fetchdata()
        }
    }
    
    func getNewUserLead() {
        self.arrayUserLead.removeAll()
        self.userOffset = 0
        self.isStopLoadUser = false
        
        self.getUserLead()
    }
}

// MARK: - UserModelDelegate
extension GroupLeadTableViewCell: UserModelDelegate {
    func userModelSynsCompleted() {
        self.cv.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension GroupLeadTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayUserLead.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeadCollectionViewCell", for: indexPath) as! LeadCollectionViewCell
        
        // Loadmore
        if (indexPath.row == self.arrayUserLead.count - 2) {
            self.getUserLead()
        }
        
        let userLead = self.arrayUserLead[indexPath.row]
        cell.setupData(userInfo: userLead)
        
        // Hide/Unhide add button
        cell.setupLayout(isShowAddButton: true)
        if self.typeGroup == TypeGroup.CoachJustConnected || self.typeGroup == TypeGroup.CoachOld || self.typeGroup == TypeGroup.CoachCurrent {
            cell.setupLayout(isShowAddButton: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let userInfo = self.arrayUserLead[indexPath.row]
        
        let targetUserId = "\(userInfo.id)"
        
        if self.userIdSelected == targetUserId {
            return CGSize(width: 0,height: 90)
        }
        return CGSize(width: 90,height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.delegateGroupLeadTableViewCell != nil {
            let userInfo = self.arrayUserLead[indexPath.row]
            let targetUserId = "\(userInfo.id)"
            
            if self.typeGroup == TypeGroup.CoachJustConnected ||
                self.typeGroup == TypeGroup.CoachOld ||
                self.typeGroup == TypeGroup.CoachCurrent {
                let userDictionary = userInfo.convertToDictionary()
                
                self.delegateGroupLeadTableViewCell?.selectUserWithCoachInfo!(coachInfo: userDictionary)
            } else {
                self.delegateGroupLeadTableViewCell?.selectUserWithID!(userId: targetUserId, typeGroup: self.typeGroup.rawValue)
            }
        }
    }
}
