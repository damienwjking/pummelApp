//
//  FSAlbumViewCell.swift
//  Fusuma
//
//  Created by Thong Nguyen on 2015/11/14.
//  Copyright © 2015年 Thong Nguyen. All rights reserved.
//

import UIKit
import Photos

final class FSAlbumViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        
        didSet {
            
            self.imageView.image = image            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selected = false
    }
    
    override var selected : Bool {
        didSet {
            self.layer.borderColor = selected ? UIColor.pmmBrightOrangeColor().CGColor : UIColor.clearColor().CGColor
            self.layer.borderWidth = selected ? 2 : 0
        }
    }
}
