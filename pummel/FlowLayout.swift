//
//  FlowLayout.swift
//  TagFlowLayout
//
//  Created by Diep Nguyen Hoang on 7/30/15.
//  Copyright (c) 2015 CodenTrick. All rights reserved.
//

import UIKit

class FlowLayout: UICollectionViewFlowLayout {
    var smaller : Bool = false
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesForElementsInRect = super.layoutAttributesForElementsInRect(rect)
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
            
            leftMargin += attributes.frame.size.width + 8
            if (leftMargin > self.collectionView?.frame.width) {
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