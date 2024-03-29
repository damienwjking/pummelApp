//
//  LeadAddedTableViewCell.swift
//  pummel
//
//  Created by Hao Nguyen Vu on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

@objc protocol LeadAddedTableViewCellDelegate: class {
    @objc optional func removeUserWithID(userId:String)
}

class LeadAddedTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var titleHeader: UILabel!
    let defaults = UserDefaults.standard
    var idUser = ""
    weak var delegateLeadAddedTableViewCell: LeadAddedTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        self.cv.dataSource = self
        self.cv.delegate = self
        let nibName = UINib(nibName: "LeadAddedCollectionViewCell" , bundle:nil)
        self.cv.register(nibName, forCellWithReuseIdentifier: "LeadAddedCollectionViewCell")
        self.cv.collectionViewLayout = layout
        self.cv.reloadData()
        self.titleHeader.font = .pmmMonReg13()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if idUser == "" {
            return 0
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeadAddedCollectionViewCell", for: indexPath) as! LeadAddedCollectionViewCell

        ImageVideoRouter.getUserAvatar(userID: self.idUser, sizeString: widthHeight160) { (result, error) in
            if (error == nil) {
                let updateCell = collectionView.cellForItem(at: indexPath)
                if (updateCell != nil) {
                    let imageRes = result as! UIImage
                    cell.imgAvatar.image = imageRes
                }
            } else {
                print("Request failed with error: \(String(describing: error))")
            }
        }.fetchdata()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50,height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.delegateLeadAddedTableViewCell != nil {
            self.delegateLeadAddedTableViewCell?.removeUserWithID!(userId: idUser)
        }
    }
}
