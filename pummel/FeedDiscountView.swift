//
//  FeedDiscountView.swift
//  pummel
//
//  Created by Nguyen Vu Hao on 6/12/17.
//  Copyright © 2017 pummel. All rights reserved.
//

import UIKit

@objc protocol FeedDiscountViewDelegate {
    func goToDetailDiscount(discount: DiscountModel)
    func loadMoreDiscount()
}

class FeedDiscountView: UIView {
    
    var cv: UICollectionView!
    var cvLayout: UICollectionViewFlowLayout!
    var arrayResult : [DiscountModel] = [] {
        didSet {
            self.cv.reloadData()
        }
    }
    var widthCell : CGFloat = 0.0
    weak var delegate : FeedDiscountViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.widthCell = (self.bounds.size.width - 50)
        
        
        self.cvLayout = UICollectionViewFlowLayout()
        self.cvLayout.itemSize = CGSize(width: (self.bounds.size.width - 50), height: self.bounds.height)
        self.cvLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 0)
        self.cvLayout.minimumLineSpacing = 10
        self.cvLayout.scrollDirection = .horizontal
        
        self.cv = UICollectionView.init(frame: self.bounds, collectionViewLayout: self.cvLayout)
        let nibName = UINib(nibName: "DiscountColectionViewCell", bundle: nil)
        self.cv.register(nibName, forCellWithReuseIdentifier: "DiscountColectionViewCell")
        self.cv.delegate = self
        self.cv.dataSource = self
        
        self.cv.isScrollEnabled = false
        self.cv.backgroundColor = UIColor.groupTableViewBackground
        
        self.addSubview(self.cv)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func endPagingCarousel(scrollView: UIScrollView) {
        if scrollView == self.cv {
            // custom pageing
            var point = scrollView.contentOffset
            point.x = self.widthCell * CGFloat(Int(round((point.x / self.widthCell))))
            
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
    func carouselSwipeLeft() {
        var offsetX = self.cv.contentOffset.x + self.widthCell
        offsetX = offsetX > self.cv.contentSize.width - self.widthCell ? self.cv.contentSize.width - self.widthCell : offsetX
        
        let newContentOffset = CGPoint(x: offsetX, y: 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.cv.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(scrollView: self.cv)
        }
    }
    
    func carouselSwipeRight() {
        var offsetX = self.cv.contentOffset.x - self.widthCell
        offsetX = offsetX < 0 ? 0 : offsetX
        
        let newContentOffset = CGPoint(x: offsetX, y: 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.cv.contentOffset = newContentOffset
        }) { (_) in
            self.endPagingCarousel(scrollView: self.cv)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FeedDiscountView : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscountColectionViewCell", for: indexPath) as! DiscountColectionViewCell
        
        let discount = self.arrayResult[indexPath.row]
        cell.setData(discount: discount)
        
        // add Swipe gesture
        if (cell.gestureRecognizers == nil || (cell.gestureRecognizers?.count)! < 2) {
            let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeLeft))
            swipeLeftGesture.direction = .left
            cell.addGestureRecognizer(swipeLeftGesture)
            
            let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(carouselSwipeRight))
            swipeRightGesture.direction = .right
            cell.addGestureRecognizer(swipeRightGesture)
        }
        
        if indexPath.row == self.arrayResult.count - 1 {
            self.delegate?.loadMoreDiscount()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cvLayout.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= self.arrayResult.count {
            return
        }
        
        if (self.delegate != nil) {
            let discount = self.arrayResult[indexPath.row]
            self.delegate?.goToDetailDiscount(discount: discount)
        }
    }
}
