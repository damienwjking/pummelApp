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
    
    
    func setupData(photoDictionary: NSDictionary) {
        if (photoDictionary[kImageUrl] is NSNull == false) {
            let imageURLString = photoDictionary.objectForKey(kImageUrl) as! String
            
            ImageRouter.getImage(imageURLString: imageURLString, sizeString: widthHeightScreen, completed: { (result, error) in
                if (error == nil) {
                    let imageRes = result as! UIImage
                    self.imageCell.image = imageRes
                } else {
                    print("Request failed with error: \(error)")
                }
            }).fetchdata()
        }
    }
}
