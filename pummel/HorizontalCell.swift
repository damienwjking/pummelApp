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
        let name = leadDictionay.object(forKey: kFirstname) as! String
        self.name.text = name.uppercased()
        
        let imageURLString = leadDictionay[kImageUrl] as? String
        if (imageURLString != nil && imageURLString?.isEmpty == false) {
            ImageVideoRouter.getImage(imageURLString: imageURLString!, sizeString: widthHeight160, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.imageV.image = imageRes
                    self.addButton.isHidden = false
                } else {
                    print("Request failed with error: \(String(describing: error))")
                }
            }).fetchdata()
        } else {
            self.imageV.image = UIImage(named: "display-empty.jpg")
            self.addButton.isHidden = false
        }
    }
}
