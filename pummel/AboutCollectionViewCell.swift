//
//  AboutCollectionViewCell.swift
//  pummel
//
//  Created by Bear Daddy on 7/4/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class AboutCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageCell: UIImageView!
    
    func setupData(photo: PhotoModel) {
        if (photo.imageUrl.isEmpty == false) {
            self.imageCell.image = photo.imageCache
        }
    }
}
