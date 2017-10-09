//
//  TextViewAutoHeight.swift
//  TextViewAutoHeightDemo
//
//  Created by pc-laptp on 12/3/14.
//  Copyright (c) 2014 StreetCoding. All rights reserved.
//

import UIKit

class TextViewAutoHeight: UITextView {
    
    //MARK: attributes

    var  maxHeight:CGFloat?
    var  heightConstraint:NSLayoutConstraint?
   
    //MARK: initialize
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpInit()
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame)
        setUpInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpConstraint()
    }
    
    //MARK: private
    
    private func setUpInit() {
        for constraint in self.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height {
                self.heightConstraint = constraint as? NSLayoutConstraint;
                break;
            }
        }
        
    }
    
    private func setUpConstraint() {
        var finalContentSize:CGSize = self.contentSize
        finalContentSize.width  += (self.textContainerInset.left + self.textContainerInset.right ) / 2.0
        finalContentSize.height += (self.textContainerInset.top  + self.textContainerInset.bottom) / 2.0
        
        fixTextViewHeigth(finalContentSize: finalContentSize)
    }
    
    private func fixTextViewHeigth(finalContentSize:CGSize) {
        if let maxHeight = self.maxHeight {
            var  customContentSize = finalContentSize;
            
            customContentSize.height = min(customContentSize.height, CGFloat(maxHeight))
            
            self.heightConstraint?.constant = customContentSize.height;
            
            if finalContentSize.height <= self.frame.height {
                let textViewHeight = (self.frame.height - self.contentSize.height * self.zoomScale)/2.0
                
                self.contentOffset = CGPoint(x: 0, y: -(textViewHeight < 0.0 ? 0.0 : textViewHeight))
                
            }
        }
    }
}
