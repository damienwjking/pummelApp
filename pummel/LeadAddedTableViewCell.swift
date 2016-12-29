//
//  LeadAddedTableViewCell.swift
//  pummel
//
//  Created by Hao Nguyen Vu on 12/22/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol LeadAddedTableViewCellDelegate: class {
    optional func removeUserWithID(userId:String)
}

class LeadAddedTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var titleHeader: UILabel!
    let defaults = NSUserDefaults.standardUserDefaults()
    var idUser = ""
    weak var delegateLeadAddedTableViewCell: LeadAddedTableViewCellDelegate?
    
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
        if idUser == "" {
            return 0
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LeadAddedCollectionViewCell", forIndexPath: indexPath) as! LeadAddedCollectionViewCell

        var prefixUser = kPMAPIUSER
        prefixUser.appendContentsOf(idUser)
        Alamofire.request(.GET, prefixUser)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                cell.imgAvatar.image = UIImage(named: "display-empty.jpg")
                if let userInfo = JSON as? NSDictionary {
                    var link = kPMAPI
                    if !(userInfo[kImageUrl] is NSNull) {
                        link.appendContentsOf(userInfo[kImageUrl] as! String)
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
        return CGSize(width: 50,height: 50)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.delegateLeadAddedTableViewCell != nil {
            self.delegateLeadAddedTableViewCell?.removeUserWithID!(idUser)
        }
    }
}
