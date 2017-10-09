//
//  HorizontalCell.swift
//  Swift_TableView_ Horizontal
//
//  Created by（ 捉个妹子来玩玩 ---- 陶亚利 ）
//  on 16/5/20.
//  taoyali_1234@163.com
//
//  Copyright © 2016年 陶亚利. All rights reserved.
//

import UIKit

class HorizontalCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var imageV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageV.layer.cornerRadius = 35
        imageV.clipsToBounds = true
        imageV.layer.borderColor = UIColor.pmmBrightOrangeColor().cgColor
        
        addButton.clipsToBounds = true
        addButton.layer.cornerRadius = 10;
        name.font = .pmmMonReg13()
        // Initialization code

        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(leadDictionay: NSDictionary) {
        let userInfo = result as! NSDictionary
        let name = userInfo.object(forKey: kFirstname) as! String
        cell!.name.text = name.uppercased()
        
        if (userInfo[kImageUrl] is NSNull == false) {
            let imageURLString = userInfo[kImageUrl] as! String
            ImageVideoRouter.getImage(imageURLString: imageURLString, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                    let visibleCell = PMHelper.checkVisibleCell(tableView: tableView, indexPath: indexPath as NSIndexPath)
                    if visibleCell == true {
                        let imageRes = result as! UIImage
                        cell!.imageV.image = imageRes
                        cell!.addButton.isHidden = false
                    }
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        } else {
            cell?.imageV.image = UIImage(named: "display-empty.jpg")
            cell!.addButton.isHidden = false
        }
    }
}
