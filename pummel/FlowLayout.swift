//
//  FlowLayout.swift
//  TagFlowLayout
//
//  Created by Bear Daddy on 6/27/16.
//  Copyright © 2016 pummel. All rights reserved.
//

import UIKit

class FlowLayout: UICollectionViewFlowLayout {
    var smaller : Bool = false
    var isSearch : Bool = false
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesForElementsInRect = super.layoutAttributesForElements(in: rect)
        var newAttributesForElementsInRect = [UICollectionViewLayoutAttributes]()
        
        var leftMargin: CGFloat = 0.0;
    
        for attributes in attributesForElementsInRect! {
            if (attributes.frame.origin.x == self.sectionInset.left) {
                leftMargin = self.sectionInset.left
            } else {
                var newLeftAlignedFrame = attributes.frame
                newLeftAlignedFrame.origin.x = leftMargin
                attributes.frame = newLeftAlignedFrame
            }
            
            leftMargin += (isSearch) ? attributes.frame.size.width + 8 : attributes.frame.size.width
            if (leftMargin > (self.collectionView?.frame.width)!) {
                leftMargin = self.sectionInset.left
                attributes.frame.origin.x = leftMargin
                leftMargin = self.sectionInset.left + attributes.frame.size.width + 8
            }
            if (attributes.frame.origin.y != 0 && smaller == true) {
                attributes.frame.origin.y -= 8
            }
            
            newAttributesForElementsInRect.append(attributes)
        }
        
        return newAttributesForElementsInRect
    }
}
